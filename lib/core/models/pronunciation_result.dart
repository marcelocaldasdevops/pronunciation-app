import 'dart:typed_data';

enum PhonemeStatus {
  correct,       // Score >= 80%
  acceptable,    // Score 60-79%
  poor,          // Score < 60%
  omitted,
  inserted,
}

class PhonemeScore {
  final String phoneme; // Símbolo IPA, ex: /θ/, /iː/, /æ/
  final double score;   // 0.0 a 100.0
  final PhonemeStatus status;
  final String? soundSubstitution; // Se o usuário falou outro fonema
  final String? articulationTip;   // Dica mecânica articulatória (língua, dentes, lábios)

  const PhonemeScore({
    required this.phoneme,
    required this.score,
    required this.status,
    this.soundSubstitution,
    this.articulationTip,
  });

  factory PhonemeScore.fromRaw({
    required String phoneme,
    required double score,
    String? substitution,
    String? tip,
  }) {
    PhonemeStatus status;
    if (score >= 80.0) {
      status = PhonemeStatus.correct;
    } else if (score >= 60.0) {
      status = PhonemeStatus.acceptable;
    } else {
      status = PhonemeStatus.poor;
    }

    return PhonemeScore(
      phoneme: phoneme,
      score: score,
      status: status,
      soundSubstitution: substitution,
      articulationTip: tip,
    );
  }
}

class WordScore {
  final String word;
  final String ipa;
  final double score;
  final List<PhonemeScore> phonemes;

  const WordScore({
    required this.word,
    required this.ipa,
    required this.score,
    required this.phonemes,
  });
}

class PronunciationResult {
  final double overallScore;      // 0 a 100
  final double accuracyScore;     // Precisão fonética
  final double fluencyScore;      // Fluência e pausas
  final double completenessScore; // Palavras omitidas vs lidas
  final double prosodyScore;      // Entonação e ritmo
  final String targetText;
  final String recognizedText;
  final List<WordScore> words;
  final Uint8List? recordedAudioBytes;
  final String? recordedAudioPath;

  const PronunciationResult({
    required this.overallScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    required this.prosodyScore,
    required this.targetText,
    required this.recognizedText,
    required this.words,
    this.recordedAudioBytes,
    this.recordedAudioPath,
  });
}
