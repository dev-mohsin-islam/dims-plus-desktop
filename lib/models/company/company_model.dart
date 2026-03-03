import 'package:hive/hive.dart';

part 'company_model.g.dart';

@HiveType(typeId: 1) // ⚠️ Ensure this typeId is unique
class CompanyModel {

  @HiveField(0)
  int company_id;

  @HiveField(1)
  String company_name;

  @HiveField(2)
  int? company_order;

  CompanyModel({
    required this.company_id,
    required this.company_name,
    this.company_order,
  });

  // ✅ fromJson (safe parsing)
  factory CompanyModel.fromJson(Map<String, dynamic> json) {
    return CompanyModel(
      company_id: json['company_id'] is int
          ? json['company_id']
          : int.tryParse(json['company_id']?.toString() ?? '0') ?? 0,

      company_name: json['company_name']?.toString() ?? '',

      company_order: json['company_order'] is int
          ? json['company_order']
          : int.tryParse(json['company_order']?.toString() ?? ''),
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'company_id': company_id,
      'company_name': company_name,
      'company_order': company_order,
    };
  }
}