import 'package:flutter/material.dart';
import 'package:vote2u/utils/constants.dart';

// Extracted common card widget
Widget buildCardDashboard({
  required String title,
  required Widget child,
}) {
  return SizedBox(
    width: double.infinity,
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: elevation2,
      child: IntrinsicHeight(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15),
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            child,
            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

// Improved buildCardTotal
Widget buildCardTotal(String title, int totalNumber) {
  return buildCardDashboard(
    title: title,
    child: Center(
      child: Text(
        totalNumber.toString(),
        style: const TextStyle(
          fontSize: 45,
          color: darkPurple,
        ),
      ),
    ),
  );
}

// Improved buildCardPercentage
Widget buildCardPercentage(String title, Widget? subtitleWidget, double percentageVoter) {
  return buildCardDashboard(
    title: title,
    child: Column(
      children: <Widget>[
        SizedBox(
          height: 30,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: subtitleWidget,
            ),
          ),
        ),
        Text(
          '${percentageVoter.toStringAsFixed(2)}%',
          style: const TextStyle(
            fontSize: 17,
            color: darkPurple,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// Improved buildCardChart
Widget buildCardChart(String title, int subTitle) {
  return buildCardDashboard(
    title: title,
    child: Center(
      child: Text(
        subTitle.toString(),
        style: const TextStyle(
          fontSize: 45,
          color: darkPurple,
        ),
      ),
    ),
  );
}