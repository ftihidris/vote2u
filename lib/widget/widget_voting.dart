import 'package:flutter/material.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:web3dart/web3dart.dart';

Widget buildCardVoting(
    BuildContext context,
    String candidateName,
    String candidateID,
    String candidateCourse,
    String imageUrl,
    Web3Client ethClient,
    bool isSelected,
    VoidCallback onVotePressed,
  ) {
  return GestureDetector(
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 110,
                child: Material(
                  elevation: 3,
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        candidateName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        candidateID,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        candidateCourse,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 8,
            right: 8,
            height: 35,
            child: GestureDetector(
              onTap: () {
                onVotePressed(); // Pass the candidate ID to the callback
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected? darkPurple : softPurple,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 17,
                ),
                child: const Center(
                  child: Text(
                    'Vote',
                    style: TextStyle(color: Colors.white),
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
