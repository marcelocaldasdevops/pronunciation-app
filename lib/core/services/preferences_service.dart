import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PronunciationType {
  standardIpa,
  portugueseGuide,
}

class PreferencesService {
  static const String _keyPronunciationType = 'pronunciation_type';
  static PreferencesService? _instance;
  static SharedPreferences? _prefs;

  final ValueNotifier<PronunciationType> pronunciationTypeNotifier =
      ValueNotifier<PronunciationType>(PronunciationType.standardIpa);

  PreferencesService._();

  static PreferencesService get instance {
    _instance ??= PreferencesService._();
    return _instance!;
  }

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedIndex = _prefs?.getInt(_keyPronunciationType);
    if (savedIndex != null &&
        savedIndex >= 0 &&
        savedIndex < PronunciationType.values.length) {
      instance.pronunciationTypeNotifier.value = PronunciationType.values[savedIndex];
    }
  }

  PronunciationType get pronunciationType => pronunciationTypeNotifier.value;

  Future<void> setPronunciationType(PronunciationType type) async {
    pronunciationTypeNotifier.value = type;
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    await prefs.setInt(_keyPronunciationType, type.index);
  }
}
