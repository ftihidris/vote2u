import 'package:flutter/material.dart';
import 'package:vote2u_admin/utils/constants.dart';

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

Widget buildCardElection(
  String title,
  Function onTap,
  MaterialColor color,
) {
  return GestureDetector(
    onTap: () async {
      await onTap();
    },
    child: Card(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: elevation2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
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
Widget buildCardPercentage(
    String title, Widget? subtitleWidget, double percentageVoter) {
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
Widget buildCardChart(String title, Widget chartWidget) {
  return buildCardDashboard(
    title: title,
    child: Card(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      shape: RoundedRectangleBorder(
        borderRadius: mediumBorderRadius,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: null,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 318, // Limit the height of the chartWidget
        ),
        child: chartWidget,
      ),
    ),
  );
}
