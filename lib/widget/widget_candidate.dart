import 'package:flutter/material.dart';
import 'package:vote2u_admin/utils/constants.dart';

Widget buildCardCandidate(
  BuildContext context, 
  String candidateName, 
  String candidateID,
  String candidateCourse,
  String imageUrl,
) {
  print('Image URL in buildCardCandidate: $imageUrl');
  return GestureDetector(
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: elevation2,
      margin: const EdgeInsets.fromLTRB(18, 20, 18, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width:130,
            child: Material(
              elevation: elevation3, // Adjust elevation as needed
              child: Image.network(
                imageUrl,
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
                  const SizedBox(height:5),
                  Text(
                    candidateID,
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