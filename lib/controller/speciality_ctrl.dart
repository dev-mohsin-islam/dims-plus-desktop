import 'dart:convert';
import 'package:dims_desktop/database/hive_box_name.dart';
import 'package:dims_desktop/models/registration/speciality_model.dart';
import 'package:dims_desktop/services/eng_point_list.dart';
import 'package:dims_desktop/services/get_api_call.dart';
import 'package:dims_desktop/utilities/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class SpecialityCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<SpecialityModel> boxSpeciality = Hive.box<SpecialityModel>(BoxName.Speciality);
  final SharedPref _sharedPref = SharedPref();
  final GetApiCallCtrl _getApiCallCtrl = GetApiCallCtrl();
  
  var specialityList = <SpecialityModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAllSpecialityFromBox();
  }

  Future<void> getAllSpecialityFromBox() async {
    specialityList.assignAll(boxSpeciality.values.toList());
  }
  Future<void>specialtyJson()async{
    try{
      String jsonString = await rootBundle.loadString('assets/db/d_specialty.json');
      final jsonResponse = await json.decode(jsonString);
      if(jsonResponse != null && jsonResponse.isNotEmpty){
        for(var item in jsonResponse){
          SpecialityModel data = SpecialityModel(
            id: item['id'] ?? 0,
            specialty: item['name'] ?? '',
          );
          if(!boxSpeciality.values.where((e) => e.id == data.id).isNotEmpty){
           boxSpeciality.add(data);
          }
        }
        getAllSpecialityFromBox();

      }
    }catch(e){
      _logger.e(e);
    }
  }
  Future<void> getSpecialityApi() async {
    isLoading.value = true;
    try {
      String token = _sharedPref.pToken;
      
      var getKey;
      try {
        getKey = await _getApiCallCtrl.getKey(
          url: "${EngPoint.BASEURL}${EngPoint.Getkey}",
          pToken: token
        );
      } catch (e) {
        _logger.e("Error getting API key: $e");
        isLoading.value = false;
        return;
      }

      if (getKey == null) {
        _logger.e("API key is null");
        isLoading.value = false;
        return;
      }

      final response = await http.post(
        Uri.parse("${EngPoint.BASEURL}${EngPoint.Specialities}"),
        headers: {
          'X-Auth-Token': getKey.toString(),
          'Accept': 'application/json',
        },
        body: {'limit': '100'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        void processItems(dynamic section) {
          if (section != null && section['data'] != null) {
            for (var item in section['data']) {
              final model = SpecialityModel(
                id: item['id'] ?? 0,
                specialty: item['specialty'] ?? '',
              );
              
              final existingIndex = boxSpeciality.values.toList().indexWhere((e) => e.id == model.id);
              if (existingIndex != -1) {
                boxSpeciality.putAt(existingIndex, model);
              } else {
                boxSpeciality.add(model);
              }
            }
          }
        }

        processItems(data['insert']);
        processItems(data['update']);

        if (data['delete'] != null && data['delete']['data'] != null) {
          for (var item in data['delete']['data']) {
            final id = item['id'];
            final existingIndex = boxSpeciality.values.toList().indexWhere((e) => e.id == id);
            if (existingIndex != -1) boxSpeciality.deleteAt(existingIndex);
          }
        }

        getAllSpecialityFromBox();
      }
    } catch (e) {
      _logger.e("Error fetching specialities: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
