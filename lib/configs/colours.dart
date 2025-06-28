import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static bool isDarkMode = true;

  static Future<void> loadThemePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? true;
  }

  static Future<void> saveThemePreference(bool darkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', darkMode);
  }

  static Color get primaryColor =>
      isDarkMode ? const Color(0xFF242424) : const Color(0xFFF2F2F2);
  static Color get appBarColor =>
      isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
  static Color get cardColor =>
      isDarkMode ? const Color(0xFF323232) : const Color(0xFFF5F5F5);
  static Color get borderColor =>
      isDarkMode ? const Color(0xFF474747) : const Color(0xFFBDBDBD);
  static Color get dividerColor =>
      isDarkMode ? const Color(0xFFAAAAAA) : const Color(0xFFB0B0B0);
  static Color get textColorLight =>
      isDarkMode ? const Color(0xFFECECEC) : const Color(0xFF212121);
  static Color get textColorDark =>
      isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF424242);
  static Color get warningColor => const Color(0xFFB71C1C);
  static Color get missingHealth => isDarkMode
      ? const Color(0xFF581B10)
      : const Color(0xFF8B3C2B);
  static Color get currentHealth =>
      isDarkMode ? const Color(0xFF1B6533) : const Color(0xFF2E8B57);
  static Color get tempHealth => const Color(0xFF1976D2);

  static void toggleTheme(bool darkMode) async {
    isDarkMode = darkMode;
    await saveThemePreference(darkMode);
  }
}
