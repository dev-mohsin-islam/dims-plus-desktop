import 'package:hive/hive.dart';

part 'indication_model.g.dart';

@HiveType(typeId: 3) // ⚠️ Must be unique in your project
class IndicationModel {

  @HiveField(0)
  int id;

  @HiveField(1)
  String name;

  IndicationModel({
    required this.id,
    required this.name,
  });

  // ✅ fromJson (safe parsing)
  factory IndicationModel.fromJson(Map<String, dynamic> json) {
    return IndicationModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,

      name: json['name']?.toString() ?? '',
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}