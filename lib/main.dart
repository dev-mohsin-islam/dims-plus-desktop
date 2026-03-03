import 'package:dims_desktop/controller/company_ctrl.dart';
import 'package:dims_desktop/screen/app_theme.dart';
import 'package:dims_desktop/screen/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'controller/app_controller.dart';
import 'controller/data_get_and_sync_ctrl.dart';
import 'database/hive_box_init.dart';
import 'database/hive_box_model_register.dart';
import 'database/hive_box_open.dart';
import 'models/brand/drug_brand_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controller/data_get_and_sync_ctrl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    WidgetsFlutterBinding.ensureInitialized();

  try{
    await HiveBoxInit().initHive();

    await AdapterRegister().registerAdapters();
    await HiveBoxOpen.instance.hiveBoxOpen();
  }catch(e){
    print(e);
  }
  runApp(const DimsApp());
}

class DimsApp extends StatelessWidget {
  const DimsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DIMS - Drug Information Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _AppRoot(),
    );
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    // Initialize the main data controller
    Get.put(DataGetAndSyncCtrl());
    return const MainScreen();
  }
}

// void main() async{
//   WidgetsFlutterBinding.ensureInitialized();
//
//   try{
//     await HiveBoxInit().initHive();
//
//     await AdapterRegister().registerAdapters();
//     await HiveBoxOpen.instance.hiveBoxOpen();
//   }catch(e){
//     print(e);
//   }
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   final AppController appController = Get.put(AppController());
//
//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       title: 'Drug Information System',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         fontFamily: 'Roboto',
//         appBarTheme: AppBarTheme(
//           elevation: 0,
//           centerTitle: false,
//         ),
//         // cardTheme: CardTheme(
//         //   elevation: 2,
//         //   shape: RoundedRectangleBorder(
//         //     borderRadius: BorderRadius.circular(12),
//         //   ),
//         // ),
//       ),
//       initialRoute: '/',
//       getPages: [
//         GetPage(name: '/', page: () => HomeView()),
//         GetPage(name: '/generics', page: () => GenericsView()),
//         GetPage(name: '/brands', page: () => BrandsView()),
//         GetPage(name: '/companies', page: () => CompaniesView()),
//         GetPage(name: '/drug-class', page: () => DrugClassView()),
//         GetPage(name: '/indication', page: () => IndicationView()),
//         GetPage(name: '/search-results', page: () {
//           final query = Get.parameters['query'] ?? '';
//           return SearchResultsView(searchQuery: query);
//         }),
//         GetPage(name: '/brand-detail', page: () {
//           final brand = Get.arguments as DrugBrandModel;
//           return BrandDetailView(brand: brand);
//         }),
//       ],
//       home: HomeView(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
//
// void main() {
//   runApp(const PharmaMarketApp());
// }
//
// class PharmaMarketApp extends StatelessWidget {
//   const PharmaMarketApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'PharmaMarket BD',
//       theme: ThemeData(
//         primaryColor: const Color(0xFF1e4b7a),
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF1e4b7a),
//           primary: const Color(0xFF1e4b7a),
//           secondary: const Color(0xFF2a6fa5),
//         ),
//         useMaterial3: true,
//       ),
//       home: const MainScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// // Demo Data Models
// class Product {
//   final String name;
//   final String brand;
//   final String generic;
//   final String company;
//   final double price;
//   final double discountedPrice;
//   final String imageUrl;
//   final int stock;
//   final bool hasDiscount;
//   final double discountPercentage;
//
//   Product({
//     required this.name,
//     required this.brand,
//     required this.generic,
//     required this.company,
//     required this.price,
//     required this.imageUrl,
//     this.stock = 50,
//     this.hasDiscount = false,
//     this.discountedPrice = 0,
//     this.discountPercentage = 0,
//   });
// }
//
// class Order {
//   final String id;
//   final String date;
//   final List<Map<String, dynamic>> items;
//   final double totalAmount;
//   final String status;
//   final Color statusColor;
//
//   Order({
//     required this.id,
//     required this.date,
//     required this.items,
//     required this.totalAmount,
//     required this.status,
//     required this.statusColor,
//   });
// }
//
// // Demo Data with Real Web Images
// final List<Product> demoProducts = [
//   Product(
//     name: 'Napa Extra',
//     brand: 'Napa',
//     generic: 'Paracetamol 500mg',
//     company: 'Beximco Pharma',
//     price: 120.50,
//     discountedPrice: 105.00,
//     imageUrl: 'https://www.beximcopharma.com.bd/storage/product/1675674817.webp',
//     hasDiscount: true,
//     discountPercentage: 13,
//   ),
//   Product(
//     name: 'Seclo 20mg',
//     brand: 'Seclo',
//     generic: 'Omeprazole',
//     company: 'Healthcare Pharma',
//     price: 250.00,
//     discountedPrice: 220.00,
//     imageUrl: 'https://www.squarepharma.com.bd/products/Seclo.jpg',
//     hasDiscount: true,
//     discountPercentage: 12,
//   ),
//   Product(
//     name: 'Fexo 120mg',
//     brand: 'Fexo',
//     generic: 'Fexofenadine',
//     company: 'Square Pharma',
//     price: 180.00,
//     imageUrl: 'https://www.squarepharma.com.bd/products/Fexo.jpg',
//     hasDiscount: false,
//   ),
//   Product(
//     name: 'Monas 10mg',
//     brand: 'Monas',
//     generic: 'Montelukast',
//     company: 'Incepta Pharma',
//     price: 300.00,
//     discountedPrice: 270.00,
//     imageUrl: 'https://inceptapharma.com/storage/products/1634567890.webp',
//     hasDiscount: true,
//     discountPercentage: 10,
//   ),
//   Product(
//     name: 'Ace 250mg',
//     brand: 'Ace',
//     generic: 'Cefalexin',
//     company: 'Renata Pharma',
//     price: 420.00,
//     imageUrl: 'https://www.renata-ltd.com/wp-content/uploads/2023/01/Ace-250.jpg',
//     hasDiscount: false,
//   ),
//   Product(
//     name: 'Rupa 10mg',
//     brand: 'Rupa',
//     generic: 'Rosuvastatin',
//     company: 'Aristopharma',
//     price: 550.00,
//     discountedPrice: 495.00,
//     imageUrl: 'https://aristopharma.com/storage/products/1678901234.webp',
//     hasDiscount: true,
//     discountPercentage: 10,
//   ),
//   Product(
//     name: 'Ciprocin 500mg',
//     brand: 'Ciprocin',
//     generic: 'Ciprofloxacin',
//     company: 'Square Pharma',
//     price: 220.00,
//     imageUrl: 'https://www.squarepharma.com.bd/products/Ciprocin.jpg',
//     hasDiscount: false,
//   ),
//   Product(
//     name: 'Omidon 10mg',
//     brand: 'Omidon',
//     generic: 'Domperidone',
//     company: 'Beximco Pharma',
//     price: 180.00,
//     discountedPrice: 160.00,
//     imageUrl: 'https://www.beximcopharma.com.bd/storage/product/1675674820.webp',
//     hasDiscount: true,
//     discountPercentage: 11,
//   ),
// ];
//
// final List<Order> demoOrders = [
//   Order(
//     id: 'ORD-2024-001',
//     date: '১৫ জানুয়ারি ২০২৪',
//     items: [
//       {'name': 'Napa Extra', 'quantity': 2, 'price': 105.00},
//       {'name': 'Seclo 20mg', 'quantity': 1, 'price': 220.00},
//     ],
//     totalAmount: 430.00,
//     status: 'ডেলিভারি সম্পন্ন',
//     statusColor: Colors.green,
//   ),
//   Order(
//     id: 'ORD-2024-002',
//     date: '২০ জানুয়ারি ২০২৪',
//     items: [
//       {'name': 'Fexo 120mg', 'quantity': 3, 'price': 180.00},
//     ],
//     totalAmount: 540.00,
//     status: 'অপেক্ষমান',
//     statusColor: Colors.orange,
//   ),
//   Order(
//     id: 'ORD-2024-003',
//     date: '২৫ জানুয়ারি ২০২৪',
//     items: [
//       {'name': 'Monas 10mg', 'quantity': 2, 'price': 270.00},
//       {'name': 'Ace 250mg', 'quantity': 1, 'price': 420.00},
//       {'name': 'Rupa 10mg', 'quantity': 1, 'price': 495.00},
//     ],
//     totalAmount: 1455.00,
//     status: 'প্রক্রিয়াধীন',
//     statusColor: Colors.blue,
//   ),
// ];
//
// // Main Screen with Bottom Navigation
// class MainScreen extends StatefulWidget {
//   const MainScreen({Key? key}) : super(key: key);
//
//   @override
//   State<MainScreen> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreen> {
//   int _selectedIndex = 0;
//
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const SearchScreen(),
//     const OrdersScreen(),
//     const ProfileScreen(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _screens[_selectedIndex],
//       bottomNavigationBar: NavigationBar(
//         selectedIndex: _selectedIndex,
//         onDestinationSelected: (index) {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         destinations: const [
//           NavigationDestination(
//             icon: Icon(Icons.home_outlined),
//             selectedIcon: Icon(Icons.home),
//             label: 'হোম',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.search_outlined),
//             selectedIcon: Icon(Icons.search),
//             label: 'অনুসন্ধান',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.shopping_bag_outlined),
//             selectedIcon: Icon(Icons.shopping_bag),
//             label: 'অর্ডার',
//           ),
//           NavigationDestination(
//             icon: Icon(Icons.person_outlined),
//             selectedIcon: Icon(Icons.person),
//             label: 'প্রোফাইল',
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Home Screen
// class HomeScreen extends StatelessWidget {
//   const HomeScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('ফার্মামার্কেট বিডি'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.notifications_outlined),
//             onPressed: () {},
//           ),
//           IconButton(
//             icon: const Icon(Icons.shopping_cart_outlined),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Banner Carousel
//             Container(
//               height: 180,
//               margin: const EdgeInsets.all(16),
//               child: PageView(
//                 children: [
//                   _buildBanner(
//                     '⚕️ স্বাস্থ্য সেবা আপনার দোরগোড়ায়',
//                     '২০% ছাড়ে আজই অর্ডার করুন',
//                     [const Color(0xFF1e4b7a), const Color(0xFF2a6fa5)],
//                   ),
//                   _buildBanner(
//                     '🆓 ফ্রি হোম ডেলিভারি',
//                     '৫০০ টাকার অর্ডারে',
//                     [const Color(0xFF2a6fa5), const Color(0xFF4a90e2)],
//                   ),
//                   _buildBanner(
//                     '💊 সব ধরনের ওষুধ',
//                     'প্রেসক্রিপশন ছাড়াই',
//                     [const Color(0xFF4a90e2), const Color(0xFF6a5acd)],
//                   ),
//                 ],
//               ),
//             ),
//
//             // Categories
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 'ব্রাউজ ক্যাটেগরি',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 12),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 children: [
//                   _buildCategoryChip('💊 ট্যাবলেট'),
//                   _buildCategoryChip('💉 সিরাপ'),
//                   _buildCategoryChip('🩹 অ্যান্টিবায়োটিক'),
//                   _buildCategoryChip('❤️ হার্টের ওষুধ'),
//                   _buildCategoryChip('🌡️ জ্বর-সর্দি'),
//                   _buildCategoryChip('🦠 অ্যান্টাসিড'),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // Discounted Products
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'ছাড়যুক্ত পণ্য',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                   ),
//                   Text(
//                     'সব দেখুন →',
//                     style: TextStyle(color: Color(0xFF1e4b7a)),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 260,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 itemCount: demoProducts.where((p) => p.hasDiscount).length,
//                 itemBuilder: (context, index) {
//                   final products = demoProducts.where((p) => p.hasDiscount).toList();
//                   final product = products[index];
//                   return _buildProductCard(product);
//                 },
//               ),
//             ),
//
//             const SizedBox(height: 24),
//
//             // All Products
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16),
//               child: Text(
//                 'সকল পণ্য',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//             ),
//             const SizedBox(height: 12),
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: demoProducts.length,
//               itemBuilder: (context, index) {
//                 return _buildProductListItem(context, demoProducts[index]);
//               },
//             ),
//             const SizedBox(height: 16),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBanner(String line1, String line2, List<Color> colors) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 8),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(16),
//         gradient: LinearGradient(
//           colors: colors,
//         ),
//       ),
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Text(
//               line1,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             Text(
//               line2,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 22,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildCategoryChip(String label) {
//     return Container(
//       margin: const EdgeInsets.only(right: 8),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(label),
//     );
//   }
//
//   Widget _buildProductCard(Product product) {
//     return Container(
//       width: 160,
//       margin: const EdgeInsets.only(right: 12),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Stack(
//               children: [
//                 ClipRRect(
//                   borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                   child: Image.network(
//                     product.imageUrl,
//                     height: 120,
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) {
//                       return Container(
//                         height: 120,
//                         color: Colors.grey[300],
//                         child: const Center(
//                           child: Icon(Icons.medical_services, size: 40, color: Colors.grey),
//                         ),
//                       );
//                     },
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) return child;
//                       return Container(
//                         height: 120,
//                         color: Colors.grey[200],
//                         child: const Center(
//                           child: CircularProgressIndicator(),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//                 if (product.hasDiscount)
//                   Positioned(
//                     top: 8,
//                     left: 8,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                       decoration: BoxDecoration(
//                         color: Colors.red,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       child: Text(
//                         '-${product.discountPercentage.toStringAsFixed(0)}%',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//             Padding(
//               padding: const EdgeInsets.all(8),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     product.name,
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   Text(
//                     product.generic,
//                     style: TextStyle(fontSize: 12, color: Colors.grey[600]),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 4),
//                   Row(
//                     children: [
//                       Text(
//                         '৳${product.hasDiscount ? product.discountedPrice.toStringAsFixed(0) : product.price.toStringAsFixed(0)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1e4b7a),
//                         ),
//                       ),
//                       if (product.hasDiscount) ...[
//                         const SizedBox(width: 4),
//                         Text(
//                           '৳${product.price.toStringAsFixed(0)}',
//                           style: TextStyle(
//                             fontSize: 11,
//                             color: Colors.grey[500],
//                             decoration: TextDecoration.lineThrough,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProductListItem(BuildContext context, Product product) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       child: ListTile(
//         leading: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Image.network(
//             product.imageUrl,
//             width: 50,
//             height: 50,
//             fit: BoxFit.cover,
//             errorBuilder: (context, error, stackTrace) {
//               return Container(
//                 width: 50,
//                 height: 50,
//                 color: Colors.grey[300],
//                 child: const Icon(Icons.medical_services, color: Colors.grey),
//               );
//             },
//           ),
//         ),
//         title: Text(product.name),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(product.generic),
//             Text('${product.company} | স্টক: ${product.stock}'),
//           ],
//         ),
//         trailing: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             Text(
//               '৳${product.hasDiscount ? product.discountedPrice.toStringAsFixed(0) : product.price.toStringAsFixed(0)}',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Color(0xFF1e4b7a),
//               ),
//             ),
//             if (product.hasDiscount)
//               Text(
//                 '৳${product.price.toStringAsFixed(0)}',
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey[500],
//                   decoration: TextDecoration.lineThrough,
//                 ),
//               ),
//           ],
//         ),
//         onTap: () {
//           _showProductDetails(context, product);
//         },
//       ),
//     );
//   }
//
//   void _showProductDetails(BuildContext context, Product product) {
//     int quantity = 1;
//     String selectedUnit = 'পিস';
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return StatefulBuilder(
//           builder: (context, setState) {
//             return Container(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom,
//                 left: 16,
//                 right: 16,
//                 top: 16,
//               ),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Container(
//                     width: 40,
//                     height: 4,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(2),
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Center(
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(12),
//                               child: Image.network(
//                                 product.imageUrl,
//                                 height: 200,
//                                 width: 200,
//                                 fit: BoxFit.cover,
//                                 errorBuilder: (context, error, stackTrace) {
//                                   return Container(
//                                     height: 200,
//                                     width: 200,
//                                     color: Colors.grey[300],
//                                     child: const Icon(Icons.medical_services, size: 80, color: Colors.grey),
//                                   );
//                                 },
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           Text(
//                             product.name,
//                             style: const TextStyle(
//                               fontSize: 24,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           _buildInfoRow('ব্র্যান্ড', product.brand),
//                           _buildInfoRow('জেনেরিক', product.generic),
//                           _buildInfoRow('কোম্পানি', product.company),
//                           const SizedBox(height: 16),
//                           Row(
//                             children: [
//                               const Text(
//                                 'মূল্য: ',
//                                 style: TextStyle(fontSize: 18),
//                               ),
//                               if (product.hasDiscount) ...[
//                                 Text(
//                                   '৳${product.discountedPrice.toStringAsFixed(2)}',
//                                   style: const TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF1e4b7a),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(
//                                   '৳${product.price.toStringAsFixed(2)}',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[500],
//                                     decoration: TextDecoration.lineThrough,
//                                   ),
//                                 ),
//                               ] else
//                                 Text(
//                                   '৳${product.price.toStringAsFixed(2)}',
//                                   style: const TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                     color: Color(0xFF1e4b7a),
//                                   ),
//                                 ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'পরিমাণের একক:',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               _buildUnitChip('বক্স', selectedUnit == 'বক্স', (){
//                                 setState(() => selectedUnit = 'বক্স');
//                               }),
//                               _buildUnitChip('প্যাক', selectedUnit == 'প্যাক', (){
//                                 setState(() => selectedUnit = 'প্যাক');
//                               }),
//                               _buildUnitChip('পিস', selectedUnit == 'পিস', (){
//                                 setState(() => selectedUnit = 'পিস');
//                               }),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'পরিমাণ:',
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Container(
//                                 decoration: BoxDecoration(
//                                   border: Border.all(color: Colors.grey[300]!),
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Row(
//                                   children: [
//                                     IconButton(
//                                       icon: const Icon(Icons.remove),
//                                       onPressed: () {
//                                         if (quantity > 1) {
//                                           setState(() => quantity--);
//                                         }
//                                       },
//                                     ),
//                                     Text('$quantity', style: const TextStyle(fontSize: 16)),
//                                     IconButton(
//                                       icon: const Icon(Icons.add),
//                                       onPressed: () {
//                                         setState(() => quantity++);
//                                       },
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               const SizedBox(width: 16),
//                               Expanded(
//                                 child: ElevatedButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       SnackBar(
//                                         content: Text('${product.name} ($quantity $selectedUnit) কার্টে যোগ করা হয়েছে'),
//                                         behavior: SnackBarBehavior.floating,
//                                       ),
//                                     );
//                                   },
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFF1e4b7a),
//                                     foregroundColor: Colors.white,
//                                     padding: const EdgeInsets.symmetric(vertical: 12),
//                                   ),
//                                   child: const Text('কার্টে যোগ করুন'),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 16),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
//
//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 2),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 80,
//             child: Text(
//               '$label:',
//               style: const TextStyle(fontWeight: FontWeight.bold),
//             ),
//           ),
//           Expanded(
//             child: Text(value),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildUnitChip(String label, bool isSelected, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.only(right: 8),
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFF1e4b7a) : Colors.grey[200],
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? Colors.white : Colors.black,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // Search Screen
// class SearchScreen extends StatefulWidget {
//   const SearchScreen({Key? key}) : super(key: key);
//
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }
//
// class _SearchScreenState extends State<SearchScreen> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Product> _searchResults = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _searchResults = demoProducts;
//   }
//
//   void _performSearch(String query) {
//     setState(() {
//       if (query.isEmpty) {
//         _searchResults = demoProducts;
//       } else {
//         _searchResults = demoProducts.where((product) =>
//         product.name.toLowerCase().contains(query.toLowerCase()) ||
//             product.generic.toLowerCase().contains(query.toLowerCase()) ||
//             product.brand.toLowerCase().contains(query.toLowerCase()) ||
//             product.company.toLowerCase().contains(query.toLowerCase())
//         ).toList();
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('পণ্য অনুসন্ধান'),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: TextField(
//               controller: _searchController,
//               onChanged: _performSearch,
//               decoration: InputDecoration(
//                 hintText: 'ওষুধের নাম, ব্র্যান্ড বা কোম্পানি লিখুন...',
//                 prefixIcon: const Icon(Icons.search),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 filled: true,
//                 fillColor: Colors.white,
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               itemCount: _searchResults.length,
//               itemBuilder: (context, index) {
//                 return Card(
//                   margin: const EdgeInsets.only(bottom: 8),
//                   child: ListTile(
//                     leading: ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.network(
//                         _searchResults[index].imageUrl,
//                         width: 50,
//                         height: 50,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return Container(
//                             width: 50,
//                             height: 50,
//                             color: Colors.grey[300],
//                             child: const Icon(Icons.medical_services, color: Colors.grey),
//                           );
//                         },
//                       ),
//                     ),
//                     title: Text(_searchResults[index].name),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('ব্র্যান্ড: ${_searchResults[index].brand}'),
//                         Text('কোম্পানি: ${_searchResults[index].company}'),
//                       ],
//                     ),
//                     trailing: Text(
//                       '৳${_searchResults[index].hasDiscount ? _searchResults[index].discountedPrice.toStringAsFixed(0) : _searchResults[index].price.toStringAsFixed(0)}',
//                       style: const TextStyle(
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF1e4b7a),
//                       ),
//                     ),
//                     onTap: () {},
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // Orders Screen
// class OrdersScreen extends StatelessWidget {
//   const OrdersScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('আমার অর্ডার'),
//       ),
//       body: ListView.builder(
//         padding: const EdgeInsets.all(16),
//         itemCount: demoOrders.length,
//         itemBuilder: (context, index) {
//           final order = demoOrders[index];
//           return Card(
//             margin: const EdgeInsets.only(bottom: 12),
//             child: ExpansionTile(
//               leading: Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: order.statusColor.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.shopping_bag_outlined,
//                   color: order.statusColor,
//                 ),
//               ),
//               title: Text(
//                 order.id,
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//               subtitle: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text('তারিখ: ${order.date}'),
//                   const SizedBox(height: 4),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                     decoration: BoxDecoration(
//                       color: order.statusColor.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(4),
//                     ),
//                     child: Text(
//                       order.status,
//                       style: TextStyle(
//                         color: order.statusColor,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               children: [
//                 const Divider(),
//                 ...order.items.map((item) => Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text('${item['name']} x${item['quantity']}'),
//                       Text('৳${(item['quantity'] * item['price']).toStringAsFixed(0)}'),
//                     ],
//                   ),
//                 )),
//                 const Divider(),
//                 Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'মোট:',
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                       Text(
//                         '৳${order.totalAmount.toStringAsFixed(2)}',
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1e4b7a),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 if (order.status == 'অপেক্ষমান')
//                   Padding(
//                     padding: const EdgeInsets.all(16),
//                     child: SizedBox(
//                       width: double.infinity,
//                       child: OutlinedButton(
//                         onPressed: () {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(
//                               content: Text('অর্ডার বাতিলের অনুরোধ করা হয়েছে'),
//                               behavior: SnackBarBehavior.floating,
//                             ),
//                           );
//                         },
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           side: const BorderSide(color: Colors.red),
//                         ),
//                         child: const Text('অর্ডার বাতিল করুন'),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // Profile Screen
// class ProfileScreen extends StatelessWidget {
//   const ProfileScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('আমার প্রোফাইল'),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // Profile Header
//             const CircleAvatar(
//               radius: 50,
//               backgroundColor: Color(0xFF1e4b7a),
//               child: Text(
//                 'রহিম',
//                 style: TextStyle(fontSize: 24, color: Colors.white),
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'মোঃ রহিম মিয়া',
//               style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//             ),
//             const Text(
//               '+৮৮০ ১৭১২-৩৪৫৬৭৮',
//               style: TextStyle(fontSize: 16, color: Colors.grey),
//             ),
//             const SizedBox(height: 24),
//
//             // Profile Menu Items
//             _buildProfileMenuItem(
//               icon: Icons.person_outline,
//               title: 'প্রোফাইল তথ্য',
//               onTap: () {},
//             ),
//             _buildProfileMenuItem(
//               icon: Icons.location_on_outlined,
//               title: 'ঠিকানা',
//               onTap: () {},
//             ),
//             _buildProfileMenuItem(
//               icon: Icons.shopping_bag_outlined,
//               title: 'আমার অর্ডার',
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(builder: (context) => const OrdersScreen()),
//                 );
//               },
//             ),
//             _buildProfileMenuItem(
//               icon: Icons.favorite_border,
//               title: 'পছন্দের তালিকা',
//               onTap: () {},
//             ),
//             const Divider(height: 32),
//
//             // Help Line Section
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Row(
//                     children: [
//                       Icon(Icons.support_agent, color: Color(0xFF1e4b7a)),
//                       SizedBox(width: 8),
//                       Text(
//                         'হেল্প লাইন',
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF1e4b7a),
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   ListTile(
//                     leading: const Icon(Icons.phone, color: Colors.green),
//                     title: const Text('০১৭১২-৩৪৫৬৭৮'),
//                     onTap: () {},
//                   ),
//                   ListTile(
//                     leading: const Icon(Icons.email, color: Colors.red),
//                     title: const Text('support@pharmamarket.com.bd'),
//                     onTap: () {},
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),
//
//             // Logout Button
//             OutlinedButton(
//               onPressed: () {
//                 _showLoginSheet(context);
//               },
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: Colors.red,
//                 side: const BorderSide(color: Colors.red),
//                 minimumSize: const Size(double.infinity, 50),
//               ),
//               child: const Text('লগআউট'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildProfileMenuItem({
//     required IconData icon,
//     required String title,
//     required VoidCallback onTap,
//   }) {
//     return ListTile(
//       leading: Icon(icon, color: const Color(0xFF1e4b7a)),
//       title: Text(title),
//       trailing: const Icon(Icons.arrow_forward_ios, size: 16),
//       onTap: onTap,
//     );
//   }
//
//   void _showLoginSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//             left: 16,
//             right: 16,
//             top: 16,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: Colors.grey[300],
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'লগইন / রেজিস্ট্রেশন',
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 20),
//               TextField(
//                 decoration: InputDecoration(
//                   labelText: 'ফোন নম্বর বা ইমেইল',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: const Icon(Icons.person_outline),
//                 ),
//               ),
//               const SizedBox(height: 12),
//               TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                   labelText: 'পাসওয়ার্ড',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   prefixIcon: const Icon(Icons.lock_outline),
//                 ),
//               ),
//               const SizedBox(height: 8),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton(
//                   onPressed: () {},
//                   child: const Text('পাসওয়ার্ড ভুলে গেছেন?'),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('সফলভাবে লগইন হয়েছে'),
//                       behavior: SnackBarBehavior.floating,
//                     ),
//                   );
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF1e4b7a),
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 50),
//                 ),
//                 child: const Text('লগইন'),
//               ),
//               const SizedBox(height: 12),
//               Row(
//                 children: [
//                   Expanded(
//                     child: OutlinedButton(
//                       onPressed: () {},
//                       style: OutlinedButton.styleFrom(
//                         minimumSize: const Size(double.infinity, 50),
//                       ),
//                       child: const Text('নিবন্ধন'),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }