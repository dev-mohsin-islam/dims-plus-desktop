// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generic_details_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GenericDetailsModelAdapter extends TypeAdapter<GenericDetailsModel> {
  @override
  final int typeId = 2;

  @override
  GenericDetailsModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GenericDetailsModel(
      generic_id: fields[0] as int,
      generic_name: fields[1] as String,
      precaution: fields[2] as String?,
      indication: fields[3] as String?,
      contra_indication: fields[4] as String?,
      dose: fields[5] as String?,
      side_effect: fields[6] as String?,
      pregnancy_category_id: fields[7] as int?,
      mode_of_action: fields[8] as String?,
      interaction: fields[9] as String?,
      pregnancy_category_note: fields[10] as String?,
      adult_dose: fields[11] as String?,
      child_dose: fields[12] as String?,
      renal_dose: fields[13] as String?,
      administration: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GenericDetailsModel obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.generic_id)
      ..writeByte(1)
      ..write(obj.generic_name)
      ..writeByte(2)
      ..write(obj.precaution)
      ..writeByte(3)
      ..write(obj.indication)
      ..writeByte(4)
      ..write(obj.contra_indication)
      ..writeByte(5)
      ..write(obj.dose)
      ..writeByte(6)
      ..write(obj.side_effect)
      ..writeByte(7)
      ..write(obj.pregnancy_category_id)
      ..writeByte(8)
      ..write(obj.mode_of_action)
      ..writeByte(9)
      ..write(obj.interaction)
      ..writeByte(10)
      ..write(obj.pregnancy_category_note)
      ..writeByte(11)
      ..write(obj.adult_dose)
      ..writeByte(12)
      ..write(obj.child_dose)
      ..writeByte(13)
      ..write(obj.renal_dose)
      ..writeByte(14)
      ..write(obj.administration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GenericDetailsModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
