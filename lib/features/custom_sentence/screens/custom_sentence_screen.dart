import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/models/pronunciation_result.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/portuguese_phonetic_service.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/services/pronunciation_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/pronunciation_type_selector.dart';

enum SentenceScreenState {
  empty,
  typing,
  listening,
  recording,
  analyzing,
  result,
  error,
}

class CustomSentenceScreen extends StatefulWidget {
  const CustomSentenceScreen({super.key});

  @override
  State<CustomSentenceScreen> createState() => _CustomSentenceScreenState();
}

class _CustomSentenceScreenState extends State<CustomSentenceScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final AudioService _audioService = AudioService();
  final PronunciationServiceImpl _pronService = PronunciationServiceImpl();
  final FlutterTts _tts = FlutterTts();

  SentenceScreenState _screenState = SentenceScreenState.empty;
  String? _errorMessage;
  bool _isMicPermissionDenied = false;

  PronunciationResult? _result;
  Timer? _recordTimer;
  int _recordSeconds = 0;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final List<String> _quickSuggestions = const [
    'I think learning pronunciation is fun',
    'Practice makes perfect',
    'Water is essential for life',
    'Good morning, how are you today?',
  ];

  @override
  void initState() {
    super.initState();
    _initTts();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.22).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final text = _textController.text.trim();
    if (_screenState != SentenceScreenState.recording &&
        _screenState != SentenceScreenState.analyzing &&
        _screenState != SentenceScreenState.result) {
      setState(() {
        if (text.isEmpty) {
          _screenState = SentenceScreenState.empty;
        } else {
          _screenState = SentenceScreenState.typing;
        }
      });
    }
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.46);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);

    _tts.setStartHandler(() {
      if (mounted) {
        setState(() {
          _screenState = SentenceScreenState.listening;
        });
      }
    });

    _tts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _screenState = _result != null
              ? SentenceScreenState.result
              : (_textController.text.trim().isNotEmpty
                  ? SentenceScreenState.typing
                  : SentenceScreenState.empty);
        });
      }
    });

    _tts.setErrorHandler((msg) {
      if (mounted) {
        setState(() {
          _screenState = _textController.text.trim().isNotEmpty
              ? SentenceScreenState.typing
              : SentenceScreenState.empty;
        });
      }
    });
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _pulseController.dispose();
    _textController.dispose();
    _audioService.dispose();
    _tts.stop();
    super.dispose();
  }

  Future<void> _speakCurrentSentence() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      await _audioService.stopPlayback();
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro na síntese de voz: $e')),
      );
    }
  }

  Future<void> _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data != null && data.text != null && data.text!.isNotEmpty) {
        final text = data.text!.trim();
        _textController.text = text.length > 150 ? text.substring(0, 150) : text;
      }
    } catch (e) {
      debugPrint('Erro ao colar: $e');
    }
  }

  Future<void> _toggleRecording() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    if (_screenState == SentenceScreenState.recording) {
      // Finalizar gravação e analisar
      _recordTimer?.cancel();
      setState(() {
        _screenState = SentenceScreenState.analyzing;
        _errorMessage = null;
      });

      try {
        final bytes = await _audioService.stopRecording();
        if (bytes == null || bytes.isEmpty) {
          throw Exception('Nenhum áudio detectado. Fale próximo ao microfone.');
        }

        final result = await _pronService.evaluatePronunciation(
          audioBytes: bytes,
          referenceText: text,
        );

        if (!mounted) return;
        setState(() {
          _result = result;
          _screenState = SentenceScreenState.result;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _screenState = SentenceScreenState.error;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } else {
      // Iniciar gravação
      await _tts.stop();
      await _audioService.stopPlayback();

      final permitted = await _audioService.hasPermission();
      if (!permitted) {
        setState(() {
          _isMicPermissionDenied = true;
          _screenState = SentenceScreenState.error;
          _errorMessage =
              'Permissão de microfone negada. Conceda acesso nas configurações do sistema para avaliar sua pronúncia.';
        });
        return;
      }

      setState(() {
        _isMicPermissionDenied = false;
        _errorMessage = null;
        _result = null;
        _recordSeconds = 0;
      });

      try {
        await _audioService.startRecording();
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            _recordSeconds++;
          });
          // Limite máximo de segurança: 30 segundos
          if (_recordSeconds >= 30) {
            _toggleRecording();
          }
        });

        setState(() {
          _screenState = SentenceScreenState.recording;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _screenState = SentenceScreenState.error;
          _errorMessage = 'Falha ao iniciar microfone: $e';
        });
      }
    }
  }

  void _resetToNewSentence() {
    _recordTimer?.cancel();
    _tts.stop();
    _audioService.stopPlayback();
    setState(() {
      _textController.clear();
      _result = null;
      _errorMessage = null;
      _screenState = SentenceScreenState.empty;
      _recordSeconds = 0;
    });
  }

  void _tryAgain() {
    _recordTimer?.cancel();
    _tts.stop();
    _audioService.stopPlayback();
    setState(() {
      _result = null;
      _errorMessage = null;
      _screenState = SentenceScreenState.typing;
      _recordSeconds = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = _textController.text;
    final charCount = text.length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Treinar Minha Frase'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Seletor Global de Tipo de Pronúncia
              const PronunciationTypeSelector(),
              const SizedBox(height: 18),

              // Área de Entrada de Texto
              _buildTextInputCard(charCount),
              const SizedBox(height: 14),

              // Pré-visualização Fonética enquanto digita
              if (_screenState == SentenceScreenState.typing ||
                  _screenState == SentenceScreenState.listening)
                _buildPhoneticPreviewCard(),

              // Mensagem / Banner de Erro & Permissão
              if (_screenState == SentenceScreenState.error && _errorMessage != null)
                _buildErrorBanner(),

              // Área de Estados Interativos
              const SizedBox(height: 10),
              _buildStateContent(),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputCard(int charCount) {
    final isLocked = _screenState == SentenceScreenState.recording ||
        _screenState == SentenceScreenState.analyzing;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: charCount > 0
              ? AppTheme.primary.withValues(alpha: 0.5)
              : AppTheme.surfaceLight.withValues(alpha: 0.8),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: TextField(
              controller: _textController,
              enabled: !isLocked,
              maxLines: 3,
              maxLength: 150,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
              decoration: InputDecoration(
                hintText: 'Digite ou cole uma frase em inglês...\nEx: "Water is essential for life"',
                hintStyle: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                ),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
          Divider(
            height: 1,
            color: AppTheme.surfaceLight.withValues(alpha: 0.6),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: isLocked ? null : _pasteFromClipboard,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.content_paste_rounded,
                                size: 16, color: AppTheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Colar',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (charCount > 0 && !isLocked) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => _textController.clear(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.close_rounded,
                                  size: 16, color: AppTheme.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                'Limpar',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '$charCount/150',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: charCount >= 140
                        ? AppTheme.scoreYellow
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneticPreviewCard() {
    final text = _textController.text.trim();
    if (text.isEmpty) return const SizedBox.shrink();

    return ValueListenableBuilder<PronunciationType>(
      valueListenable: PreferencesService.instance.pronunciationTypeNotifier,
      builder: (context, currentType, _) {
        final isAportuguesada = currentType == PronunciationType.portugueseGuide;
        final guideText = isAportuguesada
            ? PortuguesePhoneticService.getGuideForSentence(text)
            : PortuguesePhoneticService.getIpaForSentence(text);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isAportuguesada
                  ? AppTheme.accent.withValues(alpha: 0.3)
                  : AppTheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isAportuguesada ? Icons.record_voice_over_rounded : Icons.menu_book_rounded,
                    size: 16,
                    color: isAportuguesada ? AppTheme.accent : AppTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAportuguesada ? 'Guia Fonético Aportuguesado:' : 'Transcrição IPA Prevista:',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isAportuguesada ? AppTheme.accent : AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                guideText,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.scoreRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.scoreRed.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: AppTheme.scoreRed, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _isMicPermissionDenied ? 'Permissão Necessária' : 'Atenção',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.scoreRed,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _errorMessage ?? '',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textPrimary,
              height: 1.3,
            ),
          ),
          if (_isMicPermissionDenied) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.scoreRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.settings_rounded, size: 16),
                label: const Text('Abrir Configurações do Sistema'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStateContent() {
    switch (_screenState) {
      case SentenceScreenState.empty:
        return _buildEmptyState();
      case SentenceScreenState.typing:
        return _buildActionButtons(isListening: false);
      case SentenceScreenState.listening:
        return _buildActionButtons(isListening: true);
      case SentenceScreenState.recording:
        return _buildRecordingState();
      case SentenceScreenState.analyzing:
        return _buildAnalyzingState();
      case SentenceScreenState.result:
        return _buildResultState();
      case SentenceScreenState.error:
        return _buildActionButtons(isListening: false);
    }
  }

  Widget _buildEmptyState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          'Sugestões rápidas para praticar:',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _quickSuggestions.map((suggestion) {
            return InkWell(
              onTap: () {
                _textController.text = suggestion;
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      suggestion,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActionButtons({required bool isListening}) {
    return Column(
      children: [
        Row(
          children: [
            // Botão Ouvir (TTS)
            Expanded(
              flex: 4,
              child: SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: isListening ? () => _tts.stop() : _speakCurrentSentence,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isListening ? AppTheme.accent : AppTheme.primary,
                      width: 1.5,
                    ),
                    backgroundColor: isListening
                        ? AppTheme.accent.withValues(alpha: 0.15)
                        : AppTheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: Icon(
                    isListening ? Icons.stop_circle_rounded : Icons.volume_up_rounded,
                    color: isListening ? AppTheme.accent : AppTheme.primary,
                    size: 22,
                  ),
                  label: Text(
                    isListening ? 'Ouvindo...' : 'Ouvir Modelo',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isListening ? AppTheme.accent : AppTheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Botão Gravar Voz
            Expanded(
              flex: 5,
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _toggleRecording,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.mic_rounded, size: 22),
                  label: Text(
                    'Gravar Minha Voz',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecordingState() {
    final minutes = (_recordSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordSeconds % 60).toString().padLeft(2, '0');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Gravando sua voz...',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Fale a frase pausadamente e com clareza',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // Botão pulsante de gravação com onda
          ScaleTransition(
            scale: _pulseAnimation,
            child: GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppTheme.scoreRed, Color(0xFFF97316)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.scoreRed.withValues(alpha: 0.4),
                      blurRadius: 18,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.stop_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            '$minutes:$seconds',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _toggleRecording,
            child: Text(
              'Toque para concluir análise',
              style: GoogleFonts.outfit(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.surfaceLight.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              color: AppTheme.primary,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Analisando precisão fonética...',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Comparando espectro acústico com referências nativas',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState() {
    if (_result == null) return const SizedBox.shrink();

    final scoreColor = AppTheme.getScoreColor(_result!.overallScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score Global Circular & Métricas
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: scoreColor.withValues(alpha: 0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: scoreColor.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result!.overallScore >= 80
                            ? 'Excelente pronúncia!'
                            : (_result!.overallScore >= 60
                                ? 'Boa pronúncia!'
                                : 'Precisa de ajustes'),
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Avaliação fonética concluída',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scoreColor.withValues(alpha: 0.15),
                      border: Border.all(color: scoreColor, width: 3),
                    ),
                    child: Center(
                      child: Text(
                        '${_result!.overallScore.round()}%',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Divider(
                height: 1,
                color: AppTheme.surfaceLight.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 14),

              // Métricas de Precisão, Fluência, Completude
              Row(
                children: [
                  Expanded(
                    child: _buildMetricItem(
                      'Precisão',
                      '${_result!.accuracyScore.round()}%',
                      AppTheme.getScoreColor(_result!.accuracyScore),
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Fluência',
                      '${_result!.fluencyScore.round()}%',
                      AppTheme.getScoreColor(_result!.fluencyScore),
                    ),
                  ),
                  Expanded(
                    child: _buildMetricItem(
                      'Completude',
                      '${_result!.completenessScore.round()}%',
                      AppTheme.getScoreColor(_result!.completenessScore),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Área de Feedback Por Palavra
        Text(
          'Feedback Palavra por Palavra:',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Toque em qualquer palavra para ver dicas articulatórias dos fonemas',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        ValueListenableBuilder<PronunciationType>(
          valueListenable: PreferencesService.instance.pronunciationTypeNotifier,
          builder: (context, currentType, _) {
            final isAportuguesada = currentType == PronunciationType.portugueseGuide;

            return Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _result!.words.map((wordScore) {
                final color = AppTheme.getScoreColor(wordScore.score);
                final guide = isAportuguesada
                    ? (wordScore.portugueseGuide ??
                        PortuguesePhoneticService.getGuideForWord(wordScore.word))
                    : (wordScore.ipa.isNotEmpty ? wordScore.ipa : '/${wordScore.word}/');

                return InkWell(
                  onTap: () => _showWordDetailsModal(wordScore, isAportuguesada),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.6)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              wordScore.word,
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          guide,
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isAportuguesada ? AppTheme.accent : AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 20),

        // Botões de Áudio (Ouvir Gravação vs Ouvir Modelo)
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _audioService.playRecordedAudio(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.8),
                  ),
                  backgroundColor: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.play_arrow_rounded, color: AppTheme.primary),
                label: Text(
                  'Minha Voz',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _speakCurrentSentence,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.8),
                  ),
                  backgroundColor: AppTheme.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.volume_up_rounded, color: AppTheme.accent),
                label: Text(
                  'Modelo Nativo',
                  style: GoogleFonts.outfit(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Botões de Ação Final (Tentar Novamente / Nova Frase)
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _tryAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.replay_rounded, size: 20),
                  label: Text(
                    'Tentar Novamente',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _resetToNewSentence,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_rounded,
                      color: AppTheme.primary, size: 20),
                  label: Text(
                    'Nova Frase',
                    style: GoogleFonts.outfit(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  void _showWordDetailsModal(WordScore wordScore, bool isAportuguesada) {
    final tip = PortuguesePhoneticService.getTipForWord(wordScore.word);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wordScore.word,
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isAportuguesada
                          ? (wordScore.portugueseGuide ??
                              PortuguesePhoneticService.getGuideForWord(wordScore.word))
                          : wordScore.ipa,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isAportuguesada ? AppTheme.accent : AppTheme.primary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.getScoreColor(wordScore.score).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppTheme.getScoreColor(wordScore.score),
                    ),
                  ),
                  child: Text(
                    '${wordScore.score.round()}%',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.getScoreColor(wordScore.score),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Fonemas Avaliados:',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: wordScore.phonemes.map((ph) {
                final phColor = AppTheme.getScoreColor(ph.score);
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: phColor.withValues(alpha: 0.6)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        ph.phoneme,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${ph.score.round()}%',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: phColor,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            if (tip != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.lightbulb_outline_rounded,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
