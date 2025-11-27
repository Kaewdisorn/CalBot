// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemeSettingsAdapter extends TypeAdapter<ThemeSettings> {
  @override
  final int typeId = 0;

  @override
  ThemeSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemeSettings(
      themeModeIndex: fields[0] as int?,
      seedColorValue: fields[1] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ThemeSettings obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.themeModeIndex)
      ..writeByte(1)
      ..write(obj.seedColorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
