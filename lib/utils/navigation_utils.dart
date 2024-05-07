import 'package:flutter/material.dart';
import 'package:vote2u/screen/dashboard_page.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/screen/result/result_page.dart';
import 'package:vote2u/screen/voting/voting_page.dart';
//import 'package:vote2u/screen/dashboard_page.dart';
import 'package:vote2u/screen/help_page.dart';
import 'package:vote2u/screen/candidate_page.dart';
import 'package:vote2u/screen/voting/verification_page.dart';
import 'package:web3dart/web3dart.dart';


void navigateToPage(BuildContext context, String title) {
  switch (title) {
    case 'Home':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
      break;
    case 'Start Voting':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => VerificationPage()));
      break;
    case 'Candidate':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CandidatePage()));
      break;
    case 'Result':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => ResultPage()));
      break;
    case 'Dashboard':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => DashboardPage()));
      break;
    case 'Need Help?':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HelpPage()));
      break;
    default:
  }
}
void navigateToVoting(
  BuildContext context, 
  String title,
  Web3Client ethClient,
  TextEditingController controller ) {

  switch (title) {
    case 'Voting':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => VotingPage()));
      break;
          default:
  }
}
