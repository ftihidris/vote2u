import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vote2u/utils/navigation_utils.dart';
import 'package:vote2u/screen/auth/auth_preferences.dart';
import 'package:vote2u/utils/constants.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasError) {
            return const Text('Error loading user data');
          } else if (snapshot.hasData) {
            return Drawer(
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: darkPurple,
                    ),
                    accountName: FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(snapshot.data!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return const Text('Error loading user name');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final firstName = snapshot.data!['firstName'];
                          final lastName = snapshot.data!['lastName'];
                          return Text(
                            '${firstName.toUpperCase()} ${lastName.toUpperCase()}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          return const Text('Name not found');
                        }
                      },
                    ),
                    accountEmail: Text(snapshot.data!.email ?? 'Email not found'),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(left: 16),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ListTile(
                            title: const Text('Home'),
                            textColor: darkPurple,
                            onTap: () {
                              navigateToPage(context, 'Home');
                            },
                          ),
                          ListTile(
                            title: const Text('Start Voting'),
                            textColor: darkPurple,
                            onTap: () {
                              navigateToPage(context, 'Start Voting');
                            },
                          ),
                          ListTile(
                            title: const Text('Candidate'),
                            textColor: darkPurple,
                            onTap: () {
                              navigateToPage(context, 'Candidate');
                            },
                          ),
                          ListTile(
                            title: const Text('Result'),
                            textColor: darkPurple,
                            onTap: () {
                              navigateToPage(context, 'Result');
                            },
                          ),
                          ListTile(
                            title: const Text('Dashboard'),
                            textColor: darkPurple,
                            onTap: () {
                              navigateToPage(context, 'Dashboard');
                            },
                          ),
                          ListTile(
                            title: const Text('Need Help?'),
                            textColor: darkPurple,
                            onTap: () {
                              navigateToPage(context, 'Need Help?');
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        await AuthPreferences.storeUserLoggedInState(false, false);
                        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      } catch (e) {
                        print('Error signing out: $e');
                        // Handle sign out error
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.fromLTRB(32, 16, 16, 40),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color:  darkPurple,
                          ),
                           SizedBox(width: 16.0),
                           Text(
                            'Logout',
                            style: TextStyle(
                              color: darkPurple,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Text('User not authenticated');
          }
        }
      },
    );
  }
}
