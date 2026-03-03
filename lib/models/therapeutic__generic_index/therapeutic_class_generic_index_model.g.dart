// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'therapeutic_class_generic_index_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TherapeuticClassGenericIndexModelAdapter
    extends TypeAdapter<TherapeuticClassGenericIndexModel> {
  @override
  final int typeId = 7;

  @override
  TherapeuticClassGenericIndexModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TherapeuticClassGenericIndexModel(
      generic_id: fields[0] as int,
      therapitic_id: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TherapeuticClassGenericIndexModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.generic_id)
      ..writeByte(1)
      ..write(obj.therapitic_id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TherapeuticClassGenericIndexModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
