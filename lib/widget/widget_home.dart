import 'package:flutter/material.dart';
import 'package:vote2u/utils/navigation_utils.dart';
import 'package:vote2u/utils/constants.dart';

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
