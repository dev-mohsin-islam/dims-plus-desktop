
import 'dart:convert';

import 'package:dims_desktop/models/indication/indication_model.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/hive_box_get.dart';
import '../services/eng_point_list.dart';
import '../services/get_api_call.dart';
import '../utilities/helpers.dart';
import '../utilities/shared_preferences.dart';

class IndicationCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<IndicationModel> boxIndication= HiveBoxGet.getIndication();
  final RxList<IndicationModel> indicationList = <IndicationModel>[].obs;
  final RxList<IndicationModel> filteredIndicationList = <IndicationModel>[].obs;
  final helpers = Helpers();
  final sharedPref = SharedPref();
  final getApiCallCtrl = GetApiCallCtrl();
  String currentSearchQuery = '';
  Future<void>getAllIndicationFromBox()async{
    try{
      indicationList..clear()..addAll(boxIndication.values);
      print("indicationList.length");
      print(indicationList.length);
    }catch(e){
      _logger.e(e);
    }
  }
  // Search indications by name
  void searchIndications(String query) {
    currentSearchQuery = query.toLowerCase().trim();
    applyFilter();
  }

  // Apply search filter
  void applyFilter() {
    if (currentSearchQuery.isEmpty) {
      filteredIndicationList.value = indicationList;
      return;
    }

    List<IndicationModel> results = List.from(indicationList);

    results = results.where((indication) {
      final indicationName = indication.name.toLowerCase();
      return indicationName.contains(currentSearchQuery);
    }).toList();

    filteredIndicationList.value = results;
  }

  // Get indication by ID
  IndicationModel? getIndicationById(int id) {
    try {
      return indicationList.firstWhere((ind) => ind.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get indications by IDs
  List<IndicationModel> getIndicationsByIds(List<int> ids) {
    return indicationList.where((ind) => ids.contains(ind.id)).toList();
  }

  // Refresh indication list from box
  Future<void> refreshIndicationList() async {
    await getAllIndicationFromBox();
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
          if(!boxIndication.values.where((e) => e.id == data.id).isNotEmpty){
            boxIndication.add(data);
          }
        }
        getAllIndicationFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }

  /////////////////
  ///API Call
  /////////////
  Future<void> getIndicationApi() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();

      final String baseUrl = "${EngPoint.BASEURL}${EngPoint.Indication}";
      String token = sharedPref.pToken;
      String lastSyncDate = await sharedPref.getLastSyncDate(sharedPref.indicationPref);
      int currentPage = await sharedPref.getLastSyncPage("page${sharedPref.indicationPref}");
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
                      if (!indicationList.any((e) => e.id == element['id'])) {
                        var model =IndicationModel.fromJson(element);
                        await boxIndication.add(model);
                        indicationList.add(model);
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
                      var existingIndex = indicationList.indexWhere((e) => e.id == element['id']);
                     var modelUpdate = IndicationModel.fromJson(element);

                      if (existingIndex != -1) {
                        // Update existing record
                        indicationList[existingIndex] = modelUpdate;
                        await boxIndication.putAt(existingIndex,modelUpdate);
                      } else {
                        // Add if not found
                        await boxIndication.add(modelUpdate);
                        indicationList.add(modelUpdate);
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
                      var existingIndex = indicationList.indexWhere((e) => e.id == element['id']);
                      if (existingIndex != -1) {
                        indicationList.removeAt(existingIndex);
                        await boxIndication.deleteAt(existingIndex);
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
                // await sharedPref.storeLastSyncDateInt("page${sharedPref.genericPref}", page);
                // await sharedPref.storeLastSyncDateString(sharedPref.genericPref, lastSyncDate);
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
      _logger.e("Unexpected error in getIndicationCall: $e");
    } finally {
      _logger.i("getIndicationCall execution completed");
    }
  }
}