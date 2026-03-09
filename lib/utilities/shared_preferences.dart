
import 'package:shared_preferences/shared_preferences.dart';

class SharedPref{
  final String pToken = 'St@g1ngDIMS';
  final String brandPref = 'brandPref';
  final String companyPref = 'companyPref';
  final String genericPref = 'genericPref';
  final String indicationPref = 'indicationPref';
  final String indicationGenIndPref = 'indicationGenIndPref';
  final String systemPref = 'systemPref';
  final String therapeuticPref = 'therapeuticPref';
  final String therapeuticGenIndPref = 'therapeuticGenIndPref';
  final String pregnancyPref = 'pregnancyPref';
  final String loginStatusPref = 'isLoggedIn';
  final String userPhonePref = 'userPhone';

  Future<void> setLoginStatus(bool status) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginStatusPref, status);
  }

  Future<bool> getLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginStatusPref) ?? false;
  }

  Future<void> setUserPhone(String phone) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(userPhonePref, phone);
  }

  Future<String?> getUserPhone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userPhonePref);
  }

  Future<void> storeLastSyncDateString(String key, String date)async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, date);
  }
  Future<void>storeLastSyncDateInt(String key, int page)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, page);
  }
  Future<String>getLastSyncDate(key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '2002-01-01';
  }
  Future<int>getLastSyncPage(key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 1;
  }
  Future<void>clearLastSyncDate(String key)async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}