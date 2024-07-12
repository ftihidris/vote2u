import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:vote2u/screen/dashboard/dashboard_chart.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:vote2u/utils/functions.dart';
import 'package:vote2u/widget/widget_dashboard.dart';
import 'package:web3dart/web3dart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPage createState() => _DashboardPage();
}

class _DashboardPage extends State<DashboardPage> {
  late Client httpClient;
  late Web3Client ethClient;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<CandidateChartState> _candidateChartKey = GlobalKey<CandidateChartState>();

  @override
  void initState() {
    super.initState();
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
              'Dashboard',
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
    return Column(
      children: [
        const SizedBox(height: 25),
        _buildTotalCards(ethClient),
        const SizedBox(height: 15),
        _buildPercentageCard(ethClient),
        const SizedBox(height: 15),
        _buildChartCard(ethClient),
      ],
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
        height: 458, // Adjust the height as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: buildCardChart(
                'Comparison of Candidates Result',
                CandidateChart(key: _candidateChartKey),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_candidateChartKey.currentState != null) {
                  if (kDebugMode) {
                    print('Current state is not null');
                  }
                  _candidateChartKey.currentState!.exportChartToPdf();
                } else {
                  if (kDebugMode) {
                    print('Current state is null');
                  }
                }
              },
              child: const Text('Export Chart to PDF'),
            ),
          ],
        ),
      ),
    );
  }
}
