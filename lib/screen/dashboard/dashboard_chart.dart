import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:vote2u/utils/functions.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';
import 'package:permission_handler/permission_handler.dart';

class CandidateChart extends StatefulWidget {
  const CandidateChart({super.key});

  @override
  CandidateChartState createState() => CandidateChartState();
}

class CandidateChartState extends State<CandidateChart> {
  late List<ChartData> chartData;
  late TooltipBehavior tooltipBehavior;
  late Web3Client ethClient;
  final GlobalKey _chartKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ethClient = Web3Client(infura_url, http.Client());
    chartData = [];
    tooltipBehavior = TooltipBehavior(enable: true);
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder(
      future: getElectionEnded(ethClient),
      builder: (context, AsyncSnapshot<bool> electionEndedSnapshot) {
        if (electionEndedSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (electionEndedSnapshot.hasError) {
          return Center(child: Text('Error: ${electionEndedSnapshot.error}'));
        } else if (!electionEndedSnapshot.data!) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.faceFrown,
                  size: 60,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 10),
                Text(
                  "Oops!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Sorry, the election results will be\navailable once the election has ended",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        } else {
          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('candidates').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                List<Map<String, dynamic>> candidates = snapshot.data!.docs.map((doc) => doc.data()).toList();

                Future<List<int>> voteCountsFuture = Future.wait(candidates.map((candidate) async {
                  return await getCandidateVoteCount(candidate['candidatesID'], ethClient);
                }));

                return FutureBuilder(
                  future: voteCountsFuture,
                  builder: (context, AsyncSnapshot<List<int>> voteCountsSnapshot) {
                    if (voteCountsSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (voteCountsSnapshot.hasError) {
                      return Center(child: Text('Error: ${voteCountsSnapshot.error}'));
                    } else {
                      List<int> voteCounts = voteCountsSnapshot.data!;
                      chartData = _createChartData(candidates, voteCounts);
                      int maxVoteCount = voteCounts.reduce((curr, next) => curr > next ? curr : next);
                      return _buildChart(chartData, maxVoteCount);
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  List<ChartData> _createChartData(List<Map<String, dynamic>> candidates, List<int> voteCounts) {
    List<ChartData> chartData = [];
    for (int i = 0; i < candidates.length; i++) {
      Map<String, dynamic> candidate = candidates[i];
      chartData.add(ChartData(candidate['candidatesName'], voteCounts[i]));
    }
    return chartData;
  }

  Widget _buildChart(List<ChartData> chartData, int maxVoteCount) => RepaintBoundary(
    key: _chartKey,
    child: Container(
      padding: const EdgeInsets.all(20),
      child: SfCartesianChart(
        title: ChartTitle(),
        primaryXAxis: CategoryAxis(
          labelIntersectAction: AxisLabelIntersectAction.multipleRows,
          labelsExtent: 70,
          labelStyle: const TextStyle(
            overflow: TextOverflow.ellipsis,
          ),
        ),
        primaryYAxis: NumericAxis(minimum: 0, maximum: (maxVoteCount + 10).toDouble(), interval: 5),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          color: const Color.fromARGB(255, 247, 242, 249),
          textStyle: TextStyle(color: Colors.grey[800]),
        ),
        series: <CartesianSeries<ChartData, String>>[
          ColumnSeries<ChartData, String>(
            dataSource: chartData,
            xValueMapper: (ChartData data, _) => data.x,
            yValueMapper: (ChartData data, _) => data.y,
            name: 'Votes',
            color: darkPurple,
            borderRadius: mediumBorderRadius,
            dataLabelSettings: const DataLabelSettings(
              isVisible: true,
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> exportChartToPdf() async {
    if (kDebugMode) {
      print('Exporting chart to PDF');
    }
    try {
      // Create a new PDF document
      final PdfDocument document = PdfDocument();

      // Create a new PDF page
      final PdfPage page = document.pages.add();

      // Get the chart widget
      final RenderRepaintBoundary boundary = _chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      // Convert the chart to an image
      final ui.Image chartImage = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await chartImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List pngBytes = byteData!.buffer.asUint8List();

      // Convert the image to a PDF image
      final PdfBitmap pdfBitmap = PdfBitmap(pngBytes);

      // Add the PDF image to the page
      page.graphics.drawImage(pdfBitmap, Rect.fromLTWH(0, 0, page.getClientSize().width, page.getClientSize().height));

      // Save the PDF document to a file
      final Directory? directory = await getExternalStorageDirectory();
      final String filePath = '${directory!.path}/chart.pdf';
      final File file = File(filePath);
      await file.writeAsBytes(await document.save());

      // Dispose of the PDF document
      document.dispose();

      if (kDebugMode) {
        print('PDF saved at: $filePath');
      }

      // Show a snackbar with the file path
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF saved at: $filePath'),
          action: SnackBarAction(
            label: 'Open',
            onPressed: () async {
              await OpenFile.open(filePath);
            },
          ),
        ),
      );
    } catch (e) {
      // Handle errors gracefully
      if (kDebugMode) {
        print('Error exporting chart to PDF: $e');
      }
      // Optionally, show an error dialog or snackbar to inform the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to export chart to PDF. Please try again.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}
