import 'package:flutter/material.dart';

class ThemeController {
  final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  void toggleDarkMode(bool enable) {
    themeMode.value = enable ? ThemeMode.dark : ThemeMode.light;
  }

  bool get isDark => themeMode.value == ThemeMode.dark;
}

// ✅ Declare ONE global instance OUTSIDE the class
final themeController = ThemeController();
