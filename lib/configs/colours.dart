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
      isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2);
  static Color get appBarColor => 
      isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0);
  static Color get cardColor => 
      isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5);
  static Color get borderColor => 
      isDarkMode ? const Color(0xFF2C2C2C) : const Color(0xFFBDBDBD);
  static Color get dividerColor => 
      isDarkMode ? const Color(0xFF888888) : const Color(0xFFB0B0B0);
  static Color get textColorLight => 
      isDarkMode ? Colors.white : const Color(0xFF212121);
  static Color get textColorDark => 
      isDarkMode ? Colors.white70 : const Color(0xFF424242);
  static Color get warningColor => const Color(0xFFB71C1C);

  static void toggleTheme(bool darkMode) async {
    isDarkMode = darkMode;
    await saveThemePreference(darkMode);
  }
}
