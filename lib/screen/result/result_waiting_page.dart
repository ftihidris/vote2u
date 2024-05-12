import 'package:flutter/material.dart';
import 'package:vote2u/screen/home_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:vote2u/utils/constants.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({Key? key}) : super(key: key);

  @override
  _WaitingPageState createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            const Icon(
              FontAwesomeIcons.faceFrown,
              size: 90, 
              color: Colors.green, 
            ),
            const SizedBox(height: 30),
            const Text(
              "Oops!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: darkPurple,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Sorry, the result for the election\nis not available until the\nelection end.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: darkPurple),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 17),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => HomePage()),
                    (route) => false,
                  );
                },
                child: Container(
                  width: 180,
                  height: 40,
                  decoration: BoxDecoration(
                    color: darkPurple,
                    borderRadius: largeBorderRadius,
                  ),
                  child: const Center(
                    child: Text(
                      "Back to home",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
}