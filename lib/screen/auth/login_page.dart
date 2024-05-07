import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vote2u/screen/auth/loading_page.dart';
import 'package:vote2u/screen/auth/signup_page.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/utils/toast.dart';
import 'package:vote2u/utils/form_container_widget.dart';
import 'package:vote2u/screen/auth/auth_preferences.dart';
import 'package:vote2u/utils/constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isSigning = false;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/2.png',
                    width: 200,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50),
            FormContainerWidget(
              controller: _emailController,
              hintText: "Email",
              isPasswordField: false,
            ),
            const SizedBox(height: 10,),
            FormContainerWidget(
              controller: _passwordController,
              hintText: "Password",
              isPasswordField: true,
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: () {
                _signIn();
              },
              child: Container(
                width: double.infinity,
                height: mediumSizeBox,
                decoration: BoxDecoration(
                  color: darkPurple,
                  borderRadius: largeBorderRadius,
                ),
                child: Center(
                  child: _isSigning ? const CircularProgressIndicator(color: Colors.white) : const Text(
                    "Login",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
              ),
            GestureDetector(
              onTap: () {
                _signInWithGoogle();
              },
              child: Container(
                width: double.infinity,
                height: mediumSizeBox,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: largeBorderRadius,
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.google, color: Colors.white,),
                      SizedBox(width: 5,),
                      Text(
                        "Sign in with Google",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account?"),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpPage()),
                          (route) => false,
                    );
                  },
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      color: darkPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _signIn() async {
    setState(() {
      _isSigning = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;

    try {
      UserCredential userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      setState(() {
        _isSigning = false;
      });

      if (userCredential.user != null) {
        await AuthPreferences.storeUserLoggedInState(true, true);
        showToast(message: "User is successfully signed in");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoadingPage(email: email, isSignUp: true)),
        );
      } else {
        showToast(message: "Sign in failed");
      }
    } catch (e) {
      showToast(message: "Sign in failed: $e");
      setState(() {
        _isSigning = false;
      });
    }
  }

void _signInWithGoogle() async {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  try {
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      // Check if the user's email ends with "@uitm.edu.my"
      if (!googleSignInAccount.email.endsWith(studentEmailDomain)) {
        showToast(message: 'Please sign in with a UITM Google account.');
        return;
      }

      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      await _firebaseAuth.signInWithCredential(credential);

      // Check if the user is already signed in with Firebase before navigating
      final User? user = _firebaseAuth.currentUser;
      if (user != null) {
        await AuthPreferences.storeUserLoggedInState(true, false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      }
    }
  } catch (e) {
    showToast(message: "Sign in with Google failed: $e");
  }
}

}