import 'dart:convert';

import 'package:dims_desktop/models/company/company_model.dart';
import 'package:dims_desktop/services/get_api_call.dart';
import 'package:dims_desktop/utilities/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

import '../database/hive_box_get.dart';
import '../services/eng_point_list.dart';
import '../utilities/helpers.dart';

class CompanyCtrl extends GetxController {
  final Logger _logger = Logger();
  final Box<CompanyModel> boxCompany = HiveBoxGet.getCompany();
  final RxList<CompanyModel> companyList = <CompanyModel>[].obs;
  final helpers = Helpers();
  final sharedPref = SharedPref();
  final getApiCallCtrl = GetApiCallCtrl();
  final RxList<CompanyModel> filteredCompanyList = <CompanyModel>[].obs;
  final RxBool isLoading = false.obs;
  String currentSearchQuery = '';
  Future<void>getAllCompanyFromBox()async{
    try{
      companyList..clear()..addAll(boxCompany.values);
      print(companyList.length);
      // Sort by company order if available, otherwise by name
      companyList.sort((a, b) {
        if (a.company_order != null && b.company_order != null) {
          return a.company_order!.compareTo(b.company_order!);
        }
        return a.company_name.compareTo(b.company_name);
      });

      // Initialize filtered list with all companies
      filteredCompanyList.value = companyList;
      print("companyList.length");
      print(companyList.length);

    }catch(e){
      _logger.e(e);
    }
  }
  // Search companies by name
  void searchCompanies(String query) {
    currentSearchQuery = query.toLowerCase().trim();

    if (currentSearchQuery.isEmpty) {
      filteredCompanyList.value = companyList;
      return;
    }

    filteredCompanyList.value = companyList.where((company) {
      return company.company_name.toLowerCase().contains(currentSearchQuery);
    }).toList();
  }

  // Get company by ID
  CompanyModel? getCompanyById(int companyId) {
    try {
      return companyList.firstWhere((c) => c.company_id == companyId);
    } catch (e) {
      return null;
    }
  }
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
          if(!boxCompany.values.where((e) => e.company_id == data.company_id).isNotEmpty){
            boxCompany.add(data);
          }
        }
        getAllCompanyFromBox();
      }
    }catch(e){
      _logger.e(e);
    }
  }
  /////////////////
  ///API Call
  /////////////
  Future<void> getCompanyApi() async {
    try {


      final String baseUrl = "${EngPoint.BASEURL}${EngPoint.Company}";
      String token = sharedPref.pToken;
      String lastSyncDate = await sharedPref.getLastSyncDate(sharedPref.companyPref);
      int currentPage = await sharedPref.getLastSyncPage("page${sharedPref.companyPref}");
      int limit = 155;

      // Get API key with try-catch
      late var getKey;
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
                    if (element != null && element['company_id'] != null) {
                      if (!companyList.any((e) => e.company_id == element['company_id'])) {
                        var model =CompanyModel.fromJson(element);
                        await boxCompany.add(model);
                        companyList.add(model);
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
                    if (element != null && element['company_id'] != null) {
                      var existingIndex = companyList.indexWhere((e) => e.company_id == element['company_id']);
                     var modelUpdate = CompanyModel.fromJson(element);

                      if (existingIndex != -1) {
                        // Update existing record
                        companyList[existingIndex] = modelUpdate;
                        await boxCompany.putAt(existingIndex,modelUpdate);
                      } else {
                        // Add if not found
                        await boxCompany.add(modelUpdate);
                        companyList.add(modelUpdate);
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
                    if (element != null && element['company_id'] != null) {
                      var existingIndex = companyList.indexWhere((e) => e.company_id == element['company_id']);
                      if (existingIndex != -1) {
                        companyList.removeAt(existingIndex);
                        await boxCompany.deleteAt(existingIndex);
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
                // await sharedPref.storeLastSyncDateInt("page${sharedPref.companyPref}", page);
                // await sharedPref.storeLastSyncDateString(sharedPref.companyPref, lastSyncDate);
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
      _logger.e("Unexpected error in getCompany: $e");
    } finally {
      _logger.i("getCompany execution completed");
    }
  }

}