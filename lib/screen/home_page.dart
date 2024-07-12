import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:vote2u/firebase/firebase_auth_services.dart';
import 'package:vote2u/utils/app_drawer.dart';
import 'package:vote2u/utils/functions.dart';
import 'package:vote2u/widget/widget_home.dart';
import 'package:vote2u/screen/auth/loading_page.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController =
      PageController(); // Add a PageController
  Client? httpClient;
  Web3Client? ethClient;
  String electionName = '';
  bool electionEnded = false;
  bool electionStarted = false;
  bool userVoted = false;
  String voterStatus = 'Not Vote';
  String? currentUserUsername;
  final FirebaseAuthService _authService =
      FirebaseAuthService(); // Initialize FirebaseAuthService

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(infura_url, httpClient!);
    _fetchCurrentUser();
  }

  Future<void> _fetchCurrentUser() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    if (user != null) {
      currentUserUsername = await _authService
          .getCurrentUserUsername(); // Use FirebaseAuthService to get current user username
      _fetchElectionData(ethClient);
    }
  }
  Future<void> _fetchElectionData(ethClient) async {
    if (currentUserUsername == null) return;

    final electionNameResult = await getElectionName(ethClient);
    final electionStartedResult = await getElectionStarted(ethClient);
    final electionEndedResult = await getElectionEnded(ethClient);
    final userVotedResult = await hasUserVoted(
        currentUserUsername!, ethClient); // Use current user's username

    if (!mounted) return;

    setState(() {
      electionName = electionNameResult;
      electionStarted = electionStartedResult;
      electionEnded = electionEndedResult;
      userVoted = userVotedResult;
      voterStatus = userVoted ? 'Vote' : 'Not Vote';
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null && !user.emailVerified) {
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
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const Text(
              '2U',
              style: TextStyle(color: softPurple, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          ListView(
            children: [
              const SizedBox(height: 20),
              // First Row with PageView
              SizedBox(
                height: 235, // Adjust height as needed
                child: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15), // Add padding here
                            child: buildCardStatus(context, 'For You', 
                            electionName, electionStarted, electionEnded, voterStatus),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15), // Add padding here
                            child: buildCardWithHome(context, 'Start Voting',
                                'assets/images/Asset 5.png'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 2,
                      effect: const WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        activeDotColor: darkPurple,
                        dotColor: softPurple,
                      ),
                    ),
                  ],
                ),
              ),
              // Second Row with four cards
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15), // Add padding here
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: buildCardWithHome(context, 'Candidates',
                                    'assets/images/Asset 4.png')),
                            const SizedBox(width: 10),
                            Expanded(
                                child: buildCardWithHome(context, 'Result',
                                    'assets/images/Asset 3.png')),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                                child: buildCardWithHome(context, 'Dashboard',
                                    'assets/images/Asset 2.png')),
                            const SizedBox(width: 10),
                            Expanded(
                                child: buildCardWithHome(context, 'Need Help?',
                                    'assets/images/Asset 1.png')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }
}
