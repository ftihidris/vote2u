import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vote2u_admin/utils/app_drawer.dart';
import 'package:vote2u_admin/utils/constants.dart';

class VotersPage extends StatefulWidget {
  const VotersPage({super.key});

  @override
  _VotersPage createState() => _VotersPage();
}
class _VotersPage extends State<VotersPage> {

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

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
              'Voters',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('faq').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final documents = snapshot.data!.docs;
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              children: documents.map((doc) {
                final question = doc['question'];
                final answer = doc['answer'];
                return buildFaqTile(
                  question: question, 
                  answer: answer);
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget buildFaqTile(
   {required String question, 
    required String answer}) {
    return Card(
      color: const Color.fromARGB(255, 247, 242, 249),
      shape: RoundedRectangleBorder(
        borderRadius: largeBorderRadius,
      ),
      elevation: elevation1,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent, // Hide the divider
        ),
        child: ExpansionTile(
          title: Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkPurple,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  answer,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
