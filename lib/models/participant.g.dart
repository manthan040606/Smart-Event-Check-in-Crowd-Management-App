// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'participant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ParticipantAdapter extends TypeAdapter<Participant> {
  @override
  final int typeId = 0;

  @override
  Participant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Participant(
      id: fields[0] as String,
      name: fields[1] as String,
      checkInTime: fields[2] as DateTime?,
      isCheckedIn: fields[3] as bool,
      isSynced: fields[4] as bool,
      email: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Participant obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.checkInTime)
      ..writeByte(3)
      ..write(obj.isCheckedIn)
      ..writeByte(4)
      ..write(obj.isSynced)
      ..writeByte(5)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParticipantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
