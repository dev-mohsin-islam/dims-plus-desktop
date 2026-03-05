
import 'package:dims_desktop/models/generic/generic_details_model.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/hive_box_get.dart';
import '../services/eng_point_list.dart';
import '../services/get_api_call.dart';
import '../utilities/helpers.dart';
import '../utilities/shared_preferences.dart';

class GenericCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<GenericDetailsModel> boxGeneric= HiveBoxGet.getGeneric();
  final RxList<GenericDetailsModel> genericList = <GenericDetailsModel>[].obs;
  final helpers = Helpers();
  final sharedPref = SharedPref();
  final getApiCallCtrl = GetApiCallCtrl();
  final RxList<GenericDetailsModel> filteredGenericList = <GenericDetailsModel>[].obs;
  final RxBool isLoading = false.obs;
  String currentSearchQuery = '';
  Future<void> getAllGenericFromBox() async {
    try {
      isLoading.value = true;
      genericList..clear()..addAll(boxGeneric.values);

      // Sort by generic name
      genericList.sort((a, b) => a.generic_name.compareTo(b.generic_name));

      // Initialize filtered list with all generics
      filteredGenericList.value = genericList;
      print("genericList.length");
      print(genericList.length);
      print(boxGeneric.length);
    } catch(e) {
      _logger.e(e);
    } finally {
      isLoading.value = false;
    }
  }

// Search generics by name
  void searchGenerics(String query) {
    currentSearchQuery = query.toLowerCase().trim();
    applyFilter();
  }

  // Apply search filter
  void applyFilter() {
    if (currentSearchQuery.isEmpty) {
      filteredGenericList.value = genericList;
      return;
    }

    List<GenericDetailsModel> results = List.from(genericList);

    results = results.where((generic) {
      final genericName = generic.generic_name.toLowerCase();
      final indication = generic.indication?.toLowerCase() ?? '';

      return genericName.contains(currentSearchQuery) ||
          indication.contains(currentSearchQuery);
    }).toList();

    filteredGenericList.value = results;
  }

  // Get generic by ID
  GenericDetailsModel? getGenericById(int genericId) {
    try {
      return genericList.firstWhere((g) => g.generic_id == genericId);
    } catch (e) {
      return null;
    }
  }

  // Get generics by IDs
  List<GenericDetailsModel> getGenericsByIds(List<String> genericIds) {
    return genericList.where((g) => genericIds.contains(g.generic_id)).toList();
  }

  // Refresh generic list from box
  Future<void> refreshGenericList() async {
    await getAllGenericFromBox();
  }

  /////////////////
  ///API Call
  /////////////
  Future<void> getGenericApi() async {
    try {
      SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.clear();

      final String baseUrl = "${EngPoint.BASEURL}${EngPoint.Generic}";
      String token = sharedPref.pToken;
      String lastSyncDate = await sharedPref.getLastSyncDate(sharedPref.genericPref);
      int currentPage = await sharedPref.getLastSyncPage("page${sharedPref.genericPref}");
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
                    if (element != null && element['generic_id'] != null) {
                      if (!genericList.any((e) => e.generic_id == element['generic_id'])) {
                        var model =GenericDetailsModel.fromJson(element);
                        await boxGeneric.add(model);
                        genericList.add(model);
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
                    if (element != null && element['generic_id'] != null) {
                      var existingIndex = genericList.indexWhere((e) => e.generic_id == element['generic_id']);
                     var modelUpdate = GenericDetailsModel.fromJson(element);

                      if (existingIndex != -1) {
                        // Update existing record
                        genericList[existingIndex] = modelUpdate;
                        await boxGeneric.putAt(existingIndex,modelUpdate);
                      } else {
                        // Add if not found
                        await boxGeneric.add(modelUpdate);
                        genericList.add(modelUpdate);
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
                    if (element != null && element['generic_id'] != null) {
                      var existingIndex = genericList.indexWhere((e) => e.generic_id == element['generic_id']);
                      if (existingIndex != -1) {
                        genericList.removeAt(existingIndex);
                        await boxGeneric.deleteAt(existingIndex);
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
      _logger.e("Unexpected error in getGeneric: $e");
    } finally {
      _logger.i("getGeneric execution completed");
    }
  }
}