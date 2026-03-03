import 'package:hive/hive.dart';

part 'indication_generic_model.g.dart';

@HiveType(typeId: 4) // ⚠️ Make sure this is unique in your project
class IndicationGenericModel {

  @HiveField(0)
  int generic_id;

  @HiveField(1)
  int indication_id;

  IndicationGenericModel({
    required this.generic_id,
    required this.indication_id,
  });

  // ✅ Safe fromJson
  factory IndicationGenericModel.fromJson(Map<String, dynamic> json) {
    return IndicationGenericModel(
      generic_id: json['generic_id'] is int
          ? json['generic_id']
          : int.tryParse(json['generic_id']?.toString() ?? '0') ?? 0,

      indication_id: json['indication_id'] is int
          ? json['indication_id']
          : int.tryParse(json['indication_id']?.toString() ?? '0') ?? 0,
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'generic_id': generic_id,
      'indication_id': indication_id,
    };
  }
}