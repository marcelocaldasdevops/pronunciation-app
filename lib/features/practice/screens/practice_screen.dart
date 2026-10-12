import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/models/pronunciation_result.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/portuguese_phonetic_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/services/pronunciation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pronunciation_type_selector.dart';

class PracticeScreen extends StatefulWidget {
  final String? initialSentence;
  final String? initialIpa;

  const PracticeScreen({
    super.key,
    this.initialSentence,
    this.initialIpa,
  });

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  final PronunciationServiceImpl _pronService = PronunciationServiceImpl();
  final FlutterTts _tts = FlutterTts();

  bool _isPlayingNative = false;
  bool _isPlayingSlow = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<Map<String, String>> _practiceSentences = [
    {
      'text': 'I think learning pronunciation is fun',
      'ipa': '/aɪ θɪŋk ˈlɜːrnɪŋ prəˌnʌnsiˈeɪʃən ɪz fʌn/',
      'translation': 'Eu acho que aprender pronúncia é divertido',
    },
    {
      'text': 'Practice makes perfect',
      'ipa': '/ˈpræktɪs meɪks ˈpɜːrfɪkt/',
      'translation': 'A prática leva à perfeição',
    },
    {
      'text': 'Thank you for your valuable feedback',
      'ipa': '/θæŋk juː fɔːr jɔːr ˈvæljuəbəl ˈfiːdbæk/',
      'translation': 'Obrigado pelo seu valioso feedback',
    },
    {
      'text': 'The quick brown fox jumps over the lazy dog',
      'ipa': '/ðə kwɪk braʊn fɒks dʒʌmps ˈoʊvər ðə ˈleɪzi dɔːɡ/',
      'translation': 'A rápida raposa marrom pula sobre o cão preguiçoso',
    },
  ];

  int _currentSentenceIndex = 0;
  bool _isAnalyzing = false;
  PronunciationResult? _lastResult;

  @override
  void initState() {
    super.initState();
    _initTts();

    if (widget.initialSentence != null && widget.initialSentence!.trim().isNotEmpty) {
      final text = widget.initialSentence!.trim();
      final exists = _practiceSentences.any(
        (s) => s['text']?.toLowerCase() == text.toLowerCase(),
      );
      if (!exists) {
        _practiceSentences.insert(0, {
          'text': text,
          'ipa': widget.initialIpa ?? '',
          'translation': 'Frase personalizada',
        });
      }
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isPlayingNative = false;
          _isPlayingSlow = false;
        });
      }
    });

    _tts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _isPlayingNative = false;
          _isPlayingSlow = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sem voz disponível no dispositivo/navegador.'),
            backgroundColor: AppTheme.scoreYellow,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _pulseController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  Map<String, String> get _currentSentence => _practiceSentences[_currentSentenceIndex];

  Future<void> _playReferenceAudio({required bool slow}) async {
    final text = _currentSentence['text']?.trim() ?? '';
    if (text.isEmpty) return;

    if ((slow && _isPlayingSlow) || (!slow && _isPlayingNative)) {
      await _tts.stop();
      if (mounted) {
        setState(() {
          _isPlayingNative = false;
          _isPlayingSlow = false;
        });
      }
      return;
    }

    try {
      await _audioService.stopPlayback();
      await _tts.stop();

      if (kIsWeb) {
        final voices = await _tts.getVoices;
        if (voices == null || (voices is List && voices.isEmpty)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Sem voz disponível no navegador. Instale ou ative o TTS do sistema.'),
                backgroundColor: AppTheme.scoreYellow,
              ),
            );
          }
          return;
        }
      }

      setState(() {
        _isPlayingNative = !slow;
        _isPlayingSlow = slow;
      });

      await _tts.setSpeechRate(slow ? 0.30 : 0.48);
      final result = await _tts.speak(text);
      if (result != 1 && mounted) {
        setState(() {
          _isPlayingNative = false;
          _isPlayingSlow = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isPlayingNative = false;
          _isPlayingSlow = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao reproduzir áudio: $e')),
        );
      }
    }
  }

  Future<void> _toggleRecording() async {
    await _tts.stop();
    if (_isPlayingNative || _isPlayingSlow) {
      setState(() {
        _isPlayingNative = false;
        _isPlayingSlow = false;
      });
    }

    if (_audioService.isRecording) {
      setState(() => _isAnalyzing = true);
      try {
        final audioBytes = await _audioService.stopRecording();
        if (audioBytes != null) {
          final result = await _pronService.evaluatePronunciation(
            audioBytes: audioBytes,
            referenceText: _currentSentence['text']!,
            referenceIpa: _currentSentence['ipa'],
          );
          if (!mounted) return;
          setState(() {
            _lastResult = result;
            _isAnalyzing = false;
          });
        } else {
          if (!mounted) return;
          setState(() => _isAnalyzing = false);
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro na análise: $e')),
        );
      }
    } else {
      try {
        await _audioService.startRecording();
        if (!mounted) return;
        setState(() {
          _lastResult = null;
        });
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar gravação: $e')),
        );
      }
    }
    if (mounted) setState(() {});
  }

  void _nextSentence() {
    _tts.stop();
    setState(() {
      _isPlayingNative = false;
      _isPlayingSlow = false;
      _currentSentenceIndex = (_currentSentenceIndex + 1) % _practiceSentences.length;
      _lastResult = null;
    });
  }

  void _showPhonemeFeedbackModal(PhonemeScore ph, String word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final color = AppTheme.getScoreColor(ph.score);
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color),
                    ),
                    child: Text(
                      '/${ph.phoneme}/',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Na palavra "$word"',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Precisão: ${ph.score.toStringAsFixed(0)}%',
                          style: TextStyle(color: color, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              if (ph.articulationTip != null) ...[
                const Text(
                  'Instrução Mecânica Articulatória:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                Text(
                  ph.articulationTip!,
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
                ),
              ] else ...[
                const Text(
                  'Dica de Pronúncia:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Ouça o modelo de referência em velocidade reduzida e tente imitar a vibração e o ponto de apoio da língua.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK, entendi', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prática de Fala'),
        actions: [
          IconButton(
            icon: const Icon(Icons.skip_next),
            tooltip: 'Próxima Frase',
            onPressed: _nextSentence,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Seletor de Pronúncia
              const PronunciationTypeSelector(),
              const SizedBox(height: 16),

              // Card da Frase Alvo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.surfaceLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      _currentSentence['text']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<PronunciationType>(
                      valueListenable: PreferencesService.instance.pronunciationTypeNotifier,
                      builder: (context, currentType, _) {
                        final isAportuguesada = currentType == PronunciationType.portugueseGuide;
                        final guideText = isAportuguesada
                            ? PortuguesePhoneticService.getGuideForSentence(_currentSentence['text']!)
                            : _currentSentence['ipa']!;
                        return Text(
                          guideText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isAportuguesada ? AppTheme.accent : AppTheme.primary,
                            fontFamily: isAportuguesada ? null : 'monospace',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _currentSentence['translation']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isPlayingNative ? AppTheme.accent : AppTheme.primary,
                            ),
                            backgroundColor: _isPlayingNative
                                ? AppTheme.primary.withValues(alpha: 0.15)
                                : null,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _playReferenceAudio(slow: false),
                          icon: Icon(
                            _isPlayingNative ? Icons.stop_circle_rounded : Icons.volume_up,
                            size: 18,
                            color: AppTheme.primary,
                          ),
                          label: Text(
                            _isPlayingNative ? 'Parar' : 'Ouvir Nativo (1x)',
                            style: const TextStyle(color: AppTheme.primary),
                          ),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _isPlayingSlow ? AppTheme.accent : AppTheme.surfaceLight,
                            ),
                            backgroundColor: _isPlayingSlow
                                ? AppTheme.accent.withValues(alpha: 0.15)
                                : null,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _playReferenceAudio(slow: true),
                          icon: Icon(
                            _isPlayingSlow ? Icons.stop_circle_rounded : Icons.slow_motion_video,
                            size: 18,
                            color: _isPlayingSlow ? AppTheme.accent : null,
                          ),
                          label: Text(
                            _isPlayingSlow ? 'Parar' : 'Lento (0.75x)',
                            style: TextStyle(
                              color: _isPlayingSlow ? AppTheme.accent : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              if (_isAnalyzing) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.primary),
                      SizedBox(height: 16),
                      Text(
                        'Avaliando precisão fonética e entonação...',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ] else if (_lastResult != null) ...[
                _buildResultSection(_lastResult!),
              ],

              const SizedBox(height: 24),

              // Visualizador de onda em tempo real
              if (_audioService.isRecording) ...[
                StreamBuilder<double>(
                  stream: _audioService.liveAmplitudeStream,
                  builder: (context, snapshot) {
                    final amp = snapshot.data ?? 0.1;
                    return Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(15, (index) {
                          final h = (sin((index + amp * 10)) * 20 + 25) * amp;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: 4,
                            height: max(6.0, h),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Text(
                  'Fale agora... Toque para finalizar',
                  style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                ),
              ],

              const SizedBox(height: 20),

              // Botão Principal de Gravação
              GestureDetector(
                onTap: _isAnalyzing ? null : _toggleRecording,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final isRec = _audioService.isRecording;
                    final scale = isRec ? _pulseAnimation.value : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: isRec
                                ? [AppTheme.scoreRed, const Color(0xFFDC2626)]
                                : [AppTheme.primary, AppTheme.accent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isRec ? AppTheme.scoreRed : AppTheme.primary).withValues(alpha: 0.5),
                              blurRadius: isRec ? 25 : 15,
                              spreadRadius: isRec ? 4 : 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          isRec ? Icons.stop : Icons.mic,
                          color: Colors.white,
                          size: 38,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),
              Text(
                _audioService.isRecording ? 'Gravando Áudio...' : 'Toque no microfone e fale',
                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultSection(PronunciationResult result) {
    final scoreColor = AppTheme.getScoreColor(result.overallScore);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scoreColor, width: 4),
                  color: scoreColor.withValues(alpha: 0.1),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${result.overallScore.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.overallScore >= 80
                        ? 'Excelente Pronúncia! 🎉'
                        : result.overallScore >= 60
                            ? 'Boa tentativa! 👍'
                            : 'Pratique mais um pouco! 💪',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Fluência: ${result.fluencyScore.toStringAsFixed(0)}%  •  Precisão: ${result.accuracyScore.toStringAsFixed(0)}%',
                    style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 30, color: AppTheme.surfaceLight),

          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Detalhamento por Palavra e Fonema (Toque para dicas):',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 12,
            runSpacing: 14,
            children: result.words.map((w) {
              final wColor = AppTheme.getScoreColor(w.score);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: wColor.withValues(alpha: 0.4)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      w.word,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: wColor,
                      ),
                    ),
                    ValueListenableBuilder<PronunciationType>(
                      valueListenable: PreferencesService.instance.pronunciationTypeNotifier,
                      builder: (context, currentType, _) {
                        final isAportuguesada = currentType == PronunciationType.portugueseGuide;
                        final guide = isAportuguesada
                            ? (w.portugueseGuide ?? PortuguesePhoneticService.getGuideForWord(w.word))
                            : (w.ipa.isNotEmpty ? w.ipa : '/${w.word}/');
                        return Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 4),
                          child: Text(
                            guide,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isAportuguesada ? AppTheme.accent : AppTheme.primary,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: w.phonemes.map((ph) {
                        final phColor = AppTheme.getScoreColor(ph.score);
                        return GestureDetector(
                          onTap: () => _showPhonemeFeedbackModal(ph, w.word),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                            decoration: BoxDecoration(
                              color: phColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: phColor, width: 1),
                            ),
                            child: Text(
                              ph.phoneme,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: phColor,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 18),

          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _audioService.playRecordedAudio(),
            icon: const Icon(Icons.play_circle_fill, size: 18, color: AppTheme.primary),
            label: const Text('Ouvir Sua Gravação', style: TextStyle(color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}
