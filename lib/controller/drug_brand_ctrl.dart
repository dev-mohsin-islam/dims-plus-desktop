import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../database/hive_box_get.dart';
import '../models/brand/drug_brand_model.dart';
import '../services/eng_point_list.dart';
import '../services/get_api_call.dart';
import '../utilities/helpers.dart';
import '../utilities/shared_preferences.dart';

class DrugBrandCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<DrugBrandModel> boxDrugBrand = HiveBoxGet.getDrugBrand();
  final RxList<DrugBrandModel> drugBrandList = <DrugBrandModel>[].obs;
  final RxList<DrugBrandModel> filteredBrandList = <DrugBrandModel>[].obs;
  final RxBool isLoading = false.obs;
  final helpers = Helpers();
  final sharedPref = SharedPref();
  final getApiCallCtrl = GetApiCallCtrl();

  // Filter variables
  int? currentFilterGenericId;
  int? currentFilterCompanyId;
  String currentSearchQuery = '';

  @override
  void onInit() {
    super.onInit();
  }
  // Clear all filters
  void clearFilters() {
    currentFilterGenericId = null;
    currentFilterCompanyId = null;
    currentSearchQuery = '';
    filteredBrandList.value = drugBrandList;
  }
  Future<void> getAllDrugBrandFromBox() async {
    try {
      isLoading.value = true;
      drugBrandList..clear()..addAll(boxDrugBrand.values);

      // Sort by brand name
      drugBrandList.sort((a, b) => a.brand_name.compareTo(b.brand_name));

      // Initialize filtered list with all brands
      filteredBrandList.value = drugBrandList;
      print("drugBrandList.length");
      print(drugBrandList.length);
    } catch(e) {
      _logger.e(e);
    } finally {
      isLoading.value = false;
    }
  }

  // Filter by generic ID
  void filterByGeneric(int genericId) {
    currentFilterGenericId = genericId;
    applyFilters();
  }

  // Filter by company ID
  void filterByCompany(int companyId) {
    currentFilterCompanyId = companyId;
    applyFilters();
  }

  // Search brands by name, strength, or form
  void searchBrands(String query) {
    currentSearchQuery = query.toLowerCase().trim();
    applyFilters();
  }



  // Apply all active filters
  void applyFilters() {
    // Start with the entire list as a regular List
    List<DrugBrandModel> results = List.from(drugBrandList);

    // Apply generic filter
    if (currentFilterGenericId != null) {
      results = results.where((b) => b.generic_id == currentFilterGenericId).toList();
    }

    // Apply company filter
    if (currentFilterCompanyId != null) {
      results = results.where((b) => b.company_id == currentFilterCompanyId).toList();
    }

    // Apply search query
    if (currentSearchQuery.isNotEmpty) {
      results = results.where((b) {
        final brandName = b.brand_name.toLowerCase();
        final strength = b.strength?.toLowerCase() ?? '';
        final form = b.form?.toLowerCase() ?? '';

        return brandName.contains(currentSearchQuery) ||
            strength.contains(currentSearchQuery) ||
            form.contains(currentSearchQuery);
      }).toList();
    }

    // Assign the filtered List to the RxList's value
    filteredBrandList.value = results;
  }
  // Get brands by generic ID
  List<DrugBrandModel> getBrandsByGeneric(int genericId) {
    return drugBrandList.where((b) => b.generic_id == genericId).toList();
  }

  // Get brands by company ID
  List<DrugBrandModel> getBrandsByCompany(int companyId) {
    return drugBrandList.where((b) => b.company_id == companyId).toList();
  }

  // Get brand by ID
  DrugBrandModel? getBrandById(String brandId) {
    try {
      return drugBrandList.firstWhere((b) => b.brand_id == brandId);
    } catch (e) {
      return null;
    }
  }

  // Refresh brand list from box
  Future<void> refreshBrandList() async {
    await getAllDrugBrandFromBox();
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
          if(!boxDrugBrand.values.where((e) => e.brand_id == data.brand_id).isNotEmpty){
            boxDrugBrand.add(data);
          }
        }

        getAllDrugBrandFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }

  /////////////////
  ///API Call
  /////////////
  Future<void> getDrugBrandApi() async {
    try {
      isLoading.value = true;

      final String baseUrl = "${EngPoint.BASEURL}${EngPoint.Brand}";

      String lastSyncDate = await sharedPref.getLastSyncDate(sharedPref.brandPref);
      int currentPage = await sharedPref.getLastSyncPage("page${sharedPref.brandPref}");
      int limit = 165;
      String token = sharedPref.pToken;
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
                    if (element != null && element['brand_id'] != null) {
                      if (!drugBrandList.any((e) => e.brand_id == element['brand_id'])) {
                        var model = DrugBrandModel.fromJson(element);
                        await boxDrugBrand.add(model);
                        drugBrandList.add(model);
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
                    if (element != null && element['brand_id'] != null) {
                      var existingIndex = drugBrandList.indexWhere((e) => e.brand_id == element['brand_id']);
                      var modelUpdate = DrugBrandModel.fromJson(element);

                      if (existingIndex != -1) {
                        // Update existing record
                        drugBrandList[existingIndex] = modelUpdate;
                        await boxDrugBrand.putAt(existingIndex, modelUpdate);
                      } else {
                        // Add if not found
                        await boxDrugBrand.add(modelUpdate);
                        drugBrandList.add(modelUpdate);
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
                    if (element != null && element['brand_id'] != null) {
                      var existingIndex = drugBrandList.indexWhere((e) => e.brand_id == element['brand_id']);
                      if (existingIndex != -1) {
                        drugBrandList.removeAt(existingIndex);
                        await boxDrugBrand.deleteAt(existingIndex);
                      }
                    }
                  }
                } catch (e) {
                  _logger.e("Error processing delete data: $e");
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

        // After all data is loaded, refresh the list
        await getAllDrugBrandFromBox();

      } else {
        _logger.e("No internet connection");
      }
    } catch (e) {
      _logger.e("Unexpected error in getDrugBrand: $e");
    } finally {
      isLoading.value = false;
      _logger.i("getDrugBrand execution completed");
    }
  }
}