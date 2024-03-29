import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:vote2u/utils/widget_candidate.dart';
import 'package:vote2u/firebase/storage_services.dart';

class CandidatePage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CandidatePage({super.key});

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
              'Candidates',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('candidates').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                return buildCandidateCard(context, data);
              }).toList(),
            );
          }
        },
      ),
    );
  }

  Widget buildCandidateCard(BuildContext context, Map<String, dynamic> candidateData) {
    String candidateName = candidateData['candidatesName'];
    int candidateID = candidateData['candidatesID'];
    String candidateCourse = candidateData['candidatesCourse'];
    String imageName = candidateData['candidatesPhoto'] ?? 'defaultImageName.png'; // Use default image name if not provided

    return FutureBuilder(
      future: Storage().downloadURL(imageName), // Using the Storage class
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: const CircularProgressIndicator()
            );// Loading indicator while waiting for image
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}'); // Display error if any
        } else {
          return buildCardCandidate(
            context,
            candidateName,
            candidateID,
            candidateCourse,
            snapshot.data!, // Use the URL retrieved from Firebase Storage
          );
        }
      },
    );
  }
}
