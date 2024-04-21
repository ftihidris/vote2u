import 'package:flutter/material.dart';
import 'package:vote2u/screen/auth/auth_preferences.dart';
import 'package:vote2u/screen/auth/login_page.dart';
import 'package:vote2u/screen/auth/signup_page.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/utils/constants.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    Future<bool> isLoggedInFuture = AuthPreferences.getUserLoggedInState();
    return FutureBuilder<bool>(
      future: isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // If the future is not completed yet, show a loading indicator
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          // If an error occurred, show an error message
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          // If the future completed successfully
          final bool isLoggedIn = snapshot.data ?? false;
          if (isLoggedIn) {
            // If the user is logged in, navigate to the main content screen
            return HomePage();
          } else {
            // If the user is not logged in, show the login and signup buttons
            return Scaffold(
              body: Stack(
                children: [
                  Container(
                    color: Colors.white,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: SizedBox(
                            width: 250,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    darkPurple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: 17), // Added SizedBox for spacing
                        Center(
                          child: SizedBox(
                            width: 250,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const SignUpPage(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    softPurple,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/4.png', // Replace with your image path
                          width: 260,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        }
      },
    );
  }
}
