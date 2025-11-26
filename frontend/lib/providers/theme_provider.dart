import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings {
  final ThemeMode mode;
  final Color seedColor;

  ThemeSettings({required this.mode, required this.seedColor});

  ThemeSettings copyWith({ThemeMode? mode, Color? seedColor}) {
    return ThemeSettings(mode: mode ?? this.mode, seedColor: seedColor ?? this.seedColor);
  }
}

class ThemeNotifier extends Notifier<ThemeSettings> {
  @override
  ThemeSettings build() {
    _load();
    return ThemeSettings(mode: ThemeMode.system, seedColor: Colors.blue);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString("theme_mode");
    final colorValue = prefs.getInt("theme_seed_color");

    state = ThemeSettings(mode: _parseThemeMode(modeString), seedColor: colorValue != null ? Color(colorValue) : Colors.blue);
  }

  ThemeMode _parseThemeMode(String? s) {
    switch (s) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(mode: mode);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("theme_mode", mode.name);
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("theme_seed_color", color.value);
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(() => ThemeNotifier());
