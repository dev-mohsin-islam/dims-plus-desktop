import 'package:dims_desktop/database/hive_box_name.dart';
import 'package:dims_desktop/models/brand/drug_brand_model.dart';
import 'package:dims_desktop/models/company/company_model.dart';
import 'package:dims_desktop/models/generic/generic_details_model.dart';
import 'package:dims_desktop/models/indication/indication_model.dart';
import 'package:dims_desktop/models/indication_generic_index/indication_generic_model.dart';
import 'package:dims_desktop/models/pregnancy_category/pregnancy_category_model.dart';
import 'package:dims_desktop/models/registration/occupation_model.dart';
import 'package:dims_desktop/models/registration/speciality_model.dart';
import 'package:dims_desktop/models/systemic_class/systemic_class_model.dart';
import 'package:dims_desktop/models/therapeutic__generic_index/therapeutic_class_generic_index_model.dart';
import 'package:dims_desktop/models/therapeutic_class/therapeutic_class_model.dart';
import 'package:hive/hive.dart';

abstract class HiveBoxGet{

  static Box<DrugBrandModel> getDrugBrand() => Hive.box<DrugBrandModel>(BoxName.Brand);
  static Box<GenericDetailsModel> getGeneric() => Hive.box<GenericDetailsModel>(BoxName.Generic);
  static Box<CompanyModel> getCompany() => Hive.box<CompanyModel>(BoxName.Company);
  static Box<IndicationModel> getIndication() => Hive.box<IndicationModel>(BoxName.Indication);
  static Box<PregnancyCategoryModel> getPregnancyCategory() => Hive.box<PregnancyCategoryModel>(BoxName.PregnancyCategory);
  static Box<IndicationGenericModel> getIndicationGenericIndex() => Hive.box<IndicationGenericModel>(BoxName.IndicationGenericIndex);
  static Box<TherapeuticClassModel> getTherapeuticClass() => Hive.box<TherapeuticClassModel>(BoxName.TherapeuticClass);
  static Box<TherapeuticClassGenericIndexModel> getTherapeuticGenericIndex() => Hive.box<TherapeuticClassGenericIndexModel>(BoxName.TherapeuticClassGenericIndex);
  static Box<SystemicClassModel> getSystemicClass() => Hive.box<SystemicClassModel>(BoxName.SystemicClass);
  static Box<OccupationModel> getOccupation() => Hive.box<OccupationModel>(BoxName.Occupation);
  static Box<SpecialityModel> getSpeciality() => Hive.box<SpecialityModel>(BoxName.Speciality);

}