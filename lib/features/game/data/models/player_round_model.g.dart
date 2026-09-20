// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_round_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerRoundModelAdapter extends TypeAdapter<PlayerRoundModel> {
  @override
  final int typeId = 2;

  @override
  PlayerRoundModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerRoundModel(
      playerId: fields[0] as String,
      score: fields[1] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerRoundModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.playerId)
      ..writeByte(1)
      ..write(obj.score);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerRoundModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
