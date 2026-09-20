// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_preference_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ThemePreferenceModelAdapter extends TypeAdapter<ThemePreferenceModel> {
  @override
  final int typeId = 5;

  @override
  ThemePreferenceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ThemePreferenceModel(
      themeId: fields[0] as String,
      mode: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ThemePreferenceModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.themeId)
      ..writeByte(1)
      ..write(obj.mode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemePreferenceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
