import 'package:hive/hive.dart';

part 'drug_brand_model.g.dart';

@HiveType(typeId: 0) // ⚠️ Make sure this typeId is unique in your project
class DrugBrandModel {

  @HiveField(0)
  int brand_id;

  @HiveField(1)
  String brand_name;

  @HiveField(2)
  int generic_id;

  @HiveField(3)
  int company_id;

  @HiveField(4)
  String? form;

  @HiveField(5)
  String? strength;

  @HiveField(6)
  String? price;

  @HiveField(7)
  String? packsize;

  DrugBrandModel({
    required this.brand_id,
    required this.brand_name,
    required this.generic_id,
    required this.company_id,
    this.form,
    this.strength,
    this.price,
    this.packsize,
  });

  // ✅ fromJson
  factory DrugBrandModel.fromJson(Map<String, dynamic> json) {
    return DrugBrandModel(
      brand_id: json['brand_id'] is int
          ? json['brand_id']
          : int.tryParse(json['brand_id']?.toString() ?? '0') ?? 0,

      brand_name: json['brand_name']?.toString() ?? '',

      generic_id: json['generic_id'] is int
          ? json['generic_id']
          : int.tryParse(json['generic_id']?.toString() ?? '0') ?? 0,

      company_id: json['company_id'] is int
          ? json['company_id']
          : int.tryParse(json['company_id']?.toString() ?? '0') ?? 0,

      form: json['form']?.toString(),
      strength: json['strength']?.toString(),
      price: json['price']?.toString(),
      packsize: json['packsize']?.toString(),
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'brand_id': brand_id,
      'brand_name': brand_name,
      'generic_id': generic_id,
      'company_id': company_id,
      'form': form,
      'strength': strength,
      'price': price,
      'packsize': packsize,
    };
  }
}