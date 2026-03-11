import 'package:dims_desktop/database/hive_box_name.dart';
import 'package:dims_desktop/models/brand/drug_brand_model.dart';
import 'package:dims_desktop/models/company/company_model.dart';
import 'package:dims_desktop/models/generic/generic_details_model.dart';
import 'package:dims_desktop/models/indication/indication_model.dart';
import 'package:dims_desktop/models/indication_generic_index/indication_generic_model.dart';
import 'package:dims_desktop/models/pregnancy_category/pregnancy_category_model.dart';
import 'package:dims_desktop/models/systemic_class/systemic_class_model.dart';
import 'package:dims_desktop/models/therapeutic__generic_index/therapeutic_class_generic_index_model.dart';
import 'package:dims_desktop/models/therapeutic_class/therapeutic_class_model.dart';
import 'package:dims_desktop/models/favourite/favourite_model.dart';
import 'package:dims_desktop/models/registration/occupation_model.dart';
import 'package:dims_desktop/models/registration/speciality_model.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class HiveBoxOpen{
  HiveBoxOpen._privateConstructor();
  static final HiveBoxOpen instance = HiveBoxOpen._privateConstructor();

  Future<void> hiveBoxOpen() async {
   try{
     await safeOpenBox<DrugBrandModel>(BoxName.Brand);
     await safeOpenBox<GenericDetailsModel>(BoxName.Generic);
     await safeOpenBox<CompanyModel>(BoxName.Company);
     await safeOpenBox<TherapeuticClassModel>(BoxName.TherapeuticClass);
     await safeOpenBox<TherapeuticClassGenericIndexModel>(BoxName.TherapeuticClassGenericIndex);
     await safeOpenBox<IndicationGenericModel>(BoxName.IndicationGenericIndex);
     await safeOpenBox<IndicationModel>(BoxName.Indication);
     await safeOpenBox<PregnancyCategoryModel>(BoxName.PregnancyCategory);
     await safeOpenBox<SystemicClassModel>(BoxName.SystemicClass);
     await safeOpenBox<FavouriteModel>(BoxName.Favourite);
     await safeOpenBox<OccupationModel>(BoxName.Occupation);
     await safeOpenBox<SpecialityModel>(BoxName.Speciality);
   }catch(e){
     print(e);
   }
  }

  Future<void> safeOpenBox<T>(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      if (kDebugMode) print("✅ Already opened: $boxName");
      return;
    }

    try {
      await Hive.openBox<T>(boxName);
      if (kDebugMode) print("✅ Opened: $boxName");
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ Failed to open: $boxName");
        print("Error: $e");
        print(stack);
      }
    }
  }
}