// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inspiration.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InspirationAdapter extends TypeAdapter<Inspiration> {
  @override
  final int typeId = 0;

  @override
  Inspiration read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Inspiration(
      id: fields[0] as String?,
      content: fields[1] as String,
      createdAt: fields[2] as DateTime?,
      tags: (fields[3] as List).cast<String>(),
      imagePath: fields[4] as String?,
      isArchived: fields[5] as bool,
      mood: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Inspiration obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.tags)
      ..writeByte(4)
      ..write(obj.imagePath)
      ..writeByte(5)
      ..write(obj.isArchived)
      ..writeByte(6)
      ..write(obj.mood);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InspirationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
