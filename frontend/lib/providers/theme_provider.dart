import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings {
  final ThemeMode mode;
  final Color? seedColor; // nullable

  ThemeSettings({required this.mode, this.seedColor});

  ThemeSettings copyWith({ThemeMode? mode, Color? seedColor}) {
    return ThemeSettings(mode: mode ?? this.mode, seedColor: seedColor ?? this.seedColor);
  }
}

class ThemeNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    // default theme while loading saved prefs
    return ThemeSettings(mode: ThemeMode.system, seedColor: null);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    // Load theme mode
    final modeString = prefs.getString("theme_mode") ?? "system";
    final mode = _parseThemeMode(modeString);

    // Load seedColor if exists
    final colorValue = prefs.getInt("theme_seed_color");

    state = ThemeSettings(mode: mode, seedColor: colorValue != null ? Color(colorValue) : null);
  }

  ThemeMode _parseThemeMode(String str) {
    switch (str) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("theme_seed_color", color.toARGB32()); // still works
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("theme_mode", mode.name);
  }

  Future<void> resetToDefault() async {
    state = ThemeSettings(mode: ThemeMode.system, seedColor: null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("theme_mode");
    await prefs.remove("theme_seed_color");
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(() => ThemeNotifier());
