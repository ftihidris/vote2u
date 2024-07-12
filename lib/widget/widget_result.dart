import 'package:flutter/material.dart';
import 'package:vote2u_admin/utils/constants.dart';

Widget buildResultCard(
  BuildContext context, 
  String candidateName, 
  String candidateID,
  String candidateCourse,
  String imageName,
  int voteCount,
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
                    height: 140,
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
            height: 40,
            child: 
            Container(
              width: 150, // Set the width of the container
              height: 25, // Set the height of the container
              decoration: BoxDecoration(
                color: darkPurple,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Center(
                child: Text(
                 '$voteCount Votes', 
                style: const TextStyle (color: Colors.white, fontSize: 14),
            ),
              ),
          ),
          ),
        ],
      ),
    ),
  );
}