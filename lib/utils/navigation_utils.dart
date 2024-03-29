import 'package:flutter/material.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:vote2u/screen/voting_page.dart';
import 'package:vote2u/screen/result_page.dart';
import 'package:vote2u/screen/dashboard_page.dart';
import 'package:vote2u/screen/help_page.dart';
import 'package:vote2u/screen/candidate_page.dart';

void navigateToPage(BuildContext context, String title) {
  switch (title) {
    case 'Home':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => HomePage()));
    case 'Start Voting':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => VotingPage()));
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
      // Handle default case or do nothing
      break;
  }
}
