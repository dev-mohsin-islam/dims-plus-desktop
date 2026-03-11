import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../database/hive_box_get.dart';
import '../models/generic/generic_details_model.dart';
import '../models/therapeutic__generic_index/therapeutic_class_generic_index_model.dart';
import '../services/eng_point_list.dart';
import '../services/get_api_call.dart';
import '../utilities/helpers.dart';
import '../utilities/shared_preferences.dart';

class TherapeuticGenIndCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<TherapeuticClassGenericIndexModel> boxTherapeuticGenInd = HiveBoxGet.getTherapeuticGenericIndex();
  final RxList<TherapeuticClassGenericIndexModel> therapeuticGenIndList = <TherapeuticClassGenericIndexModel>[].obs;
  final RxList<GenericDetailsModel> selectedClassGenerics = <GenericDetailsModel>[].obs;
  final RxBool isLoading = false.obs;
  final helpers = Helpers();
  final sharedPref = SharedPref();
  final getApiCallCtrl = GetApiCallCtrl();

  @override
  void onInit() {
    super.onInit();
    getAllTherapeuticGenIndFromBox();
  }

  Future<void> getAllTherapeuticGenIndFromBox() async {
    try {
      isLoading.value = true;
      therapeuticGenIndList..clear()..addAll(boxTherapeuticGenInd.values);
      print("therapeuticGenIndList.length");
      print(therapeuticGenIndList.length);
    } catch(e) {
      _logger.e(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Get generic IDs by therapeutic class ID - returns List of dynamic (int or String based on your model)
  List<dynamic> getGenericIdsByTherapeuticClass(dynamic therapeuticId) {
    return therapeuticGenIndList
        .where((item) => item.therapitic_id == therapeuticId)
        .map((item) => item.generic_id)
        .toList();
  }


  // Check if a generic belongs to a therapeutic class
  bool isGenericInTherapeuticClass(String genericId, String therapeuticId) {
    return therapeuticGenIndList.any(
            (item) => item.generic_id == genericId && item.therapitic_id == therapeuticId
    );
  }

  // Get therapeutic class IDs by generic ID - returns List of dynamic (int or String based on your model)
  List<dynamic> getTherapeuticClassIdsByGeneric(dynamic genericId) {
    return therapeuticGenIndList
        .where((item) => item.generic_id == genericId)
        .map((item) => item.therapitic_id)
        .toList();
  }


  // Clear selected class generics
  void clearSelectedGenerics() {
    selectedClassGenerics.clear();
  }

  // Refresh from box
  Future<void> refreshTherapeuticGenIndList() async {
    await getAllTherapeuticGenIndFromBox();
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
          if(!boxTherapeuticGenInd.values.where((e) => e.generic_id == data.generic_id && e.therapitic_id == data.therapitic_id).isNotEmpty){
            boxTherapeuticGenInd.add(data);
          }
        }

        getAllTherapeuticGenIndFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  /////////////////
  ///API Call
  /////////////
  Future<void> getTherapeuticGenIndApi() async {
    try {
      isLoading.value = true;

      final String baseUrl = "${EngPoint.BASEURL}${EngPoint.TherapeuticClassGenericIndex}";
      String token = sharedPref.pToken;
      String lastSyncDate = await sharedPref.getLastSyncDate(sharedPref.therapeuticGenIndPref);
      int currentPage = await sharedPref.getLastSyncPage("page${sharedPref.therapeuticGenIndPref}");
      int limit = 155;

      // Get API key with try-catch
      var getKey;
      try {
        getKey = await getApiCallCtrl.getKey(
            url: "${EngPoint.BASEURL}${EngPoint.Getkey}",
            pToken: token
        );
      } catch (e) {
        print("Error getting API key: $e");
        isLoading.value = false;
        return;
      }

      if (await helpers.checkInternetConnection()) {
        bool hasMoreData = true;
        int page = currentPage;

        while (hasMoreData) {
          try {
            var response = await getApiCallCtrl.getApiCall(
                token: getKey,
                url: '$baseUrl?',
                syncDate: lastSyncDate,
                currentPage: page,
                limit: limit
            );

            if (response != null) {
              List<dynamic> insert = [];
              List<dynamic> update = [];
              List<dynamic> delete = [];

              try {
                insert = response['insert']?['data'] ?? [];
                update = response['update']?['data'] ?? [];
                delete = response['delete']?['data'] ?? [];
              } catch (e) {
                _logger.e("Error extracting data from response: $e");
                hasMoreData = false;
                break;
              }

              // Handle insert data
              if (insert.isNotEmpty) {
                try {
                  for (var element in insert) {
                    if (element != null && element['generic_id'] != null && element['therapitic_id'] != null) {
                      if (!therapeuticGenIndList.any((e) =>
                      e.generic_id == element['generic_id'] &&
                          e.therapitic_id == element['therapitic_id'])) {
                        var model = TherapeuticClassGenericIndexModel.fromJson(element);
                        await boxTherapeuticGenInd.add(model);
                        therapeuticGenIndList.add(model);
                      }
                    }
                  }
                } catch (e) {
                  _logger.e("Error processing insert data: $e");
                }
              }

              // Handle update data
              if (update.isNotEmpty) {
                try {
                  for (var element in update) {
                    if (element != null && element['generic_id'] != null && element['therapitic_id'] != null) {
                      var existingIndex = therapeuticGenIndList.indexWhere((e) =>
                      e.generic_id == element['generic_id'] &&
                          e.therapitic_id == element['therapitic_id']);
                      var modelUpdate = TherapeuticClassGenericIndexModel.fromJson(element);

                      if (existingIndex != -1) {
                        therapeuticGenIndList[existingIndex] = modelUpdate;
                        await boxTherapeuticGenInd.putAt(existingIndex, modelUpdate);
                      } else {
                        await boxTherapeuticGenInd.add(modelUpdate);
                        therapeuticGenIndList.add(modelUpdate);
                      }
                    }
                  }
                } catch (e) {
                  _logger.e("Error processing update data: $e");
                }
              }

              // Handle delete data
              if (delete.isNotEmpty) {
                try {
                  for (var element in delete) {
                    if (element != null && element['generic_id'] != null && element['therapitic_id'] != null) {
                      var existingIndex = therapeuticGenIndList.indexWhere((e) =>
                      e?.generic_id == element['generic_id'] &&
                          e.therapitic_id == element['therapitic_id']);
                      if (existingIndex != -1) {
                        therapeuticGenIndList.removeAt(existingIndex);
                        await boxTherapeuticGenInd.deleteAt(existingIndex);
                      }
                    }
                  }
                } catch (e) {
                  _logger.e("Error processing delete data: $e");
                }
              }

              // Check pagination
              try {
                var pagination = response['insert']?['meta']?['pagination'] ??
                    response['update']?['meta']?['pagination'] ??
                    response['delete']?['meta']?['pagination'];

                if (pagination != null) {
                  int totalPages = pagination['total_pages'] ?? 1;
                  int currentPageNum = pagination['current_page'] ?? page;

                  if (currentPageNum >= totalPages) {
                    hasMoreData = false;
                  } else {
                    page = currentPageNum + 1;
                  }
                } else {
                  hasMoreData = false;
                }
              } catch (e) {
                _logger.e("Error processing pagination: $e");
                hasMoreData = false;
              }
            } else {
              _logger.e("Response is null");
              hasMoreData = false;
            }
          } catch (e) {
            _logger.e("Error in API call or data processing: $e");
            hasMoreData = false;
          }
        }

        await getAllTherapeuticGenIndFromBox();

      } else {
        _logger.e("No internet connection");
      }
    } catch (e) {
      _logger.e("Unexpected error in getTherapeuticGenInd: $e");
    } finally {
      isLoading.value = false;
      _logger.i("getTherapeuticGenInd execution completed");
    }
  }
}