import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:vote2u/screen/result/result_waiting_page.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:vote2u/widget/widget_result.dart';
import 'package:vote2u/firebase/storage_services.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:vote2u/utils/functions.dart';
import 'package:web3dart/web3dart.dart';

class ResultPage extends StatefulWidget {
  ResultPage({Key? key});

  @override
  _ResultPage createState() => _ResultPage();
}

class _ResultPage extends State<ResultPage> {
  late Client _httpClient;
  late Web3Client _ethClient;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<BigInt> _numCandidatesToWin = Future.value(BigInt.zero);
  int? _numWinners;
  @override
  void initState() {
    super.initState();
    _httpClient = http.Client();
    _ethClient = Web3Client(infura_url, _httpClient);
    _numCandidatesToWin = getNumCandidatesToWin(_ethClient);
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
              'Result',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder(
        future: getElectionEnded(_ethClient),
        builder: (context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data!) {
            return Column(
              children: [
                FutureBuilder(
                  future: _numCandidatesToWin,
                  builder: (context, AsyncSnapshot<BigInt> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      _numWinners = snapshot.data!.toInt();
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 15, 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Top $_numWinners Winners',
                                    textAlign: TextAlign.left,
                                    style: const TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        color: darkPurple),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('candidates')
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              } else if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              } else {
                                List<Map<String, dynamic>> winners = snapshot
                                    .data!.docs
                                    .take(_numWinners!)
                                    .toList()
                                    .map((document) => document.data())
                                    .toList();
                                List<Map<String, dynamic>> otherCandidates =
                                    snapshot.data!.docs
                                        .skip(_numWinners!)
                                        .toList()
                                        .map((document) => document.data())
                                        .toList();

                                return Column(
                                  children: [
                                    ...winners.map((candidateData) {
                                      String candidateName =
                                          candidateData['candidatesName'];
                                      String candidateID =
                                          candidateData['candidatesID'];
                                      String candidateCourse =
                                          candidateData['candidatesCourse'];
                                      String imageName =
                                          candidateData['candidatesPhoto'] ??
                                              'defaultImageName.png';

                                      return FutureBuilder(
                                        future:
                                            Storage().downloadURL(imageName),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator()); // Loading indicator while waiting for image
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}'); // Display error if any
                                          } else {
                                            return buildResultCard(
                                              context,
                                              candidateName,
                                              candidateID,
                                              candidateCourse,
                                              snapshot.data!,
                                            );
                                          }
                                        },
                                      );
                                    }),
                                    Container(
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color:
                                                darkPurple, // Set the color of the border
                                            width:
                                                1, // Set the width of the border
                                          ),
                                        ),
                                      ),
                                      margin: const EdgeInsets.fromLTRB(
                                          20,
                                          20,
                                          20,
                                          10), // Add margin to adjust the position of the divider
                                    ),
                                    ...otherCandidates.map((candidateData) {
                                      String candidateName =
                                          candidateData['candidatesName'];
                                      String candidateID =
                                          candidateData['candidatesID'];
                                      String candidateCourse =
                                          candidateData['candidatesCourse'];
                                      String imageName =
                                          candidateData['candidatesPhoto'] ??
                                              'defaultImageName.png';

                                      return FutureBuilder(
                                        future:
                                            Storage().downloadURL(imageName),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<String> snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator()); // Loading indicator while waiting for image
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}'); // Display error if any
                                          } else {
                                            return buildResultCard(
                                              context,
                                              candidateName,
                                              candidateID,
                                              candidateCourse,
                                              snapshot.data!,
                                            );
                                          }
                                        },
                                      );
                                    }),
                                  ],
                                );
                              }
                            },
                          )
                        ],
                      );
                    }
                  },
                ),
              ],
            );
          } else {
            return const WaitingPage(); // Show waiting page if election has not ended
          }
        },
      ),
    );
  }
}
