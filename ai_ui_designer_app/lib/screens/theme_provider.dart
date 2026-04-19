import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;

  ThemeMode get currentTheme =>
      isDarkMode ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool value) {
    isDarkMode = value;
    notifyListeners();
  }
}