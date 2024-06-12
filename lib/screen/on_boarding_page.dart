import 'package:flutter/material.dart';
import 'package:vote2u/screen/auth/auth_preferences.dart';
import 'package:vote2u/screen/auth/login_page.dart';
import 'package:vote2u/screen/auth/signup_page.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/utils/constants.dart';

class GetStarted extends StatelessWidget {
  const GetStarted({Key? key}) : super(key: key);

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
                  children: [
                    Text(
                      'VOTE',
                      style: TextStyle(color: darkPurple, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '2U',
                      style: TextStyle(color: softPurple, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              body: Column(
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
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
            );
          }
        }
      },
    );
  }
}

class PageBuilderWidget extends StatelessWidget {
  final String title;
  final String description;
  final String image;

  const PageBuilderWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Image.asset(image),
          ),
          const SizedBox(
            height: 20,
          ),
          // Title Text
          Text(
            title,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          // Description
          Text(
            description,
            textAlign: TextAlign.justify,
            style: const TextStyle(
              color: darkPurple,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
