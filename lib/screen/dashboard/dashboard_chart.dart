import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vote2u/utils/constants.dart';
import 'package:vote2u/utils/functions.dart';
import 'package:http/http.dart' as http;
import 'package:web3dart/web3dart.dart';

class CandidateChart extends StatefulWidget {
  
  
  CandidateChart({Key? key}) : super(key: key);

  @override
  _CandidateChartState createState() => _CandidateChartState();
}

class _CandidateChartState extends State<CandidateChart> {
  late List<ChartData> chartData;
  late TooltipBehavior tooltipBehavior;
  late Web3Client ethClient;

  @override
  void initState() {
    super.initState();
    ethClient = Web3Client(infura_url, http.Client());
    chartData = [];
    tooltipBehavior = TooltipBehavior(enable: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('candidates').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Map<String, dynamic>> candidates =
              snapshot.data!.docs.map((doc) => doc.data()).toList();

          Future<List<int>> voteCountsFuture =
              Future.wait(candidates.map((candidate) async {
            return await getCandidateVoteCount(
                candidate['candidatesID'], ethClient);
          }));
          return FutureBuilder(
            future: voteCountsFuture,
            builder: (context, AsyncSnapshot<List<int>> voteCountsSnapshot) {
              if (voteCountsSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (
                voteCountsSnapshot.hasError) {
                return Center(
                    child: Text('Error: ${voteCountsSnapshot.error}'));
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

  List<ChartData> _createChartData(
      List<Map<String, dynamic>> candidates, List<int> voteCounts) {
    List<ChartData> chartData = [];
    for (int i = 0; i < candidates.length; i++) {
      Map<String, dynamic> candidate = candidates[i];
      chartData.add(ChartData(candidate['candidatesName'], voteCounts[i]));
    }
    return chartData;
  }

  Widget _buildChart(List<ChartData> chartData, int maxVoteCount) => Container(
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
        primaryYAxis:
            NumericAxis(minimum: 0, maximum: (maxVoteCount + 10), interval: 5),
        tooltipBehavior: TooltipBehavior(
          enable: true, 
          color: const Color.fromARGB(255, 247, 242, 249),
          textStyle: TextStyle(color: Colors.grey[800]), // Adjust the text color here
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
              isVisible: true, // Set your desired color here
            ),
          ),
        ],
      ));
  }

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final int y;
}
