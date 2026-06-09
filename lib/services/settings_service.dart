import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static Future<void> setLang(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("lang", lang);
  }

  static Future<String> getLang() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("lang") ?? "fr";
  }
}
