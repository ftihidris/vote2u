import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vote2u/firebase/firebase_auth_services.dart';
import 'package:vote2u/screen/auth/auth_preferences.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/utils/toast.dart';
import 'package:vote2u/utils/constants.dart';

class LoadingPage extends StatefulWidget {
  final String email;
  final bool isSignUp;

  const LoadingPage({
    super.key,
    required this.email,
    required this.isSignUp,
  });

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isEmailVerified = false;
  bool _canResendEmail = true; // Initially true to allow first send
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startEmailVerificationCheck();
  }

  void _startEmailVerificationCheck() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _checkEmailVerification();
    });
  }

  void _stopEmailVerificationCheck() {
    _timer?.cancel();
  }

  Future<void> _checkEmailVerification() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await currentUser.reload();
      if (!mounted) return;
      setState(() {
        _isEmailVerified = currentUser.emailVerified;
      });

      if (_isEmailVerified) {
        _stopEmailVerificationCheck();
        if (!mounted) return;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      
      if (!mounted) return;

      // Disable the button and show toast
      setState(() => _canResendEmail = false);
      showToast(message: "Verification email sent successfully.");
      
      // Enable the button after 5 seconds
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return;
      setState(() => _canResendEmail = true);
    } catch (e) {
      showToast(message: "Wait few seconds to resend email verification");
      if (kDebugMode) {
        print("Error sending email verification: $e");
      }
    }
  }

  @override
  void dispose() {
    _stopEmailVerificationCheck();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _isEmailVerified
      ? const HomePage()
      : Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 120),
                const CircularProgressIndicator(),
                const SizedBox(height: 30),
                const Text(
                  "You're almost there!",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "We sent an email to:",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.email,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Just click the email to complete the",
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  widget.isSignUp ? "Sign Up" : "Login",
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 50),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 17),
                  child: GestureDetector(
                    onTap: _canResendEmail ? _sendVerificationEmail : null,
                    child: Container(
                      width: double.infinity,
                      height: mediumSizeBox,
                      decoration: BoxDecoration(
                        color: _canResendEmail ? darkPurple : Colors.grey[300],
                        borderRadius: largeBorderRadius,
                      ),
                      child: const Center(
                        child: Text(
                          "Resend Email Verification",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 0, 30, 10),
                  child: GestureDetector(
                    onTap: () async {
                      try {
                        await FirebaseAuthService().signOut();
                        AuthPreferences.storeUserLoggedInState(false, false);
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/login', (route) => false);
                      } catch (e) {
                        if (kDebugMode) {
                          print('Error signing out: $e');
                        }
                        showToast(
                            message: 'An error occurred. Please try again later.');
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      height: mediumSizeBox,
                      decoration: BoxDecoration(
                        color: softPurple,
                        borderRadius: largeBorderRadius,
                      ),
                      child: const Center(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
}
