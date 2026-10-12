import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class AudioService {
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  bool _isRecording = false;
  String? _lastRecordedPath;
  Uint8List? _lastRecordedBytes;

  bool get isRecording => _isRecording;
  bool get isPlaying => _player.playing;
  String? get lastRecordedPath => _lastRecordedPath;
  Uint8List? get lastRecordedBytes => _lastRecordedBytes;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;

  /// Stream com a amplitude em tempo real do microfone (dB) para renderizar a onda sonora
  Stream<double> get liveAmplitudeStream {
    return Stream.periodic(const Duration(milliseconds: 60)).asyncMap((_) async {
      if (!_isRecording) return 0.0;
      try {
        final amp = await _recorder.getAmplitude();
        // Converte o valor de dB (-60 a 0) em um fator normalizado de 0.0 a 1.0
        final current = amp.current;
        if (current <= -60.0) return 0.05;
        if (current >= 0.0) return 1.0;
        return (current + 60.0) / 60.0;
      } catch (_) {
        return 0.1;
      }
    });
  }

  /// Verifica e solicita permissão de gravação
  Future<bool> hasPermission() async {
    if (kIsWeb) {
      return await _recorder.hasPermission();
    }
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  /// Inicia a gravação em formato WAV (PCM 16-bit, 16000Hz, Mono)
  Future<void> startRecording() async {
    if (_isRecording) return;
    final permitted = await hasPermission();
    if (!permitted) {
      throw Exception('Permissão de microfone não concedida.');
    }

    String? path;
    if (!kIsWeb) {
      final tempDir = await getTemporaryDirectory();
      path = '${tempDir.path}/user_pronunciation_${DateTime.now().millisecondsSinceEpoch}.wav';
    }

    // Configuração idêntica aos padrões de reconhecimento de fala
    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      bitRate: 256000,
      numChannels: 1,
    );

    if (kIsWeb) {
      await _recorder.start(config, path: '');
    } else {
      await _recorder.start(config, path: path!);
    }

    _isRecording = true;
    _lastRecordedPath = path;
  }

  /// Finaliza a gravação e extrai os bytes
  Future<Uint8List?> stopRecording() async {
    if (!_isRecording) return null;
    final path = await _recorder.stop();
    _isRecording = false;

    if (path != null) {
      _lastRecordedPath = path;
      if (!kIsWeb) {
        final file = File(path);
        if (await file.exists()) {
          _lastRecordedBytes = await file.readAsBytes();
          return _lastRecordedBytes;
        }
      }
    }
    return null;
  }

  /// Reproduz áudio a partir de um arquivo local gravado
  Future<void> playRecordedAudio() async {
    if (_lastRecordedPath == null) return;
    try {
      await _player.stop();
      if (kIsWeb && _lastRecordedPath != null) {
        await _player.setUrl(_lastRecordedPath!);
      } else if (_lastRecordedPath != null) {
        await _player.setFilePath(_lastRecordedPath!);
      }
      await _player.play();
    } catch (e) {
      debugPrint('Erro ao reproduzir gravação: $e');
    }
  }

  /// Reproduz modelo de voz nativo a partir de uma URL ou Asset
  Future<void> playReferenceAudio(String urlOrAsset, {double speed = 1.0}) async {
    try {
      await _player.stop();
      await _player.setSpeed(speed);
      if (urlOrAsset.startsWith('http://') || urlOrAsset.startsWith('https://')) {
        await _player.setUrl(urlOrAsset);
      } else {
        await _player.setAsset(urlOrAsset);
      }
      await _player.play();
    } catch (e) {
      debugPrint('Erro ao reproduzir modelo nativo: $e');
    }
  }

  Future<void> stopPlayback() async {
    await _player.stop();
  }

  void dispose() {
    _recorder.dispose();
    _player.dispose();
  }
}
