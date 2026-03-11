import 'package:hive/hive.dart';

part 'speciality_model.g.dart';

@HiveType(typeId: 14)
class SpecialityModel extends HiveObject {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String specialty;

  SpecialityModel({required this.id, required this.specialty});

  factory SpecialityModel.fromJson(Map<String, dynamic> json) {
    return SpecialityModel(
      id: json['id'] ?? 0,
      specialty: json['specialty'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specialty': specialty,
    };
  }
}
