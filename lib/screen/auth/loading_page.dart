import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/utils/toast.dart';
import 'package:vote2u/utils/constants.dart';

class LoadingPage extends StatefulWidget {
  final String email;
  final bool isSignUp;

  const LoadingPage({
    Key? key,
    required this.email,
    required this.isSignUp,
  }) : super(key: key);

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isEmailVerified = false;
  bool _canResendEmail = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _checkEmailVerification();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
    void _checkEmailVerified() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await currentUser.reload(); // Reload user data to get the latest email verification status
      setState(() {
        _isEmailVerified = currentUser.emailVerified;
      });
      if (!_isEmailVerified) {
        _setupTimer(); // Start timer if email is not verified
        _sendVerificationEmail(); // Send verification email if not already verified
      }
    }
  }

  void _checkEmailVerification() {
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!_isEmailVerified) {
      _setupTimer();
      _sendVerificationEmail();
    }
  }

  void _setupTimer() {
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      _checkEmailVerified();
    });
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      setState(() => _canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => _canResendEmail = true);
    } catch (e) {
      showToast(message: "Some error occurred");
    }
  }

  @override
  Widget build(BuildContext context) => _isEmailVerified
      ? HomePage()
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
                        color: darkPurple,
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
                      await FirebaseAuth.instance.signOut();  
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false); // Close the loading page and return to the previous page
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
