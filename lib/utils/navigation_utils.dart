import 'package:flutter/material.dart';
import 'package:vote2u_admin/election_page.dart';
import 'package:vote2u_admin/screen/home_page.dart';
import 'package:vote2u_admin/screen/candidates/add_candidates_page.dart';
import 'package:vote2u_admin/screen/settings_page.dart';
import 'package:vote2u_admin/screen/voters/add_voters_page.dart';
import 'package:vote2u_admin/screen/voters/voters_page.dart';
import 'package:vote2u_admin/screen/candidates/candidate_page.dart';


void navigateToPage(BuildContext context, String title) {
  switch (title) {
    case 'Home':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const HomePage()));
      break;
    case 'Election':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ElectionPage()));
      break;
    case 'Candidates List':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CandidatePage()));
      break;
    case 'Add Candidates':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddCandidates()));
      break;
    case 'Add Voters':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AddVoters()));
      break;
    case 'Voters List':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const VotersPage()));
      break;
    case 'Settings':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SettingsPage()));
      break;
    default:
  }
}
