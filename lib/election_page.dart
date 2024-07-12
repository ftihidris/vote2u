import 'package:firebase_auth/firebase_auth.dart';
import 'package:vote2u_admin/firebase/firebase_auth_services.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:vote2u_admin/screen/dashboard/dashboard_chart.dart';
import 'package:vote2u_admin/utils/app_drawer.dart';
import 'package:vote2u_admin/utils/constants.dart';
import 'package:vote2u_admin/utils/functions.dart';
import 'package:vote2u_admin/utils/toast.dart';
import 'package:vote2u_admin/widget/widget_election.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web3dart/web3dart.dart';

class ElectionPage extends StatefulWidget {
  const ElectionPage({super.key});

  @override
  _ElectionPage createState() => _ElectionPage();
}

class _ElectionPage extends State<ElectionPage> {
  late Client httpClient;
  late Web3Client ethClient;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;
  User? _user;
  

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
    httpClient = http.Client();
    ethClient = Web3Client(infura_url, httpClient);
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
              'Election',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(ethClient),
    );
  }

Widget _buildBody(Web3Client ethClient) {
  return ListView(
    children: [
      const SizedBox(height: 25),
      _buildCardElection(ethClient),
      const SizedBox(height: 15),
      _buildTotalCards(ethClient),
      const SizedBox(height: 15),
      _buildPercentageCard(ethClient),
      const SizedBox(height: 15),
      _buildChartCard(ethClient),
    ],
  );
}
Widget _buildCardElection(Web3Client ethClient) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Row(
      children: [
        Expanded(
          child: buildCardElection(
            'Start Election',
            () async {
              await _showPasswordDialog(
                context,
                'Start Election',
                () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await startElection(ethClient, owner_private_key);
                    await FirebaseFirestore.instance
                        .collection('election')
                        .doc('TdpVaSNP0u9LSxmujuGD')
                        .update({'electionStarted': true});
                    showToast(message: 'Election started successfully');
                  } catch (e) {
                    showToast(message: 'Failed to start election: $e');
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              );
            },
            Colors.green,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: buildCardElection(
            'End Election',
            () async {
              await _showPasswordDialog(
                context,
                'End Election',
                () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await endElection(ethClient, owner_private_key);
                    await FirebaseFirestore.instance
                        .collection('election')
                        .doc('TdpVaSNP0u9LSxmujuGD')
                        .update({'electionEnded': true});
                    showToast(message: 'Election ended successfully');
                  } catch (e) {
                    showToast(message: 'Failed to end election: $e');
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              );
            },
            Colors.red,
          ),
        ),
      ],
    ),
  );
}

Future<void> _showPasswordDialog(
  BuildContext context,
  String title,
  VoidCallback onPressed,
) async {
  final passwordController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter your current password to verify your identity.'),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current Password'),
                ),
                if (_isLoading)
                  const CircularProgressIndicator(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    await _authService.reauthenticateUser(
                      email: _user!.email!,
                      password: passwordController.text,
                  );
                    onPressed();
                  } catch (e) {
                    showToast(message: 'Failed to verify password: $e');
                  } finally {
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                child: const Text('Confirm'),
              ),
            ],
          );
        },
      );
    },
  );
}


  Widget _buildTotalCards(Web3Client ethClient) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          Expanded(
            child: FutureBuilder(
              future: getTotalVoters(ethClient),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int totalVoters = snapshot.data as int;
                  return buildCardTotal('Total Voters', totalVoters);
                } else {
                  return buildCardTotal('Total Voters', 0);
                }
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FutureBuilder(
              future: getTotalVotes(ethClient),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  int totalVotes = snapshot.data as int;
                  return buildCardTotal('Votes Received', totalVotes);
                } else {
                  return buildCardTotal('Votes Received', 0);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPercentageCard(Web3Client ethClient) {
    return FutureBuilder(
      future: Future.wait([
        getTotalVoters(ethClient),
        getTotalVotes(ethClient),
      ]),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int totalVoters = snapshot.data![0];
          int totalVotes = snapshot.data![1];
          double percentage = (totalVotes / totalVoters) * 100;
          if (totalVoters == 0) {
            percentage = 0;
          } else {
            percentage = (totalVotes / totalVoters) * 100;
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                buildCardPercentage(
                  'Percentage of Voting Participation',
                  SizedBox(
                    height: 7,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: percentage / 100,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation(darkPurple),
                      ),
                    ),
                  ),
                  percentage,
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                buildCardPercentage(
                  'Percentage of Voting Participation',
                  SizedBox(
                    height: 6,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0,
                        backgroundColor: Colors.white,
                        valueColor: AlwaysStoppedAnimation(darkPurple),
                      ),
                    ),
                  ),
                  0,
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildChartCard(Web3Client ethClient) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
        child: SizedBox(
          height: 401, // Adjust the height as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: buildCardChart(
                  'Comparison of Candidates Result',
                  const CandidateChart(),
                ),
              ),
            ],
          ),
        ));
  }
}
