import 'package:hive/hive.dart';

part 'therapeutic_class_model.g.dart';

@HiveType(typeId: 8) // ⚠️ Must be unique in your project
class TherapeuticClassModel {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int systemic_class_id;

  TherapeuticClassModel({
    required this.id,
    required this.name,
    required this.systemic_class_id,
  });

  // ✅ fromJson (safe parsing)
  factory TherapeuticClassModel.fromJson(Map<String, dynamic> json) {
    return TherapeuticClassModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      name: json['name']?.toString() ?? '',

      systemic_class_id: json['systemic_class_id'] is int
          ? json['systemic_class_id']
          : int.tryParse(json['systemic_class_id']?.toString() ?? '0') ?? 0,
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'systemic_class_id': systemic_class_id,
    };
  }
}