import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/firebase/firebase_auth_services.dart';
import 'package:vote2u/screen/login_page.dart';
import 'package:vote2u/utils/form_container_widget.dart';
import 'package:vote2u/utils/toast.dart';
import 'package:vote2u/utils/auth_preferences.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final FirebaseAuthService _auth = FirebaseAuthService();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool isSigningUp = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
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
              controller: _usernameController,
              hintText: "Student ID",
              isPasswordField: false,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                 Expanded(
                  child: FormContainerWidget(controller: _firstNameController,
                  hintText: "First Name",
                  isPasswordField: false,
                  ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FormContainerWidget(
                      controller: _lastNameController,
                      hintText: "Last Name",
                      isPasswordField: false,
                      ),
                      ),
                      ],
                      ),
                      const SizedBox(
                        height: 10,
                         ),
            FormContainerWidget(
              controller: _emailController,
              hintText: "Email",
              isPasswordField: false,
            ),
            const SizedBox(
              height: 10,
            ),
            FormContainerWidget(
              controller: _passwordController,
              hintText: "Password",
              isPasswordField: true,
            ),
            const SizedBox(
              height: 30,
            ),
            GestureDetector(
              onTap: _signUp,
              child: Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 63, 41, 120),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: isSigningUp
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
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
                const Text("Already have an account?"),
                const SizedBox(
                  width: 5,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    "Login",
                    style: TextStyle(
                        color: Color.fromARGB(255, 63, 41, 120), fontWeight: FontWeight.bold),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
}
  void _signUp() async {
    setState(() {
      isSigningUp = true;
    });

    String email = _emailController.text;
    String password = _passwordController.text;
    String username = _usernameController.text;
    String firstName = _firstNameController.text;
    String lastName = _lastNameController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password, username, firstName, lastName);

    setState(() {
      isSigningUp = false;
    });

    if (user != null) {
      showToast(message: "User is successfully created");
      await AuthPreferences.storeUserLoggedInState(true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      showToast(message: "Some error happened");
    }
  }
}
