import 'package:flutter/material.dart';
import 'package:vote2u_admin/utils/constants.dart';
import 'package:vote2u_admin/utils/navigation_utils.dart';

Widget buildCardWithHome(BuildContext context, String title, String imagePath) {
  return GestureDetector(
    onTap: () {
      navigateToPage(context, title);
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: elevation2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.asset(
            imagePath,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: mediumEdgeInsets,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget buildCardStatus(BuildContext context,String title, String electionName, bool electionStarted, bool electionEnded, String voterStatus) {
  String electionStatusText;
  Color electionStatusColor;

  if (!electionStarted) {
    electionStatusText = 'Not started';
    electionStatusColor = Colors.red;
  } else if (electionEnded) {
    electionStatusText = 'Ended';
    electionStatusColor = Colors.red;
  } else {
    electionStatusText = 'Ongoing';
    electionStatusColor = Colors.green;
  }
  
  return GestureDetector(
    onTap: () {
      navigateToPage(context, 'Election Status');
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: elevation2,
      child: Column(
        children: <Widget>[
          Container(
            color: darkPurple,
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Ongoing election:',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                Text(
                  electionName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min, // Shrink-wrap the Column
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center vertically
                      children: [
                        buildStatusIndicator(
                          'Election Status', electionStatusText, electionStatusColor),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min, // Shrink-wrap the Column
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Center vertically
                      children: [
                        buildStatusIndicator(
                          'Voter Status', voterStatus,
                            voterStatus == 'Vote' ? Colors.green : Colors.red),
                      ],
                    ),
                  ],
                )),
          ),
        ],
      ),
    ),
  );
}

Widget buildStatusIndicator(String title, String status, Color color) {
  return Column(
    children: [
      Text(
        title,
        style: TextStyle(
          color: Colors.grey[700],
          fontSize: 12
        ),
      ),
      const SizedBox(height: 8),
      Container(
        width: 100,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center( 
          child: 
        Text(
          status,
          style: const TextStyle(
            color: Colors.white,
          
          ),
        ),
        ),
      ),
    ],
  );
}
