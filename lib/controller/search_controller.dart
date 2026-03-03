import 'package:get/get.dart';
import '../models/brand/drug_brand_model.dart';
import 'drug_brand_ctrl.dart';
import 'generic_ctrl.dart';

class SearchCtrl extends GetxController {
  final DrugBrandCtrl drugBrandCtrl = Get.put(DrugBrandCtrl());
  final GenericCtrl genericCtrl = Get.put(GenericCtrl());

  final RxList<DrugBrandModel> searchResults = <DrugBrandModel>[].obs;
  final RxBool isLoading = false.obs;

  void search(String query) {
    isLoading.value = true;
    final searchTerm = query.toLowerCase();

    // Find matching generics
    final matchingGenerics = genericCtrl.genericList
        .where((g) => g.generic_name.toLowerCase().contains(searchTerm))
        .map((g) => g.generic_id)
        .toSet();

    // Find brands matching by name or related generics
    final results = drugBrandCtrl.drugBrandList.where((brand) {
      // Check brand name match
      if (brand.brand_name.toLowerCase().contains(searchTerm)) {
        return true;
      }

      // Check generic match
      if (matchingGenerics.contains(brand.generic_id)) {
        return true;
      }

      // Check strength match
      if (brand.strength?.toLowerCase().contains(searchTerm) ?? false) {
        return true;
      }

      return false;
    }).toList();

    searchResults.value = results;
    isLoading.value = false;
  }
}