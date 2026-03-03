import 'package:hive/hive.dart';

part 'pregnancy_category_model.g.dart';

@HiveType(typeId: 5) // ⚠️ Must be unique in your project
class PregnancyCategoryModel {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  PregnancyCategoryModel({
    required this.id,
    required this.name,
    this.description,
  });

  // ✅ fromJson (safe parsing)
  factory PregnancyCategoryModel.fromJson(Map<String, dynamic> json) {
    return PregnancyCategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      name: json['name']?.toString().trim() ?? '',

      description: json['description']?.toString(),
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
    };
  }
}