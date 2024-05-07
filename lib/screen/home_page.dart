import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:vote2u/widget/widget_home.dart'; 
import 'package:vote2u/screen/auth/loading_page.dart';
import 'package:vote2u/utils/constants.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user!= null &&!user.emailVerified) {
      // User is not verified, show verification screen
      return LoadingPage(email: user.email!, isSignUp: true);
    }
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: darkPurple,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            const Text(
              'VOTE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Text(
              '2U',
              style: TextStyle(color: softPurple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: buildCardWithHome(context, 'Start Voting', 'assets/images/Asset 5.png'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(child: buildCardWithHome(context, 'Candidate', 'assets/images/Asset 4.png')),
                const SizedBox(width: 10),
                Expanded(child: buildCardWithHome(context, 'Result', 'assets/images/Asset 3.png')),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                Expanded(child: buildCardWithHome(context, 'Dashboard', 'assets/images/Asset 2.png')),
                const SizedBox(width: 10),
                Expanded(child: buildCardWithHome(context, 'Need Help?', 'assets/images/Asset 1.png')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
