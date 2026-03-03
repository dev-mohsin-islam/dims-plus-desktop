import 'package:hive/hive.dart';

part 'systemic_class_model.g.dart';

@HiveType(typeId: 6) // ⚠️ Make sure this typeId is unique
class SystemicClassModel {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int? parent_id;

  SystemicClassModel({
    required this.id,
    required this.name,
    this.parent_id,
  });

  // ✅ fromJson (safe parsing)
  factory SystemicClassModel.fromJson(Map<String, dynamic> json) {
    return SystemicClassModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      name: json['name']?.toString() ?? '',

      parent_id: json['parent_id'] is int
          ? json['parent_id']
          : int.tryParse(json['parent_id']?.toString() ?? ''),
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parent_id': parent_id,
    };
  }
}