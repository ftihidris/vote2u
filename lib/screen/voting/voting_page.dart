import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vote2u/screen/voting/confirmation_page.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:vote2u/utils/functions.dart';
import 'package:vote2u/utils/toast.dart';
import 'package:vote2u/widget/widget_voting.dart';
import 'package:vote2u/firebase/storage_services.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

class VotingPage extends StatefulWidget {
  final String? studentId; 

  const VotingPage({super.key, 
  required this.studentId
  });

  @override
  _VotingPageState createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  late Client httpClient;
  late Web3Client ethClient;
  late Future<BigInt> numCandidatesPerVote;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Set<String> selectedCandidates = {};

  @override
  void initState() {
    super.initState();
    httpClient = http.Client();
    ethClient = Web3Client(infura_url, httpClient);
    numCandidatesPerVote = getMaxCandidatesPerVote(ethClient);
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
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            const Text(
              'Voting',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<BigInt>(
        future: numCandidatesPerVote,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            int numPerVote = snapshot.data!.toInt();
            return buildCandidatesList(context, numPerVote);
          }
        },
      ),
      floatingActionButton: selectedCandidates.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () async {
                int numPerVote = (await numCandidatesPerVote).toInt();
                if (selectedCandidates.length != numPerVote) {
                  showToast(
                      message:
                          "You must select exactly $numPerVote candidates to vote");
                } else {
                  // Convert the Set<String> to a List<String>
                  final candidateIdsList = selectedCandidates.toList();

                  // Show confirmation dialog
                  bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Confirm Vote'),
                        content: Text(
                            'Are you sure you want to cast your vote for these candidates: \n\n$selectedCandidates'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                          ),
                          TextButton(
                            child: const Text('Confirm'),
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    // Transact the vote using the list of candidate IDs
                    await vote(widget.studentId!, candidateIdsList, ethClient);

                    // Navigate to confirmation page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ConfirmationPage()),
                    );
                  }
                }
              },
              label: Text('Cast ${selectedCandidates.length} Votes',
                  style: const TextStyle(color: Colors.white)),
              icon: const Icon(Icons.how_to_vote, color: Colors.white),
              backgroundColor: darkPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            )
          : null,
    );
  }

  Widget buildCandidatesList(BuildContext context, int numPerVote) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 15, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select $numPerVote Candidates to Vote',
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: darkPurple,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream:
                FirebaseFirestore.instance.collection('candidates').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No candidates found'));
              } else {
                return ListView(
                  children: snapshot.data!.docs.map((document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return buildCandidateCard(
                        context, data, ethClient, numPerVote);
                  }).toList(),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget buildCandidateCard(
      BuildContext context,
      Map<String, dynamic> candidateData,
      Web3Client ethClient,
      int numPerVote) {
    String candidateName = candidateData['candidatesName'];
    String candidateID = candidateData['candidatesID'];
    String candidateCourse = candidateData['candidatesCourse'];
    String imageName =
        candidateData['candidatesPhoto'] ?? 'defaultImageName.png';

    // Debug output to log candidate IDs fetched from Firestore
    if (kDebugMode) {
      print('Candidate ID from Firestore: $candidateID');
    }

    return FutureBuilder<String>(
      future: Storage().downloadURL(imageName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          String imageName = snapshot.data ?? '';
          bool isSelected = selectedCandidates.contains(candidateID);
          return buildCardVoting(
            context,
            candidateName,
            candidateID,
            candidateCourse,
            imageName,
            ethClient,
            isSelected,
            () {
              setState(() {
                if (isSelected) {
                  selectedCandidates.remove(candidateID);
                } else {
                  if (selectedCandidates.length < numPerVote) {
                    selectedCandidates.add(candidateID);
                  } else {
                    showToast(
                        message: "You can only select $numPerVote candidates");
                  }
                }
              });
            },
          );
        }
      },
    );
  }
}
