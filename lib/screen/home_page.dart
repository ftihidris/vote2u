import 'package:flutter/material.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:vote2u/utils/widget_home.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Homepage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  HomePage({Key? key}) : super(key: key);

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
              'VOTE',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Text(
              '2U',
              style: TextStyle(color: Color.fromARGB(255, 131, 121, 205), fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
            child: buildCardWithHome(context, 'Start Voting', 'assets/images/Asset 5.png'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(child: buildCardWithHome(context, 'Candidate', 'assets/images/Asset 4.png')),
                const SizedBox(width: 10),
                Expanded(child: buildCardWithHome(context, 'Result', 'assets/images/Asset 3.png')),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
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
