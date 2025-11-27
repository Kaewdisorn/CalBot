import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/theme_settings.dart';

final themeProvider = NotifierProvider<ThemeNotifier, ThemeSettings>(() {
  return ThemeNotifier();
});

class ThemeNotifier extends Notifier<ThemeSettings> {
  static const _boxName = 'settings';
  static const _key = 'theme';

  late Box<ThemeSettings> box;

  @override
  ThemeSettings build() {
    // Load Hive synchronously (box is already opened in main)
    box = Hive.box<ThemeSettings>(_boxName);

    final saved = box.get(_key);
    if (saved != null) {
      return saved;
    }

    // default
    final def = ThemeSettings();
    box.put(_key, def);
    return def;
  }

  Future<void> _save(ThemeSettings next) async {
    state = next;
    await box.put(_key, next);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _save(ThemeSettings(themeModeIndex: mode.index, seedColorValue: state.seedColor.toARGB32()));
  }

  Future<void> setSeedColor(Color color) async {
    await _save(ThemeSettings(themeModeIndex: state.mode.index, seedColorValue: color.toARGB32()));
  }

  Future<void> resetToDefault() async {
    await _save(ThemeSettings());
  }
}
