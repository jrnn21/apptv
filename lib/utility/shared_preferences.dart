// ignore_for_file: deprecated_member_use

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  Future<bool> saveUsername(String tel) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('tel', tel);
    return prefs.commit();
  }

  Future<String> getUsername() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final tel = prefs.getString('tel');
    if (tel == null) {
      return '';
    }
    return tel;
  }

  // void removeUser() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.remove('user');
  // }

  // Future<bool> saveTheme(bool dark) async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setString('darkMode', '$dark');
  //   return prefs.commit();
  // }

  // Future<bool> getTheme() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final themeCached = prefs.getString('darkMode');
  //   bool b = themeCached?.toLowerCase() == 'true';
  //   return b;
  // }
}
