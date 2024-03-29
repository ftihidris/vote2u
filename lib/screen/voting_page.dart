import 'package:flutter/material.dart';
import 'package:vote2u/utils/app_drawer.dart';

class VotingPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  VotingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 63, 41, 120),
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
              'Cast Your Vote',
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
            child: _buildCardWithImageAndText('Start Voting', 'assets/images/Asset 5.png'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(child: _buildCardWithImageAndText('Candidate', 'assets/images/Asset 4.png')),
                const SizedBox(width: 10),
                Expanded(child: _buildCardWithImageAndText('Result', 'assets/images/Asset 3.png')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(child: _buildCardWithImageAndText('Dashboard', 'assets/images/Asset 2.png')),
                const SizedBox(width: 10),
                Expanded(child: _buildCardWithImageAndText('Need Help?', 'assets/images/Asset 1.png')),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onWillPop() async {
    // Prevent default behavior of popping the route
    return;
  }

  Widget _buildCardWithImageAndText(String title, String imagePath) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
            padding: const EdgeInsets.all(10),
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
