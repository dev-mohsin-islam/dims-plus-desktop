// // lib/utils/routes.dart
// import 'package:get/get.dart';
// import '../views/home/home_screen.dart';
// import '../views/medicines/generics_list_screen.dart';
// import '../views/medicines/generic_details_screen.dart';
// import '../views/medicines/brands_list_screen.dart';
// import '../views/medicines/brand_details_screen.dart';
// import '../views/medicines/companies_list_screen.dart';
// import '../views/drug_class/therapeutic_class_list_screen.dart';
// import '../views/drug_class/systemic_class_list_screen.dart';
// import '../views/drug_class/generics_by_class_screen.dart';
// import '../views/indication/indication_list_screen.dart';
// import '../views/indication/indication_generic_list_screen.dart';
// import '../views/search/global_search_results_screen.dart';
//
// class AppRoutes {
//   static const String home = '/';
//   static const String generics = '/generics';
//   static const String genericDetails = '/generic-details';
//   static const String brands = '/brands';
//   static const String brandsByGeneric = '/brands-by-generic';
//   static const String brandDetails = '/brand-details';
//   static const String companies = '/companies';
//   static const String companyBrands = '/company-brands';
//   static const String drugClass = '/drug-class';
//   static const String systemicClasses = '/systemic-classes';
//   static const String genericsByClass = '/generics-by-class';
//   static const String indications = '/indications';
//   static const String indicationGenerics = '/indication-generics';
//   static const String searchResults = '/search-results';
//   static const String otherBrands = '/other-brands';
//
//   static List<GetPage> routes = [
//     GetPage(name: home, page: () => HomeScreen()),
//     GetPage(name: generics, page: () => GenericsListScreen()),
//     GetPage(name: genericDetails, page: () => GenericDetailsScreen()),
//     GetPage(name: brands, page: () => BrandsListScreen()),
//     GetPage(name: brandsByGeneric, page: () => BrandsListScreen()),
//     GetPage(name: brandDetails, page: () => BrandDetailsScreen()),
//     GetPage(name: companies, page: () => CompaniesListScreen()),
//     GetPage(name: companyBrands, page: () => BrandsListScreen()),
//     GetPage(name: drugClass, page: () => TherapeuticClassListScreen()),
//     GetPage(name: systemicClasses, page: () => SystemicClassListScreen()),
//     GetPage(name: genericsByClass, page: () => BrandsListScreen()),
//     GetPage(name: indications, page: () => IndicationListScreen()),
//     GetPage(name: indicationGenerics, page: () => BrandsListScreen()),
//     GetPage(name: searchResults, page: () => GlobalSearchResultsScreen()),
//     GetPage(name: otherBrands, page: () => BrandsListScreen()),
//   ];
// }