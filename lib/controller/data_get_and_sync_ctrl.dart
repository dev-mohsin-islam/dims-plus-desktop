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
import 'indication_gen_ind_ctrl.dart';
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

  Future<void>companyInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_company_name.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){

        for(var item in jsonResponse){
          CompanyModel data = CompanyModel(
            company_id: int.parse(item['company_id']),
            company_name: item['company_name'],
          );
          if(!_ctrlCompany.boxCompany.values.where((e) => e.company_id == data.company_id).isNotEmpty){
            _ctrlCompany.boxCompany.add(data);
          }
        }
        _ctrlCompany.getAllCompanyFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>genericInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_drug_generic.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
        var dataList = (jsonResponse as List)
            .map((i) => GenericDetailsModel.fromJson(i))
            .where((company) => !_ctrlGeneric.boxGeneric.values
            .any((e) => e.generic_id == company.generic_id))
            .toList();

        _ctrlGeneric.boxGeneric.addAll(dataList);
        _ctrlGeneric.getAllGenericFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>druBrandInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_drug_brand.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
        for(var item in jsonResponse){
          DrugBrandModel data = DrugBrandModel(
              brand_id: int.parse(item['brand_id']),
              brand_name: item['brand_name'],
              generic_id: int.parse(item['generic_id']),
            company_id: int.parse(item['company_id']),
            form: item['form'],
            strength: item['strength'],
            packsize: item['packsize'],
            price:  item['price'],
          );
          if(!_ctrlDrugBrand.boxDrugBrand.values.where((e) => e.brand_id == data.brand_id).isNotEmpty){
            _ctrlDrugBrand.boxDrugBrand.add(data);
          }
        }

        _ctrlDrugBrand.getAllDrugBrandFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>indicationInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_indication.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
        for(var item in jsonResponse){
          IndicationModel data = IndicationModel(
              id: int.parse(item['indication_id']),
              name: item['indication_name'],
          );
          if(!_ctrlIndication.boxIndication.values.where((e) => e.id == data.id).isNotEmpty){
            _ctrlIndication.boxIndication.add(data);
          }
        }
        _ctrlIndication.getAllIndicationFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>indicationGenIndInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_indication_generic_index.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
        for(var item in jsonResponse){
          IndicationGenericModel data = IndicationGenericModel(
              generic_id: int.parse(item['generic_id']),
              indication_id: item['indication_id'],
          );

          if(!_ctrlIndicationGenIndex.boxIndGenIndex.values.where((e) => e.generic_id == data.generic_id && e.indication_id == data.indication_id).isNotEmpty){
            _ctrlIndicationGenIndex.boxIndGenIndex.add(data);
          }
        }
        _ctrlIndicationGenIndex.getAllIndicationGenIndFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>pregnancyCatInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_pregnancy_category.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
        for(var item in jsonResponse){
          PregnancyCategoryModel data = PregnancyCategoryModel(
              id: int.parse(item['pregnancy_id'].toString()),
              name: item['pregnancy_name'],
              description: item['pregnancy_description'],
            );

          if(!_ctrlPregnancy.boxPregnancyCategory.values.where((e) => e.id == data.id).isNotEmpty){
            _ctrlPregnancy.boxPregnancyCategory.add(data);
          }
        }
        _ctrlPregnancy.getAllPregnancyFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>therapeuticClassInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_therapitic.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
         for(var item in jsonResponse){
           TherapeuticClassModel data = TherapeuticClassModel(
             id: int.parse(item['therapitic_id']),
             name: item['therapitic_name'],
             systemic_class_id: int.parse(item['therapitic_systemic_class_id']),
           );
           if(!_ctrlTherapeuticClass.boxTherapeuticClass.values.where((e) => e.id == data.id).isNotEmpty){
             _ctrlTherapeuticClass.boxTherapeuticClass.add(data);
           }
         }

        _ctrlTherapeuticClass.getAllTherapeuticFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>therapeuticClassGenIndInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_therapitic_generic.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
        for(var item in jsonResponse){
          TherapeuticClassGenericIndexModel data = TherapeuticClassGenericIndexModel(
              generic_id: int.parse(item['generic_id']),
              therapitic_id: int.parse(item['therapitic_id'])
          );
          if(!_ctrlTherapeuticGenIndex.boxTherapeuticGenInd.values.where((e) => e.generic_id == data.generic_id && e.therapitic_id == data.therapitic_id).isNotEmpty){
            _ctrlTherapeuticGenIndex.boxTherapeuticGenInd.add(data);
          }
        }

        _ctrlTherapeuticGenIndex.getAllTherapeuticGenIndFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void>systemicClassInsertJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/t_systemic.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
        for(var item in jsonResponse){
          SystemicClassModel data = SystemicClassModel(
            id: item['systemic_id'],
            name: item['systemic_name'],
            parent_id: item['systemic_parent_id'],
          );
          if(!_systemicClassCtrl.boxSystemicClass.values.where((e) => e.id == data.id).isNotEmpty){
            _systemicClassCtrl.boxSystemicClass.add(data);
          }
        }

        _systemicClassCtrl.getAllTherapeuticFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }

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
    await companyInsertJson();
    await genericInsertJson();
    await druBrandInsertJson();
    await indicationInsertJson();
    await indicationGenIndInsertJson();
    await pregnancyCatInsertJson();
    await therapeuticClassInsertJson();
    await therapeuticClassGenIndInsertJson();
    await systemicClassInsertJson();
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
  Future initialCall() async {
    // await boxClear();
    // await insertFromJson();
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
    initialCall();
  }
}