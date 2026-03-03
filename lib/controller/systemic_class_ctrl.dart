
import 'package:dims_desktop/models/systemic_class/systemic_class_model.dart';
import 'package:dims_desktop/models/therapeutic_class/therapeutic_class_model.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive/hive.dart';

import '../database/hive_box_get.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/eng_point_list.dart';
import '../services/get_api_call.dart';
import '../utilities/helpers.dart';
import '../utilities/shared_preferences.dart';

class SystemicClassCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<SystemicClassModel> boxSystemicClass = HiveBoxGet.getSystemicClass();
  final RxList<SystemicClassModel> systemicClassList = <SystemicClassModel>[].obs;
  final helpers = Helpers();
  final sharedPref = SharedPref();
  final getApiCallCtrl = GetApiCallCtrl();

  Future<void>getAllTherapeuticFromBox()async{
    try{
      systemicClassList..clear()..addAll(boxSystemicClass.values);
      print("systemicClassList.length");
      print(systemicClassList.length);
    }catch(e){
      _logger.e(e);
    }
  }


  /////////////////
  ///API Call
  /////////////
  Future<void> getTherapeuticClassApi() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();

      final String baseUrl = "${EngPoint.BASEURL}${EngPoint.TherapeuticClass}";
      String token = sharedPref.pToken;
      String lastSyncDate = await sharedPref.getLastSyncDate(sharedPref.therapeuticPref);
      int currentPage = await sharedPref.getLastSyncPage("page${sharedPref.therapeuticPref}");
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
                      if (!systemicClassList.any((e) => e.id == element['id'])) {
                        var model = SystemicClassModel.fromJson(element);
                        await boxSystemicClass.add(model);
                        systemicClassList.add(model);
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
                      var existingIndex = systemicClassList.indexWhere((e) => e.id == element['id']);
                      var modelUpdate = SystemicClassModel.fromJson(element);

                      if (existingIndex != -1) {
                        // Update existing record
                        systemicClassList[existingIndex] = modelUpdate;
                        await boxSystemicClass.putAt(existingIndex, modelUpdate);
                      } else {
                        // Add if not found
                        await boxSystemicClass.add(modelUpdate);
                        systemicClassList.add(modelUpdate);
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
                      var existingIndex = systemicClassList.indexWhere((e) => e.id == element['id']);
                      if (existingIndex != -1) {
                        systemicClassList.removeAt(existingIndex);
                        await boxSystemicClass.deleteAt(existingIndex);
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
                // await sharedPref.storeLastSyncDateInt("page${sharedPref.therapticPref}", page);
                // await sharedPref.storeLastSyncDateString(sharedPref.therapticPref, lastSyncDate);
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
      _logger.e("Unexpected error in getTherapeuticClass: $e");
    } finally {
      _logger.i("getTherapeuticClass execution completed");
    }
  }
}