import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vote2u/utils/auth_preferences.dart';
import 'home_screen.dart';
import 'login_page.dart'; // Import your login page

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    // Check if the user is logged in
    bool isLoggedIn = await AuthPreferences.getUserLoggedInState();
    // Navigate based on login status
    navigateToNextScreen(isLoggedIn);
  }

  void navigateToNextScreen(bool isLoggedIn) {
    // Replace HomeScreen with your home screen widget
    // Replace LoginPage with your login page widget
    Widget nextScreen = isLoggedIn ? const HomeScreen() : const LoginPage();

    // Simulate a delay for the splash screen
    Future.delayed(const Duration(seconds: 1), () {
      // Navigate to the next screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/4.png', // Replace with your image path
              width: 150,
            ),
            const SizedBox(height: 16),
            // Add any additional widgets as needed
          ],
        ),
      ),
    );
  }
}
