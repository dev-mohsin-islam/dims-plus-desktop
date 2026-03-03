import 'package:hive/hive.dart';

part 'generic_details_model.g.dart';

@HiveType(typeId: 2) // ⚠️ Must be unique in your project
class GenericDetailsModel {

  @HiveField(0)
  int generic_id;

  @HiveField(1)
  String generic_name;

  @HiveField(2)
  String? precaution;

  @HiveField(3)
  String? indication;

  @HiveField(4)
  String? contra_indication;

  @HiveField(5)
  String? dose;

  @HiveField(6)
  String? side_effect;

  @HiveField(7)
  int? pregnancy_category_id;

  @HiveField(8)
  String? mode_of_action;

  @HiveField(9)
  String? interaction;

  @HiveField(10)
  String? pregnancy_category_note;

  @HiveField(11)
  String? adult_dose;

  @HiveField(12)
  String? child_dose;

  @HiveField(13)
  String? renal_dose;

  @HiveField(14)
  String? administration;

  GenericDetailsModel({
    required this.generic_id,
    required this.generic_name,
    this.precaution,
    this.indication,
    this.contra_indication,
    this.dose,
    this.side_effect,
    this.pregnancy_category_id,
    this.mode_of_action,
    this.interaction,
    this.pregnancy_category_note,
    this.adult_dose,
    this.child_dose,
    this.renal_dose,
    this.administration,
  });

  // ✅ fromJson (safe parsing)
  factory GenericDetailsModel.fromJson(Map<String, dynamic> json) {
    return GenericDetailsModel(
      generic_id: json['generic_id'] is int
          ? json['generic_id']
          : int.tryParse(json['generic_id']?.toString() ?? '0') ?? 0,

      generic_name: json['generic_name']?.toString() ?? '',

      precaution: json['precaution']?.toString(),
      indication: json['indication']?.toString(),
      contra_indication: json['contra_indication']?.toString(),
      dose: json['dose']?.toString(),
      side_effect: json['side_effect']?.toString(),

      pregnancy_category_id: json['pregnancy_category_id'] is int
          ? json['pregnancy_category_id']
          : int.tryParse(json['pregnancy_category_id']?.toString() ?? ''),

      mode_of_action: json['mode_of_action']?.toString(),
      interaction: json['interaction']?.toString(),
      pregnancy_category_note: json['pregnancy_category_note']?.toString(),
      adult_dose: json['adult_dose']?.toString(),
      child_dose: json['child_dose']?.toString(),
      renal_dose: json['renal_dose']?.toString(),
      administration: json['administration']?.toString(),
    );
  }

  // ✅ toJson
  Map<String, dynamic> toJson() {
    return {
      'generic_id': generic_id,
      'generic_name': generic_name,
      'precaution': precaution,
      'indication': indication,
      'contra_indication': contra_indication,
      'dose': dose,
      'side_effect': side_effect,
      'pregnancy_category_id': pregnancy_category_id,
      'mode_of_action': mode_of_action,
      'interaction': interaction,
      'pregnancy_category_note': pregnancy_category_note,
      'adult_dose': adult_dose,
      'child_dose': child_dose,
      'renal_dose': renal_dose,
      'administration': administration,
    };
  }
}