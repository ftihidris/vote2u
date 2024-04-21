import 'package:shared_preferences/shared_preferences.dart';

class AuthPreferences {
  static Future<void> storeUserLoggedInState(bool isLoggedIn, bool isEmailVerified) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', isLoggedIn);
    await prefs.setBool('isEmailVerified', isEmailVerified);
  }

  static Future<bool> getUserLoggedInState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<bool> isEmailVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isEmailVerified') ?? false;
  }
}
