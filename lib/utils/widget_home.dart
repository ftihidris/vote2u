import 'package:flutter/material.dart';
import 'package:vote2u/utils/navigation_utils.dart';

Widget buildCardWithHome(BuildContext context, String title, String imagePath) {
  return GestureDetector(
    onTap: () {
      navigateToPage(context, title);
    },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 2
    ,
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
            padding: const EdgeInsets.all(10),
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
