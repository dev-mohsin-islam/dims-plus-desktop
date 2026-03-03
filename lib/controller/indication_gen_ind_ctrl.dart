
import 'package:dims_desktop/models/indication_generic_index/indication_generic_model.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/hive_box_get.dart';
import '../models/generic/generic_details_model.dart';
import '../services/eng_point_list.dart';
import '../services/get_api_call.dart';
import '../utilities/helpers.dart';
import '../utilities/shared_preferences.dart';

class IndicationGenIndCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<IndicationGenericModel> boxIndGenIndex = HiveBoxGet.getIndicationGenericIndex();
  final RxList<IndicationGenericModel> indicationGenIndList = <IndicationGenericModel>[].obs;
  final RxList<GenericDetailsModel> selectedIndicationGenerics = <GenericDetailsModel>[].obs;
  final RxBool isLoading = false.obs;
  final helpers = Helpers();
  final sharedPref = SharedPref();
  final getApiCallCtrl = GetApiCallCtrl();

  Future<void>getAllIndicationGenIndFromBox()async{
    try{
      indicationGenIndList..clear()..addAll(boxIndGenIndex.values);
      print("indicationGenIndList.length");
      print(indicationGenIndList.length);
    }catch(e){
      _logger.e(e);
    }
  }

  // Get generic IDs by indication ID
  List<dynamic> getGenericIdsByIndication(dynamic indicationId) {
    return indicationGenIndList
        .where((item) => item.indication_id == indicationId)
        .map((item) => item.generic_id)
        .toList();
  }

  // Get indication IDs by generic ID
  List<dynamic> getIndicationIdsByGeneric(dynamic genericId) {
    return indicationGenIndList
        .where((item) => item.generic_id == genericId)
        .map((item) => item.indication_id)
        .toList();
  }

  // Check if a generic belongs to an indication
  bool isGenericInIndication(dynamic genericId, dynamic indicationId) {
    return indicationGenIndList.any(
            (item) => item.generic_id == genericId && item.indication_id == indicationId
    );
  }

  // Get all relationships for an indication
  List<IndicationGenericModel> getRelationsByIndication(dynamic indicationId) {
    return indicationGenIndList
        .where((item) => item.indication_id == indicationId)
        .toList();
  }

  // Get all relationships for a generic
  List<IndicationGenericModel> getRelationsByGeneric(dynamic genericId) {
    return indicationGenIndList
        .where((item) => item.generic_id == genericId)
        .toList();
  }

  // Clear selected indication generics
  void clearSelectedGenerics() {
    selectedIndicationGenerics.clear();
  }

  // Refresh from box
  Future<void> refreshIndicationGenIndList() async {
    await getAllIndicationGenIndFromBox();
  }

  /////////////////
  ///API Call
  /////////////
  Future<void> getIndicationGenIndexApi() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();

      final String baseUrl = "${EngPoint.BASEURL}${EngPoint.IndicationGenericIndex}";
      String token = sharedPref.pToken;
      String lastSyncDate = await sharedPref.getLastSyncDate(sharedPref.indicationGenIndPref);
      int currentPage = await sharedPref.getLastSyncPage("page${sharedPref.indicationGenIndPref}");
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
                    if (element != null && element['indication_id'] != null) {
                      if (!indicationGenIndList.any((e) => e.indication_id == element['indication_id'])) {
                        var model = IndicationGenericModel.fromJson(element);
                        await boxIndGenIndex.add(model);
                        indicationGenIndList.add(model);
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
                    if (element != null && element['indication_id'] != null) {
                      var existingIndex = indicationGenIndList.indexWhere((e) => e.indication_id == element['indication_id']);
                     var modelUpdate = IndicationGenericModel.fromJson(element);

                      if (existingIndex != -1) {
                        // Update existing record
                        indicationGenIndList[existingIndex] = modelUpdate;
                        await boxIndGenIndex.putAt(existingIndex, modelUpdate);
                      } else {
                        // Add if not found
                        await boxIndGenIndex.add(modelUpdate);
                        indicationGenIndList.add(modelUpdate);
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
                    if (element != null && element['indication_id'] != null) {
                      var existingIndex = indicationGenIndList.indexWhere((e) => e.indication_id == element['indication_id']);
                      if (existingIndex != -1) {
                        indicationGenIndList.removeAt(existingIndex);
                        await boxIndGenIndex.deleteAt(existingIndex);
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
                // await sharedPref.storeLastSyncDateInt("page${sharedPref.indicationGenIndPref}", page);
                // await sharedPref.storeLastSyncDateString(sharedPref.indicationGenIndPref, lastSyncDate);
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
      _logger.e("Unexpected error in getIndicationGenericCall: $e");
    } finally {
      _logger.i("getIndicationGenericCall execution completed");
    }
  }
}