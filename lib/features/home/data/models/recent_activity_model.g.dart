// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RecentActivityModelAdapter extends TypeAdapter<RecentActivityModel> {
  @override
  final int typeId = 2;

  @override
  RecentActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RecentActivityModel(
      title: fields[0] as String,
      subtitle: fields[1] as String,
      iconCode: fields[2] as int,
      colorValue: fields[3] as int,
      timestamp: fields[4] as DateTime,
      targetRoute: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, RecentActivityModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.subtitle)
      ..writeByte(2)
      ..write(obj.iconCode)
      ..writeByte(3)
      ..write(obj.colorValue)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.targetRoute);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecentActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
