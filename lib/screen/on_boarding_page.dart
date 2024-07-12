import 'package:flutter/material.dart';
import 'package:vote2u_admin/screen/auth/auth_preferences.dart';
import 'package:vote2u_admin/screen/auth/login_page.dart';
import 'package:vote2u_admin/screen/auth/signup_page.dart';
import 'package:vote2u_admin/screen/home_page.dart';
import 'package:vote2u_admin/utils/constants.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({super.key});

  @override
  Widget build(BuildContext context) {
    Future<bool> isLoggedInFuture = AuthPreferences.getUserLoggedInState();
    return FutureBuilder<bool>(
      future: isLoggedInFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        } else {
          final bool isLoggedIn = snapshot.data ?? false;
          if (isLoggedIn) {
            return const HomePage();
          } else {
            return Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'VOTE',
                      style: TextStyle(
                          color: darkPurple, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '2U',
                      style: TextStyle(
                          color: softPurple, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' ADMIN',
                      style: TextStyle(
                          color: darkPurple, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              body: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/Asset 6.png',
                        width: MediaQuery.of(context).size.width,
                      ),
                      const SizedBox(height: 50),
                      const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Empowerment at your fingertips!",
                              style: TextStyle(
                                color: darkPurple,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Participate in elections from the convenience\nof your smartphone. Your voice matters, and\nnow it's easier than ever to make it heard. ",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: darkPurple,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                print(
                                    'Get Started button pressed'); // Debug print
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SignUpPage(),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                width: double.infinity,
                                height: mediumSizeBox,
                                decoration: BoxDecoration(
                                  color: darkPurple,
                                  borderRadius: largeBorderRadius,
                                ),
                                child: const Center(
                                  child: Text(
                                    "Get Started",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                print('Login button pressed'); // Debug print
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
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
                                    "Login",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        }
      },
    );
  }
}
