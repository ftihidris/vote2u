import 'package:flutter/material.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:vote2u/utils/constants.dart';

class DashboardPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
              'Dashboard',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: _buildCardWithHome('Start Voting', 'assets/images/Asset 5.png'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(child: _buildCardWithHome('Candidate', 'assets/images/Asset 4.png')),
                const SizedBox(width: 10),
                Expanded(child: _buildCardWithHome('Result', 'assets/images/Asset 3.png')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(child: _buildCardWithHome('Dashboard', 'assets/images/Asset 2.png')),
                const SizedBox(width: 10),
                Expanded(child: _buildCardWithHome('Need Help?', 'assets/images/Asset 1.png')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardWithHome(String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            imagePath,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: mediumEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    color: Colors.grey,
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
