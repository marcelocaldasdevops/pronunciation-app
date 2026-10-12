class PhoneticGuideEntry {
  final String word;
  final String ipa;
  final String portugueseGuide;
  final String? phoneticTip;

  const PhoneticGuideEntry({
    required this.word,
    required this.ipa,
    required this.portugueseGuide,
    this.phoneticTip,
  });
}

class PortuguesePhoneticService {
  static const Map<String, PhoneticGuideEntry> _dictionary = {
    'i': PhoneticGuideEntry(
      word: 'i',
      ipa: '/aɪ/',
      portugueseGuide: 'ai',
      phoneticTip: 'Ditongo aberto como o "ai" em "pai".',
    ),
    'think': PhoneticGuideEntry(
      word: 'think',
      ipa: '/θɪŋk/',
      portugueseGuide: 'zínk',
      phoneticTip: 'Língua entre os dentes soprando o ar, soando perto de um "z/s" suave.',
    ),
    'learning': PhoneticGuideEntry(
      word: 'learning',
      ipa: '/ˈlɜːrnɪŋ/',
      portugueseGuide: 'lêr-nin',
      phoneticTip: 'O "r" é puxado na garganta e o "g" final quase não soa.',
    ),
    'pronunciation': PhoneticGuideEntry(
      word: 'pronunciation',
      ipa: '/prəˌnʌnsiˈeɪʃən/',
      portugueseGuide: 'prô-nan-si-éi-chan',
      phoneticTip: 'Atenção na sílaba tônica "éi" e terminação suave "chan".',
    ),
    'is': PhoneticGuideEntry(
      word: 'is',
      ipa: '/ɪz/',
      portugueseGuide: 'iz',
      phoneticTip: 'Som de "i" curto e "z" vozeado.',
    ),
    'fun': PhoneticGuideEntry(
      word: 'fun',
      ipa: '/fʌn/',
      portugueseGuide: 'fân',
      phoneticTip: 'Vogal relaxada próxima de um "ã" suave.',
    ),
    'practice': PhoneticGuideEntry(
      word: 'practice',
      ipa: '/ˈpræktɪs/',
      portugueseGuide: 'prék-tis',
      phoneticTip: 'O "a" tem som entre "é" e "á", boca aberta na vertical.',
    ),
    'makes': PhoneticGuideEntry(
      word: 'makes',
      ipa: '/meɪks/',
      portugueseGuide: 'mêiks',
      phoneticTip: 'Ditongo fechado com "k" seco.',
    ),
    'perfect': PhoneticGuideEntry(
      word: 'perfect',
      ipa: '/ˈpɜːrfɪkt/',
      portugueseGuide: 'pêr-fikt',
      phoneticTip: 'Primeira sílaba tônica "pêr" e "t" final seco sem adicionar "i".',
    ),
    'thank': PhoneticGuideEntry(
      word: 'thank',
      ipa: '/θæŋk/',
      portugueseGuide: 'zênk',
      phoneticTip: 'Língua entre os dentes soprada, "a" aberto.',
    ),
    'you': PhoneticGuideEntry(
      word: 'you',
      ipa: '/juː/',
      portugueseGuide: 'iú',
      phoneticTip: 'Semelhante a "iú", lábios arredondados no final.',
    ),
    'for': PhoneticGuideEntry(
      word: 'for',
      ipa: '/fɔːr/',
      portugueseGuide: 'fór',
      phoneticTip: 'Vogal "ó" aberta com "r" retroflexo americano.',
    ),
    'your': PhoneticGuideEntry(
      word: 'your',
      ipa: '/jɔːr/',
      portugueseGuide: 'iór',
      phoneticTip: 'Semelhante a "iór" curto.',
    ),
    'valuable': PhoneticGuideEntry(
      word: 'valuable',
      ipa: '/ˈvæljuəbəl/',
      portugueseGuide: 'vé-liu-bou',
      phoneticTip: 'O final "-ble" soa como "bou" no português.',
    ),
    'feedback': PhoneticGuideEntry(
      word: 'feedback',
      ipa: '/ˈfiːdbæk/',
      portugueseGuide: 'fíd-bék',
      phoneticTip: 'O primeiro "ee" é longo ("fíd") e o segundo "a" soa "bék".',
    ),
    'the': PhoneticGuideEntry(
      word: 'the',
      ipa: '/ðə/',
      portugueseGuide: 'dâ',
      phoneticTip: 'Língua nos dentes vibrando a voz, soando como um "d" suave com vogal neutra.',
    ),
    'quick': PhoneticGuideEntry(
      word: 'quick',
      ipa: '/kwɪk/',
      portugueseGuide: 'kuík',
      phoneticTip: 'Som rápido de "kuík" com "k" sem eco.',
    ),
    'brown': PhoneticGuideEntry(
      word: 'brown',
      ipa: '/braʊn/',
      portugueseGuide: 'bráun',
      phoneticTip: 'Ditongo "áu" seguido de "n".',
    ),
    'fox': PhoneticGuideEntry(
      word: 'fox',
      ipa: '/fɒks/',
      portugueseGuide: 'fóks',
      phoneticTip: 'Vogal "ó" aberta e som final de "ks".',
    ),
    'jumps': PhoneticGuideEntry(
      word: 'jumps',
      ipa: '/dʒʌmps/',
      portugueseGuide: 'djâmps',
      phoneticTip: '"dj" articulado com lábios arredondados.',
    ),
    'over': PhoneticGuideEntry(
      word: 'over',
      ipa: '/ˈoʊvər/',
      portugueseGuide: 'óu-ver',
      phoneticTip: 'Ditongo "óu" com "v" vozeado vibrante.',
    ),
    'lazy': PhoneticGuideEntry(
      word: 'lazy',
      ipa: '/ˈleɪzi/',
      portugueseGuide: 'léi-zi',
      phoneticTip: 'Primeira sílaba tônica "léi" e final "zi".',
    ),
    'dog': PhoneticGuideEntry(
      word: 'dog',
      ipa: '/dɔːɡ/',
      portugueseGuide: 'dóg',
      phoneticTip: 'Vogal "ó" aberta e "g" sem vogal de apoio no fim.',
    ),
    'water': PhoneticGuideEntry(
      word: 'water',
      ipa: '/ˈwɔːtər/',
      portugueseGuide: 'uá-der',
      phoneticTip: 'No inglês americano o "t" vira som de "r" suave como em "arara" (flap T).',
    ),
    'hello': PhoneticGuideEntry(
      word: 'hello',
      ipa: '/həˈloʊ/',
      portugueseGuide: 're-lóu',
      phoneticTip: 'O "h" é aspirado, soando como o "r" carioca em "rato".',
    ),
    'world': PhoneticGuideEntry(
      word: 'world',
      ipa: '/wɜːrld/',
      portugueseGuide: 'uârld',
      phoneticTip: 'Transição suave de "u" para o "r" retroflexo terminando em "ld".',
    ),
    'english': PhoneticGuideEntry(
      word: 'english',
      ipa: '/ˈɪŋɡlɪʃ/',
      portugueseGuide: 'ín-glish',
      phoneticTip: 'O final "-sh" soa exatamente como o "ch" de "chave".',
    ),
    'today': PhoneticGuideEntry(
      word: 'today',
      ipa: '/təˈdeɪ/',
      portugueseGuide: 'tu-déi',
      phoneticTip: 'Primeira sílaba rápida e tônica no "déi".',
    ),
    'people': PhoneticGuideEntry(
      word: 'people',
      ipa: '/ˈpiːpəl/',
      portugueseGuide: 'pí-pou',
      phoneticTip: 'Final "-ple" soa como "pou".',
    ),
    'time': PhoneticGuideEntry(
      word: 'time',
      ipa: '/taɪm/',
      portugueseGuide: 'táim',
      phoneticTip: 'Feche os lábios no final com "m", sem adicionar "i".',
    ),
    'good': PhoneticGuideEntry(
      word: 'good',
      ipa: '/ɡʊd/',
      portugueseGuide: 'gúd',
      phoneticTip: 'Som de "u" relaxado, "d" seco.',
    ),
    'morning': PhoneticGuideEntry(
      word: 'morning',
      ipa: '/ˈmɔːrnɪŋ/',
      portugueseGuide: 'mór-nin',
      phoneticTip: 'Tônica na primeira sílaba com "r" aspirado.',
    ),
    'coffee': PhoneticGuideEntry(
      word: 'coffee',
      ipa: '/ˈkɒfi/',
      portugueseGuide: 'kó-fi',
      phoneticTip: 'Primeira sílaba com "ó" aberto.',
    ),
    'friend': PhoneticGuideEntry(
      word: 'friend',
      ipa: '/frɛnd/',
      portugueseGuide: 'frênd',
      phoneticTip: 'Vogal "e" nasalada antes de "nd".',
    ),
    'because': PhoneticGuideEntry(
      word: 'because',
      ipa: '/bɪˈkɒz/',
      portugueseGuide: 'bi-cóz',
      phoneticTip: 'Sílaba tônica em "cóz".',
    ),
    'comfortable': PhoneticGuideEntry(
      word: 'comfortable',
      ipa: '/ˈkʌmftərbəl/',
      portugueseGuide: 'kâmf-ter-bou',
      phoneticTip: 'Note que tem 3 sílabas principais faladas, não 4.',
    ),
    'schedule': PhoneticGuideEntry(
      word: 'schedule',
      ipa: '/ˈskɛdʒuːl/',
      portugueseGuide: 'ské-djul',
      phoneticTip: 'Som de "dj" suave no meio.',
    ),
  };

  /// Retorna a transcrição aportuguesada para uma palavra específica
  static String getGuideForWord(String word) {
    final clean = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    if (_dictionary.containsKey(clean)) {
      return _dictionary[clean]!.portugueseGuide;
    }
    return _generateHeuristicGuide(clean);
  }

  /// Retorna o fonema IPA para uma palavra específica
  static String getIpaForWord(String word) {
    final clean = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    if (_dictionary.containsKey(clean)) {
      return _dictionary[clean]!.ipa;
    }
    return '/$clean/';
  }

  /// Retorna a dica mecânica/articulatória se disponível
  static String? getTipForWord(String word) {
    final clean = word.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
    return _dictionary[clean]?.phoneticTip;
  }

  /// Transcreve uma frase inteira para o formato aportuguesado
  static String getGuideForSentence(String sentence) {
    final words = sentence.trim().split(RegExp(r'\s+'));
    return words.map(getGuideForWord).join(' ');
  }

  /// Transcreve uma frase inteira para o formato IPA
  static String getIpaForSentence(String sentence) {
    final words = sentence.trim().split(RegExp(r'\s+'));
    final ipas = words.map(getIpaForWord).map((ipa) => ipa.replaceAll('/', '')).join(' ');
    return '/$ipas/';
  }

  /// Algoritmo heurístico para gerar aproximações fonéticas em PT-BR
  /// para palavras em inglês não presentes no dicionário estático.
  static String _generateHeuristicGuide(String word) {
    if (word.isEmpty) return '';

    String s = word.toLowerCase();

    // Substituições fonológicas comuns inglês -> português
    s = s.replaceAll('tion', 'chan');
    s = s.replaceAll('sion', 'jan');
    s = s.replaceAll('ture', 'tcher');
    s = s.replaceAll('ght', 't');
    s = s.replaceAll('igh', 'ai');
    s = s.replaceAll('ph', 'f');
    s = s.replaceAll('th', 'z');
    s = s.replaceAll('sh', 'ch');
    s = s.replaceAll('ch', 'tch');
    s = s.replaceAll('ee', 'í');
    s = s.replaceAll('ea', 'í');
    s = s.replaceAll('oo', 'ú');
    s = s.replaceAll('ou', 'áu');
    s = s.replaceAll('ow', 'óu');
    s = s.replaceAll('ay', 'éi');
    s = s.replaceAll('ey', 'éi');
    s = s.replaceAll('ck', 'k');
    s = s.replaceAll('wh', 'u');
    s = s.replaceAll('wr', 'r');

    if (s.startsWith('w')) {
      s = 'u${s.substring(1)}';
    }

    if (s.endsWith('le') && s.length > 2) {
      s = '${s.substring(0, s.length - 2)}ou';
    } else if (s.endsWith('e') && s.length > 3) {
      // 'e' mudo final no inglês
      s = s.substring(0, s.length - 1);
    }

    // Separação silábica aproximada
    final buffer = StringBuffer();
    final vowels = 'aeiouáéíóúâêô';
    for (int i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      if (i < s.length - 1) {
        final currentIsVowel = vowels.contains(s[i]);
        final nextIsConsonant = !vowels.contains(s[i + 1]);
        if (currentIsVowel && nextIsConsonant && i < s.length - 2) {
          final afterNextIsVowel = vowels.contains(s[i + 2]);
          if (afterNextIsVowel) {
            buffer.write('-');
          }
        }
      }
    }

    return buffer.toString();
  }
}
