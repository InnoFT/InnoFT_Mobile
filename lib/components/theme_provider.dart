import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(false); // По умолчанию светлая тема

  bool get isDarkTheme => state;

  void toggleTheme() {
    state = !state; // Меняем тему
  }
}

final themeNotifierProvider = StateNotifierProvider<ThemeNotifier, bool>(
  (ref) => ThemeNotifier(),
);
