import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/utils/ringtone.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vote2u/utils/constants.dart';

class ConfirmationPage extends StatefulWidget {
  const ConfirmationPage({Key? key}) : super(key: key);

  @override
  _ConfirmationPageState createState() => _ConfirmationPageState();
}

class _ConfirmationPageState extends State<ConfirmationPage> {
  bool isLoading = true;

@override
void initState() {
  super.initState();
  // Simulate a delay to show loading indicator
  Timer(const Duration(seconds: 2), () {
    setState(() {
      isLoading = false; // Set loading to false after delay
    });
    Timer(const Duration(seconds: 0), () {
      startTimer();
    });
  });
}
  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : FutureBuilder<User?>(
            future: FirebaseAuth.instance.authStateChanges().first,
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                if (userSnapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text('Error loading user data: ${userSnapshot.error}'),
                    ),
                  );
                } else if (userSnapshot.hasData) {
                  final User? user = userSnapshot.data;
                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('users')
                        .doc(user!.uid)
                        .get(),
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
                            child: Text('Error loading user name: ${snapshot.error}'),
                          ),
                        );
                      } else if (snapshot.hasData && snapshot.data != null) {
                        final firstName = snapshot.data!['firstName'];
                        final lastName = snapshot.data!['lastName'];
                        return Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(height: 120),
                                const Icon(
                                  FontAwesomeIcons.circleCheck,
                                  size: 90, 
                                  color: Colors.green, 
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  "THANK YOU FOR\nYOUR VOTE!",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: darkPurple,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  '${firstName.toUpperCase()} ${lastName.toUpperCase()}',
                                  style: const TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "We already received your vote\nand it will be counted and\nsecured",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: darkPurple),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  "You can view the result for the\nelection on 9 P.M",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: darkPurple),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(30, 30, 30, 17),
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (context) => HomePage()),
                                        (route) => false,
                                      );
                                    },
                                    child: Container(
                                      width: 180,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: darkPurple,
                                        borderRadius: largeBorderRadius,
                                        ),
                                    child: const Center(
                                      child: Text(
                                      "Back to home",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                ),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else {
                        return const Scaffold(
                          body: Center(
                            child: Text('Name not found'),
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return const Scaffold(
                    body: Center(
                      child: Text('User not authenticated'),
                    ),
                  );
                }
              }
            },
          );
  }
}
