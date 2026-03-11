import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../services/eng_point_list.dart';
import '../services/get_api_call.dart';
import '../utilities/shared_preferences.dart';
import '../screen/main_screen.dart';
import '../screen/login_screen.dart';
import '../screen/registration_screen.dart';

class AuthCtrl extends GetxController {
  final SharedPref _sharedPref = SharedPref();
  final GetApiCallCtrl _getApiCallCtrl = GetApiCallCtrl();
  
  final phoneController = TextEditingController();
  var isLoading = false.obs;
  var isLoggedIn = false.obs;

  // User profile data
  var userId = ''.obs;
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var userOccupation = ''.obs;
  var userSpecialty = ''.obs;
  var userOrganization = ''.obs;
  var userBmdc = ''.obs;
  var userQualification = ''.obs;
  var userDesignation = ''.obs;
  var userBmdcType = '0'.obs;

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
      if (phone != null) {
        phoneController.text = phone;
        userPhone.value = phone;
      }
    }
  }

  Future<void> login() async {
    if (phoneController.text.isEmpty) {
      Get.snackbar('Required', 'Please enter your phone number',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
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
        },
        body: {'phone': phoneController.text},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final isSuccess = data['success']?.toString().trim().toLowerCase() == 'true' || data['success'] == true;
        
        if (isSuccess) {
          isLoggedIn.value = true;
          await _sharedPref.setLoginStatus(true);
          await _sharedPref.setUserPhone(phoneController.text);
          
          if (data['data'] != null) {
            final u = data['data'];
            userId.value = u['id']?.toString() ?? '';
            userName.value = u['name'] ?? '';
            userEmail.value = u['email'] ?? '';
            userPhone.value = u['phone'] ?? phoneController.text;
            userOccupation.value = u['occupation'] ?? '';
            userSpecialty.value = u['specialty'] ?? '';
            userOrganization.value = u['organization'] ?? '';
            userBmdc.value = u['bmdc'] ?? '';
            userQualification.value = u['qualification'] ?? '';
            userDesignation.value = u['dsignation'] ?? '';
            userBmdcType.value = u['bmdc_type']?.toString() ?? '0';
          }

          Get.snackbar('Success', 'Welcome back!', 
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);

          Future.delayed(const Duration(milliseconds: 500), () {
            Get.offAll(() => const MainScreen());
          });
        } else {
          Get.snackbar('Login Failed', data['message'] ?? 'Invalid phone number',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orangeAccent, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e',
        snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(Map<String, String> data) async {
    isLoading.value = true;

    try {

      String token = _sharedPref.pToken;

      print("Request Data: $data");
      print("P-Auth-Token: $token");

      var request = http.MultipartRequest(
        'POST',
        Uri.parse("${EngPoint.BASEURL}${EngPoint.Registration}"),
      );

      /// headers (same as postman)
      request.headers.addAll({
        "P-Auth-Token": token,
        "Accept": "application/json",
      });

      /// form-data fields
      request.fields.addAll({
        "name": data['name'] ?? "",
        "email": data['email'] ?? "",
        "phone": data['phone'] ?? "",
        "occupation": data['occupation'] ?? "",
        "specialty": data['specialty'] ?? "",
        "organization": data['organization'] ?? "",
        "bmdc": data['bmdc'] ?? "",
        "qualification": data['qualification'] ?? "",
        "designation": data['designation'] ?? "",
        "bmdc_type": data['bmdc_type'] ?? "",
      });

      /// send request
      var response = await request.send();

      /// convert response
      var responseBody = await response.stream.bytesToString();

      print("Status Code: ${response.statusCode}");
      print("Response Body: $responseBody");

      if (response.statusCode == 200) {

        final respData = json.decode(responseBody);

        if (respData['success']?.toString().toLowerCase() == 'true') {

          Get.snackbar(
            "Success",
            "Registration successful! Please login.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          Get.back();

        } else {

          Get.snackbar(
            "Error",
            respData['message'] ?? "Registration failed",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );

        }

      } else {

        Get.snackbar(
          "Error",
          "Server Error: ${response.statusCode}",
          snackPosition: SnackPosition.BOTTOM,
        );

      }

    } catch (e) {

      print("Error: $e");

      Get.snackbar(
        "Error",
        "Connection failed: $e",
        snackPosition: SnackPosition.BOTTOM,
      );

    } finally {

      isLoading.value = false;

    }
  }

  Future<void> updateProfile(Map<String, String> data) async {
    isLoading.value = true;
    try {
      if (!data.containsKey('userid')) data['userid'] = userId.value;

      String token = _sharedPref.pToken;
      var getKey;
      try {
        getKey = await _getApiCallCtrl.getKey(
          url: "${EngPoint.BASEURL}${EngPoint.Getkey}",
          pToken: token
        );
      } catch (e) {
        Get.snackbar('Error', "Failed to secure connection: $e");
        isLoading.value = false;
        return;
      }

      final response = await http.post(
        Uri.parse("${EngPoint.BASEURL}${EngPoint.ProfileUpdate}"),
        headers: {
          'X-Auth-Token': getKey.toString(),
          'Accept': 'application/json',
        },
        body: data,
      );

      if (response.statusCode == 200) {
        final respData = json.decode(response.body);
        if (respData['success']?.toString().toLowerCase() == 'true') {
          Get.snackbar('Success', 'Profile updated successfully',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);

          userName.value = data['name'] ?? userName.value;
          userEmail.value = data['email'] ?? userEmail.value;
          userPhone.value = data['phone'] ?? userPhone.value;
          userOccupation.value = data['occupation'] ?? userOccupation.value;
          userSpecialty.value = data['specialty'] ?? userSpecialty.value;
          userOrganization.value = data['organization'] ?? userOrganization.value;
          userBmdc.value = data['bmdc'] ?? userBmdc.value;
          userQualification.value = data['qualification'] ?? userQualification.value;
          userDesignation.value = data['dsignation'] ?? userDesignation.value;
          userBmdcType.value = data['bmdc_type'] ?? userBmdcType.value;
          isLoggedIn.value = true;
          await _sharedPref.setLoginStatus(true);
          await _sharedPref.setUserPhone(phoneController.text);

          Get.snackbar('Success', 'Welcome back!',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.withOpacity(0.8), colorText: Colors.white);

          Future.delayed(const Duration(milliseconds: 500), () {
            Get.offAll(() => const MainScreen());
          });
        } else {
          String errorMsg = parseErrorMessage(respData['message']);

          Get.snackbar(
            "Error",
            errorMsg,
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Connection failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoggedIn.value = false;
    await _sharedPref.setLoginStatus(false);
    phoneController.clear();
    Get.offAll(() => const LoginScreen());
  }

  void goToRegistration() {
    Get.to(() => const RegistrationScreen());
  }
  String parseErrorMessage(dynamic message) {
    if (message is String) {
      return message;
    }

    if (message is Map) {
      List<String> errors = [];

      message.forEach((key, value) {
        if (value is List) {
          errors.addAll(value.map((e) => e.toString()));
        } else {
          errors.add(value.toString());
        }
      });

      return errors.join("\n");
    }

    return "Something went wrong";
  }
}
