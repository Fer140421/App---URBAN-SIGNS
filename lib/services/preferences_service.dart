import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  static const _darkModeKey = 'dark_mode';
  static const _compactCardsKey = 'compact_cards';

  Future<bool> getDarkMode() async => await _prefs.getBool(_darkModeKey) ?? false;
  Future<void> setDarkMode(bool value) => _prefs.setBool(_darkModeKey, value);

  Future<bool> getCompactCards() async =>
      await _prefs.getBool(_compactCardsKey) ?? false;
  Future<void> setCompactCards(bool value) =>
      _prefs.setBool(_compactCardsKey, value);
}
