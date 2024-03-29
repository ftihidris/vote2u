import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vote2u/utils/navigation_utils.dart';
import 'package:vote2u/utils/auth_preferences.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return Drawer(
              child: Column(
                children: [
                  UserAccountsDrawerHeader(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 63, 41, 120),
                    ),
                    accountName: FutureBuilder<DocumentSnapshot>(
                      //Read the data collection from firestore
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(snapshot.data!.uid)
                          .get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else {
                          if (snapshot.hasData && snapshot.data != null) {
                            final firstName = snapshot.data!['firstName'];
                            final lastName = snapshot.data!['lastName'];
                            return Text(
                              '$firstName $lastName', 
                              style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold));
                          } else {
                            return const Text('Name not found');
                          }
                        }
                      },
                    ),
                    accountEmail: Text(snapshot.data!.email ?? 'Email not found'),
                  ),
                  ListTile(
                    title: const Text('Home'),
                    textColor: const Color.fromARGB(255, 63, 41, 120),
                    onTap: () {
                      navigateToPage(context, 'Home');
                    },
                  ),
                  ListTile(
                    title: const Text('Start Voting'),
                    textColor: const Color.fromARGB(255, 63, 41, 120),
                    onTap: () {
                      navigateToPage(context, 'Start Voting');
                    },
                  ),
                  ListTile(
                    title: const Text('Candidate'),
                    textColor: const Color.fromARGB(255, 63, 41, 120),
                    onTap: () {
                      navigateToPage(context, 'Candidate');
                    },
                  ),
                  ListTile(
                    title: const Text('Result'),
                    textColor: const Color.fromARGB(255, 63, 41, 120),
                    onTap: () {
                      navigateToPage(context, 'Result');
                    },
                  ),
                  ListTile(
                    title: const Text('Dashboard'),
                    textColor: const Color.fromARGB(255, 63, 41, 120),
                    onTap: () {
                      navigateToPage(context, 'Dashboard');
                    },
                  ),
                  ListTile(
                    title: const Text('Need Help?'),
                    textColor: const Color.fromARGB(255, 63, 41, 120),
                    onTap: () {
                      navigateToPage(context, 'Need Help?');
                    },
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      await AuthPreferences.storeUserLoggedInState(false);
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                      },
                      // Logout action
                    
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.logout,
                            color: Color.fromARGB(255, 63, 41, 120),
                          ),
                          SizedBox(width: 16.0),
                          Text(
                            'Logout',
                            style: TextStyle(
                              color: Color.fromARGB(255, 63, 41, 120),
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
            return const CircularProgressIndicator();
          }
        }
      },
    );
  }
}