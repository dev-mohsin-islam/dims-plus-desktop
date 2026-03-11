// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'speciality_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpecialityModelAdapter extends TypeAdapter<SpecialityModel> {
  @override
  final int typeId = 14;

  @override
  SpecialityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SpecialityModel(
      id: fields[0] as int,
      specialty: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SpecialityModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.specialty);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpecialityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
