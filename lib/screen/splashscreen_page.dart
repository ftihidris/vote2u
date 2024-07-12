import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vote2u/screen/auth/auth_preferences.dart';
import 'package:vote2u/screen/on_boarding_page.dart';
import 'package:vote2u/screen/auth/login_page.dart'; 

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    try {
      // Check if the user is logged in
      bool isLoggedIn = await AuthPreferences.getUserLoggedInState();
      if (kDebugMode) {
        print('User logged in status: $isLoggedIn');
      } // Add logging

      // Navigate based on login status
      navigateToNextScreen(isLoggedIn);
    } catch (error) {
      if (kDebugMode) {
        print('Error checking login status: $error');
      } // Add error handling
      // Navigate to login page in case of error
      navigateToNextScreen(false);
    }
  }

  void navigateToNextScreen(bool isLoggedIn) {
    // Determine the next screen based on login status
    Widget nextScreen = isLoggedIn ? const GetStarted() : const LoginPage();

    // If the user is not logged in, redirect them to the HomeScreen
    if (!isLoggedIn) {
      nextScreen = const GetStarted();
    }

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
              'assets/images/4.png', 
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
