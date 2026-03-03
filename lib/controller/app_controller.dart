import 'package:get/get.dart';

class AppController extends GetxController {
  var selectedMenuItem = ''.obs;

  void navigateTo(String route) {
    selectedMenuItem.value = route;
    Get.toNamed('/$route');
  }
}