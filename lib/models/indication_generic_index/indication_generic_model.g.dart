// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'indication_generic_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IndicationGenericModelAdapter
    extends TypeAdapter<IndicationGenericModel> {
  @override
  final int typeId = 4;

  @override
  IndicationGenericModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IndicationGenericModel(
      generic_id: fields[0] as int,
      indication_id: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, IndicationGenericModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.generic_id)
      ..writeByte(1)
      ..write(obj.indication_id);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndicationGenericModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
