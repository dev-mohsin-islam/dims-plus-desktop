import 'package:hive/hive.dart';

part 'therapeutic_class_generic_index_model.g.dart';

@HiveType(typeId: 7) // ⚠️ Ensure this typeId is unique
class TherapeuticClassGenericIndexModel {

  @HiveField(0)
  int generic_id;

  @HiveField(1)
  int therapitic_id; // spelling from JSON

  TherapeuticClassGenericIndexModel({
    required this.generic_id,
    required this.therapitic_id,
  });

  // ✅ Safe fromJson
  factory TherapeuticClassGenericIndexModel.fromJson(Map<String, dynamic> json) {
    return TherapeuticClassGenericIndexModel(
      generic_id: json['generic_id'] is int
          ? json['generic_id']
          : int.tryParse(json['generic_id']?.toString() ?? '0') ?? 0,

      therapitic_id: json['therapitic_id'] is int
          ? json['therapitic_id']
          : int.tryParse(json['therapitic_id']?.toString() ?? '0') ?? 0,
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'generic_id': generic_id,
      'therapitic_id': therapitic_id,
    };
  }
}