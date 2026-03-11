import 'dart:convert';

import 'package:dims_desktop/controller/company_ctrl.dart';
import 'package:dims_desktop/controller/drug_brand_ctrl.dart';
import 'package:dims_desktop/controller/generic_ctrl.dart';
import 'package:dims_desktop/controller/indication_ctrl.dart';
import 'package:dims_desktop/controller/pregnancy_cat_ctrl.dart';
import 'package:dims_desktop/controller/systemic_class_ctrl.dart';
import 'package:dims_desktop/controller/therapeutic_class_ctrl.dart';
import 'package:dims_desktop/controller/therapeutic_generic_index_ctrl.dart';
import 'package:dims_desktop/models/systemic_class/systemic_class_model.dart';
import 'package:dims_desktop/models/therapeutic__generic_index/therapeutic_class_generic_index_model.dart';
import 'package:dims_desktop/models/therapeutic_class/therapeutic_class_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:logger/logger.dart';
import '../models/brand/drug_brand_model.dart';
import '../models/company/company_model.dart';
import '../models/generic/generic_details_model.dart';
import '../models/indication/indication_model.dart';
import '../models/indication_generic_index/indication_generic_model.dart';
import '../models/pregnancy_category/pregnancy_category_model.dart';
import '../models/registration/occupation_model.dart';
import 'indication_gen_ind_ctrl.dart';
import 'occupation_ctrl.dart';
import 'speciality_ctrl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DataGetAndSyncCtrl extends GetxController{
  final Logger _logger = Logger();
  final CompanyCtrl _ctrlCompany = Get.put(CompanyCtrl());
  final GenericCtrl _ctrlGeneric = Get.put(GenericCtrl());
  final DrugBrandCtrl _ctrlDrugBrand = Get.put(DrugBrandCtrl());
  final IndicationCtrl _ctrlIndication = Get.put(IndicationCtrl());
  final IndicationGenIndCtrl _ctrlIndicationGenIndex = Get.put(IndicationGenIndCtrl());
  final TherapeuticClassCtrl _ctrlTherapeuticClass = Get.put(TherapeuticClassCtrl());
  final TherapeuticGenIndCtrl _ctrlTherapeuticGenIndex = Get.put(TherapeuticGenIndCtrl());
  final PregnancyCatCtrl _ctrlPregnancy = Get.put(PregnancyCatCtrl());
  final SystemicClassCtrl _systemicClassCtrl = Get.put(SystemicClassCtrl());
  final OccupationCtrl _ctrlOccupation = Get.put(OccupationCtrl());
  final SpecialityCtrl _ctrlSpeciality = Get.put(SpecialityCtrl());








  Future helperSyncFromServer() async {
     try{
       _ctrlCompany.getCompanyApi();
       _ctrlGeneric.getGenericApi();
       _ctrlIndication.getIndicationApi();
       _ctrlTherapeuticClass.getTherapeuticClassApi();
       _ctrlPregnancy.getPregnancyCategoryApi();

     }catch(e){
       _logger.e(e);
     }
  }
  Future dataSyncFromServer() async {
    try{
      await helperSyncFromServer();
      _ctrlDrugBrand.getDrugBrandApi();
      _ctrlTherapeuticGenIndex.getTherapeuticGenIndApi();
      _ctrlIndicationGenIndex.getIndicationGenIndexApi();
    }catch(e){
      _logger.e(e);
    }
  }

  Future dataGetFromBoxHelper() async {
    try{
      _ctrlCompany.getAllCompanyFromBox();
      _ctrlGeneric.getAllGenericFromBox();
      _ctrlIndication.getAllIndicationFromBox();
      _ctrlTherapeuticClass.getAllTherapeuticFromBox();
      _ctrlPregnancy.getAllPregnancyFromBox();
      _systemicClassCtrl.getAllSystemicFromBox();
      _ctrlOccupation.getAllOccupationFromBox();
      _ctrlSpeciality.getAllSpecialityFromBox();
    }catch(e){
      _logger.e(e);
    }
  }
  Future dataGetFromBox() async {
    try{
      await dataGetFromBoxHelper();
      _ctrlDrugBrand.getAllDrugBrandFromBox();
      _ctrlTherapeuticGenIndex.getAllTherapeuticGenIndFromBox();
      _ctrlIndicationGenIndex.getAllIndicationGenIndFromBox();
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>insertFromJson()async{
    await _ctrlCompany.companyInsertJson();
    await _ctrlGeneric.genericInsertJson();
    await _ctrlDrugBrand.druBrandInsertJson();
    await _ctrlIndication.indicationInsertJson();
    await _ctrlIndicationGenIndex.indicationGenIndInsertJson();
    await _ctrlPregnancy.pregnancyCatInsertJson();
    await _ctrlTherapeuticClass.therapeuticClassInsertJson();
    await _ctrlTherapeuticGenIndex.therapeuticClassGenIndInsertJson();
    await _systemicClassCtrl.systemicClassInsertJson();
    await _ctrlOccupation.occupationJson();
    await _ctrlSpeciality.specialtyJson();
  }
  Future<void>boxClear()async{
    await _ctrlCompany.boxCompany.clear();
    await _ctrlGeneric.boxGeneric.clear();
    await _ctrlIndication.boxIndication.clear();
    await _ctrlTherapeuticClass.boxTherapeuticClass.clear();
    await _ctrlPregnancy.boxPregnancyCategory.clear();
    await _ctrlDrugBrand.boxDrugBrand.clear();
    await _ctrlTherapeuticGenIndex.boxTherapeuticGenInd.clear();
    await _ctrlIndicationGenIndex.boxIndGenIndex.clear();
    await _systemicClassCtrl.boxSystemicClass.clear();
  }
  Future initialCall()async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if(!prefs.containsKey("initialCallJson")){
      await insertFromJson();
      prefs.setBool("initialCallJson", true);
    }
    // await boxClear();

    try{
      // await dataSyncFromServer();

      await dataGetFromBox();
    }catch(e){
      _logger.e(e);
    }
  }
  @override
  void onInit() {
    super.onInit();
  }
}