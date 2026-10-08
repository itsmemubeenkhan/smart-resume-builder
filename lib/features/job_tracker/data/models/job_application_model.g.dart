// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class JobApplicationModelAdapter extends TypeAdapter<JobApplicationModel> {
  @override
  final int typeId = 0;

  @override
  JobApplicationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return JobApplicationModel(
      id: fields[0] as String,
      company: fields[1] as String,
      position: fields[2] as String,
      location: fields[3] as String,
      dateApplied: fields[4] as DateTime,
      status: fields[5] as String,
      notes: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, JobApplicationModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.company)
      ..writeByte(2)
      ..write(obj.position)
      ..writeByte(3)
      ..write(obj.location)
      ..writeByte(4)
      ..write(obj.dateApplied)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JobApplicationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
