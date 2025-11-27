import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'theme_settings.g.dart';

@HiveType(typeId: 0)
class ThemeSettings extends HiveObject {
  // Store ThemeMode as int
  @HiveField(0)
  int themeModeIndex;

  // Store Color as int
  @HiveField(1)
  int seedColorValue;

  // Hive-friendly constructor: optional named args with defaults
  ThemeSettings({int? themeModeIndex, int? seedColorValue})
    : themeModeIndex = themeModeIndex ?? ThemeMode.system.index,
      seedColorValue = seedColorValue ?? Colors.blue.toARGB32();

  // Convenience getters/setters
  ThemeMode get mode => ThemeMode.values[themeModeIndex];
  set mode(ThemeMode m) => themeModeIndex = m.index;

  Color get seedColor => Color(seedColorValue);
  set seedColor(Color color) => seedColorValue = color.toARGB32();
}
