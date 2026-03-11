
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive/hive.dart';
import '../database/hive_box_get.dart';
import '../models/pregnancy_category/pregnancy_category_model.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/eng_point_list.dart';
import '../services/get_api_call.dart';
import '../utilities/helpers.dart';
import '../utilities/shared_preferences.dart';

class PregnancyCatCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<PregnancyCategoryModel> boxPregnancyCategory = HiveBoxGet.getPregnancyCategory();
  final RxList<PregnancyCategoryModel> pregnancyCategoryList = <PregnancyCategoryModel>[].obs;
  final helpers = Helpers();
  final sharedPref = SharedPref();
  final getApiCallCtrl = GetApiCallCtrl();

  Future<void>getAllPregnancyFromBox()async{
    try{
      pregnancyCategoryList..clear()..addAll(boxPregnancyCategory.values);
      print("pregnancyCategoryList.length");
      print(pregnancyCategoryList.length);
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

          if(!boxPregnancyCategory.values.where((e) => e.id == data.id).isNotEmpty){
            boxPregnancyCategory.add(data);
          }
        }
        getAllPregnancyFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }


  /////////////////
  ///API Call
  /////////////
  Future<void> getPregnancyCategoryApi() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();

      final String baseUrl = "${EngPoint.BASEURL}${EngPoint.IndicationGenericIndex}";
      String token = sharedPref.pToken;
      String lastSyncDate = await sharedPref.getLastSyncDate(sharedPref.pregnancyPref);
      int currentPage = await sharedPref.getLastSyncPage("page${sharedPref.pregnancyPref}");
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
        return;
      }

      if (await helpers.checkInternetConnection()) {
        bool hasMoreData = true;
        int page = currentPage; // Start from the stored page

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
              // Safely extract data with null checks
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
                    if (element != null && element['id'] != null) {
                      if (!pregnancyCategoryList.any((e) => e.id == element['id'])) {
                        var model = PregnancyCategoryModel.fromJson(element);
                        await boxPregnancyCategory.add(model);
                        pregnancyCategoryList.add(model);
                      }
                    }
                  }
                } catch (e) {
                  _logger.e("Error processing insert data: $e");
                  // Continue with other operations instead of breaking
                }
              }

              // Handle update data
              if (update.isNotEmpty) {
                try {
                  for (var element in update) {
                    if (element != null && element['id'] != null) {
                      var existingIndex = pregnancyCategoryList.indexWhere((e) => e.id == element['id']);
                      var modelUpdate = PregnancyCategoryModel.fromJson(element);

                      if (existingIndex != -1) {
                        // Update existing record
                        pregnancyCategoryList[existingIndex] = modelUpdate;
                        await boxPregnancyCategory.putAt(existingIndex, modelUpdate);
                      } else {
                        // Add if not found
                        await boxPregnancyCategory.add(modelUpdate);
                        pregnancyCategoryList.add(modelUpdate);
                      }
                    }
                  }
                } catch (e) {
                  _logger.e("Error processing update data: $e");
                  // Continue with other operations
                }
              }

              // Handle delete data
              if (delete.isNotEmpty) {
                try {
                  for (var element in delete) {
                    if (element != null && element['id'] != null) {
                      var existingIndex = pregnancyCategoryList.indexWhere((e) => e.id == element['id']);
                      if (existingIndex != -1) {
                        pregnancyCategoryList.removeAt(existingIndex);
                        await boxPregnancyCategory.deleteAt(existingIndex);
                      }
                    }
                  }
                } catch (e) {
                  _logger.e("Error processing delete data: $e");
                  // Continue with pagination check
                }
              }

              // Check if this was the last page
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
                  // If no pagination info, assume we're done after one page
                  hasMoreData = false;
                }
              } catch (e) {
                _logger.e("Error processing pagination: $e");
                hasMoreData = false;
              }

              // Store the progress with try-catch
              try {
                // await sharedPref.storeLastSyncDateInt("page${sharedPref.pregnancyPref}", page);
                // await sharedPref.storeLastSyncDateString(sharedPref.pregnancyPref, lastSyncDate);
              } catch (e) {
                _logger.e("Error storing sync progress: $e");
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
      } else {
        _logger.e("No internet connection");
      }
    } catch (e) {
      _logger.e("Unexpected error in getPregnancyCategory: $e");
    } finally {
      _logger.i("getPregnancyCategory execution completed");
    }
  }
}