import 'dart:convert';
import 'package:http/http.dart' as http;
class GetApiCallCtrl{

  // Future getApiCall({required String token, required String url,required syncDate, required currentPage, required limit}) async {
  //   final uri = Uri.parse('$url');
  //
  //   try {
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         'X-Auth-Token': token,
  //         'Accept': 'application/json',
  //       },
  //       body: {
  //         'limit': limit.toString(),
  //         'date': syncDate,
  //         'page': currentPage.toString(),
  //       },
  //     );
  //
  //     if (response.statusCode == 200) {
  //       return json.decode(response.body) as Map<String, dynamic>;
  //     } else {
  //       print('❌ API Error: ${response.statusCode}');
  //       print('Body: ${response.body}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('❌ Exception: $e');
  //     return null;
  //   }
  // }
  Future<Map<String, dynamic>?> getApiCall({
    required String token,
    required String url,
    required String syncDate,  // Specify type
    required int currentPage,   // Specify type
    required int limit          // Specify type
  }) async {

    // Add query parameters to URL if needed
    final uri = Uri.parse(url).replace(
        queryParameters: {
          'limit': limit.toString(),
          'page': currentPage.toString(),
          if (syncDate.isNotEmpty) 'date': syncDate,
        }
    );

    try {
      print('📡 API Call: $uri');
      print('📤 Headers: X-Auth-Token: $token');
      print('📤 Body: limit=$limit, page=$currentPage, date=$syncDate');

      final response = await http.post(
        uri,
        headers: {
          'X-Auth-Token': token,
          'Accept': 'application/json',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'limit': limit.toString(),
          'date': syncDate,
          'page': currentPage.toString(),
        },
      );

      print('📥 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // Optional: Validate response structure
        if (responseData.containsKey('insert') &&
            responseData.containsKey('update') &&
            responseData.containsKey('delete')) {
          return responseData;
        } else {
          print('⚠️ Unexpected response structure: ${responseData.keys}');
          return responseData; // Still return but log warning
        }
      } else if (response.statusCode == 401) {
        print('🔐 Authentication failed - token might be expired');
        // You might want to refresh token here
        return null;
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception in getApiCall: $e');
      if (e is FormatException) {
        print('❌ JSON parsing error');
      } else if (e is http.ClientException) {
        print('❌ Network error');
      }
      return null;
    }
  }

  /// POST /getkey
  Future getKey({required url,pToken}) async {
    final uri = Uri.parse('$url');

    try {
      final response = await http.post(
        uri,
        headers: {
          'P-Auth-Token': '$pToken',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return getPrivateFromResponse(json.decode(response.body));
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Exception: $e');
      return null;
    }
  }

  String? getPrivateFromResponse(Map<String, dynamic> json) {
    // Check if "success" key exists and is "true"
    if (json['success']?.toString().toLowerCase() == 'true') {
      return json['private']?.toString();
    } else {
      return null;
    }
  }

}
