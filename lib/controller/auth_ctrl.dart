import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/eng_point_list.dart';
import '../utilities/shared_preferences.dart';
import '../screen/main_screen.dart';
import '../screen/login_screen.dart';

class AuthCtrl extends GetxController {
  final SharedPref _sharedPref = SharedPref();
  
  final phoneController = TextEditingController();
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final status = await _sharedPref.getLoginStatus();
    isLoggedIn.value = status;
    if (status) {
      final phone = await _sharedPref.getUserPhone();
      if (phone != null) phoneController.text = phone;
    }
  }

  Future<void> login() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar(
        'Required', 
        'Please enter your phone number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final url = '${EngPoint.BASEURL}${EngPoint.Login}';
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'P-Auth-Token': _sharedPref.pToken,
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'phone': phoneController.text,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isSuccess = data['success']?.toString().trim().toLowerCase() == 'true' || 
                         data['success'] == true;
        
        if (isSuccess) {
          isLoggedIn.value = true;
          // PERSIST LOGIN DATA
          await _sharedPref.setLoginStatus(true);
          await _sharedPref.setUserPhone(phoneController.text);
          
          Get.snackbar(
            'Success', 
            'Welcome, ${data['name']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.8),
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
          );

          Future.delayed(const Duration(milliseconds: 500), () {
            Get.offAll(() => const MainScreen());
          });
        } else {
          Get.snackbar(
            'Login Failed', 
            data['message'] ?? 'Invalid phone number or account issue',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.orangeAccent,
            colorText: Colors.white,
          );
        }
      } else {
        Get.snackbar(
          'Error', 
          'Server error: ${response.statusCode}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error', 
        'Connection failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    // CLEAR PERSISTENT DATA
    await _sharedPref.setLoginStatus(false);
    // await _sharedPref.setUserPhone(''); // Optional: Keep phone for next login?
    
    phoneController.clear();
    Get.offAll(() => const LoginScreen());
    
    Get.snackbar(
      'Logged Out', 
      'You have been successfully logged out',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueGrey,
      colorText: Colors.white,
    );
  }

  void goToRegistration() {
    Get.snackbar('Info', 'Registration screen coming soon');
  }
}
