import 'package:flutter/material.dart';
import 'package:vote2u/utils/constants.dart';

Widget buildCardVoting(
  BuildContext context, 
  String candidateName, 
  String candidateID,
  String candidateCourse,
  String imageName,
) {
  return GestureDetector(
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: elevation2,
      margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 110,
                child: Material(
                  elevation: elevation3, // Adjust elevation as needed
                  child: Image.network(
                    imageName,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: mediumEdgeInsets,
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
                        candidateID.toString(),
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
            child: 
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: darkPurple, // Background color
              ),
              onPressed: () async {
                // Handle button press
              },
              child: const Text('Vote', 
              style: TextStyle (color: Colors.white),
            ),
          ),
          ),
        ],
      ),
    ),
  );
}
