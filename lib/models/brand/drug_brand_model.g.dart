// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drug_brand_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DrugBrandModelAdapter extends TypeAdapter<DrugBrandModel> {
  @override
  final int typeId = 0;

  @override
  DrugBrandModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrugBrandModel(
      brand_id: fields[0] as int,
      brand_name: fields[1] as String,
      generic_id: fields[2] as int,
      company_id: fields[3] as int,
      form: fields[4] as String?,
      strength: fields[5] as String?,
      price: fields[6] as String?,
      packsize: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DrugBrandModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.brand_id)
      ..writeByte(1)
      ..write(obj.brand_name)
      ..writeByte(2)
      ..write(obj.generic_id)
      ..writeByte(3)
      ..write(obj.company_id)
      ..writeByte(4)
      ..write(obj.form)
      ..writeByte(5)
      ..write(obj.strength)
      ..writeByte(6)
      ..write(obj.price)
      ..writeByte(7)
      ..write(obj.packsize);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrugBrandModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
