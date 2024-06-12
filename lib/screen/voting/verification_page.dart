import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:vote2u/firebase/firebase_auth_services.dart';
import 'package:web3dart/web3dart.dart';
import 'package:vote2u/screen/voting/voting_page.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:vote2u/utils/functions.dart';
import 'package:vote2u/utils/toast.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  _VerificationState createState() => _VerificationState();
}

class _VerificationState extends State<VerificationPage> {
  Client? httpClient;
  Web3Client? ethClient;
  bool isLoading = false;
  final FirebaseAuthService _authService = FirebaseAuthService();
  String? studentId;
  bool isRegistered = false;
  bool isEligible = false;
  bool hasVoted = false;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(infura_url, httpClient!);
    _fetchStudentId();
  }

  Future<void> _fetchStudentId() async {
    String? currentUserUsername = await _authService.getCurrentUserUsername();
    setState(() {
      studentId = currentUserUsername;
      isRegistered = currentUserUsername != null;
    });
    if (isRegistered) {
      await _verifyStudent();
    }
  }

  Future<void> _verifyStudent() async {
    if (studentId != null) {
      setState(() {
        isLoading = true;
      });
      bool isVerified = await verifyVoter(studentId!, ethClient!);

      if (isVerified) {
        setState(() {
          isEligible = true;
        });
        bool voted = await hasUserVoted(studentId!, ethClient!);
        setState(() {
          hasVoted = voted;
        });
      }

      setState(() {
        isLoading = false;
      });
    } else {
      showToast(message: "Unable to retrieve your Student ID");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              'Verification',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: largeBorderRadius,
              ),
              elevation: elevation2,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(30),
                child: Column(
                  children: [
                    const Icon(
                      CupertinoIcons.rectangle_stack_person_crop_fill,
                      size: 170,
                      color: darkPurple,
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'Student ID',
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (studentId != null)
                      Text(
                        '$studentId',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: darkPurple,
                        ),
                      ),
                    const SizedBox(height: 30),
                    _buildCheckRow(
                      "UiTM Student status",
                      isRegistered,
                    ),
                    const SizedBox(height: 5),
                    _buildCheckRow(
                      "Eligibile voter",
                      isEligible,
                    ),
                    const SizedBox(height: 5),
                    _buildCheckRow(
                      "Voting status",
                      !hasVoted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              height: mediumSizeBox,
              decoration: BoxDecoration(
                color: darkPurple,
                borderRadius: largeBorderRadius,
              ),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : TextButton(
                      onPressed: isEligible && !hasVoted
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const VotingPage(),
                                ),
                              );
                            }
                          : () async {
                              await _verifyStudent();
                            },
                      child: Center(
                        child: Text(
                          isEligible && !hasVoted
                              ? 'Continue to vote'
                              : 'Refresh your status',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckRow(String text, bool isChecked) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
        Icon(
          isChecked
              ? CupertinoIcons.check_mark_circled_solid
              : CupertinoIcons.xmark_circle_fill,
          color: isChecked ? Colors.green : Colors.red,
        ),
      ],
    );
  }
}
