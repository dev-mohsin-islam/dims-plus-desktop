// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'systemic_class_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SystemicClassModelAdapter extends TypeAdapter<SystemicClassModel> {
  @override
  final int typeId = 6;

  @override
  SystemicClassModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SystemicClassModel(
      id: fields[0] as int,
      name: fields[1] as String,
      parent_id: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SystemicClassModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.parent_id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SystemicClassModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
