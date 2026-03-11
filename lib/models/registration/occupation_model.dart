import 'package:hive/hive.dart';

part 'occupation_model.g.dart';

@HiveType(typeId: 13)
class OccupationModel extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String name;

  OccupationModel({required this.id, required this.name});

  factory OccupationModel.fromJson(Map<String, dynamic> json) {
    return OccupationModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
