import 'package:flutter/material.dart';

Widget buildCardCandidate(
  BuildContext context, 
  String candidateName, 
  int candidateID,
  String candidateCourse,
  String imagePath) 
  {

  return GestureDetector(
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2,
      margin: const EdgeInsets.fromLTRB(13, 20, 13, 0),
      
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width:140,
            child: Image.asset(
              imagePath,
              height: 140,
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
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
                  const SizedBox(height:5),
                  Text(
                    candidateID.toString(),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height:5),
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
    ),
  );
}