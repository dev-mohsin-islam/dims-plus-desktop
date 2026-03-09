import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/brand/drug_brand_model.dart';
import '../models/company/company_model.dart';
import '../models/generic/generic_details_model.dart';
import '../models/indication/indication_model.dart';
import '../models/indication_generic_index/indication_generic_model.dart';
import '../models/pregnancy_category/pregnancy_category_model.dart';
import '../models/systemic_class/systemic_class_model.dart';
import '../models/therapeutic__generic_index/therapeutic_class_generic_index_model.dart';
import '../models/therapeutic_class/therapeutic_class_model.dart';
import '../models/favourite/favourite_model.dart';

class AdapterRegister {
  Future<void> registerAdapters() async {
    try {
      _safeRegister(DrugBrandModelAdapter(), 0);
      _safeRegister(CompanyModelAdapter(), 1);
      _safeRegister(GenericDetailsModelAdapter(), 2);
      _safeRegister(IndicationModelAdapter(), 3);
      _safeRegister(IndicationGenericModelAdapter(), 4);
      _safeRegister(PregnancyCategoryModelAdapter(), 5);
      _safeRegister(SystemicClassModelAdapter(), 6);
      _safeRegister(TherapeuticClassGenericIndexModelAdapter(), 7);
      _safeRegister(TherapeuticClassModelAdapter(), 8);
      _safeRegister(FavouriteModelAdapter(), 10);
    } catch (e, stack) {
      if (kDebugMode) {
        print("❌ Adapter registration failed: $e");
        print(stack);
      }
    }
  }

  /// Private helper: safely register adapter if not already registered
  void _safeRegister<T>(TypeAdapter<T> adapter, int typeId) {
    if (!Hive.isAdapterRegistered(typeId)) {
      Hive.registerAdapter(adapter);
      if (kDebugMode) print("✅ Adapter registered: ${adapter.runtimeType}");
    } else {
      if (kDebugMode) print("ℹ️ Adapter already registered: ${adapter.runtimeType}");
    }
  }

}