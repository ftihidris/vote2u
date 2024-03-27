import 'package:shared_preferences/shared_preferences.dart';


class AuthPreferences {
  static Future<void> storeUserLoggedInState(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  static Future<bool> getUserLoggedInState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
