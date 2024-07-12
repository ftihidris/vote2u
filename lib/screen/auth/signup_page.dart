import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vote2u_admin/screen/auth/loading_page.dart';
import 'package:vote2u_admin/firebase/firebase_auth_services.dart';
import 'package:vote2u_admin/screen/auth/login_page.dart';
import 'package:vote2u_admin/utils/form_container_widget.dart';
import 'package:vote2u_admin/utils/toast.dart';
import 'package:vote2u_admin/screen/auth/auth_preferences.dart';
import 'package:vote2u_admin/utils/constants.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

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
  void initState() {
    super.initState();
    _usernameController.addListener(_updateEmail);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _updateEmail() {
    String username = _usernameController.text;
    _emailController.text = '$username@student.uitm.edu.my';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
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
                Row(
                  children: [
                    Expanded(
                      child: FormContainerWidget(
                        controller: _firstNameController,
                        hintText: "First Name",
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FormContainerWidget(
                        controller: _lastNameController,
                        hintText: "Last Name",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _usernameController,
                  hintText: "Student ID",
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _emailController,
                  hintText: "Email",
                ),
                const SizedBox(height: 10),
                FormContainerWidget(
                  controller: _passwordController,
                  hintText: "Password",
                  isPasswordField: true,
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: _signUp,
                  child: Container(
                    width: double.infinity,
                    height: mediumSizeBox,
                    decoration: BoxDecoration(
                      color: darkPurple,
                      borderRadius: largeBorderRadius,
                    ),
                    child: Center(
                      child: isSigningUp
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Sign Up",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account?"),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      child: const Text(
                        "Login",
                        style: TextStyle(
                            color: darkPurple, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

    User? user = await _auth.signUpWithEmailAndPassword(
        email, password, username, firstName, lastName);

    setState(() {
      isSigningUp = false;
    });

    if (user != null) {
      showToast(message: "User is successfully created");
      await AuthPreferences.storeUserLoggedInState(true, true);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => LoadingPage(email: email, isSignUp: true)),
      );
    }
  }
}
