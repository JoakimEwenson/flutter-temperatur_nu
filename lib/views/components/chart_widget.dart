import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

List<FlSpot> dataPostToFlSpot(List<DataPost> _dataPosts) {
  List<FlSpot> output = [];
  int position = 0;
  _dataPosts.forEach((_dataPost) {
    double temperature = double.tryParse(_dataPost.temperatur);
    if (temperature == null) {
      print(temperature);
      output.add(FlSpot.nullSpot);
    }
    if (temperature != null && !temperature.isNaN) {
      output.add(
        FlSpot(
          position.toDouble(),
          temperature,
        ),
      );
      position++;
    }
  });

  return output;
}

class ChartWidget extends StatelessWidget {
  const ChartWidget({Key key, this.dataposts}) : super(key: key);

  final List<DataPost> dataposts;

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> _spots = dataPostToFlSpot(dataposts);
    double chartMinY = _spots[0].y.toInt().toDouble();
    double chartMaxY = _spots[0].y.toInt().toDouble();
    _spots.forEach((element) {
      chartMinY =
          chartMinY < element.y ? chartMinY : element.y.toInt().toDouble();
      chartMaxY =
          chartMaxY > element.y ? chartMaxY : element.y.toInt().toDouble();
    });

    double chartWidth = MediaQuery.of(context).size.width;
    double chartHeight = chartWidth * 0.6;

    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Senaste dygnet',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              height: chartHeight,
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
              child: LineChart(
                LineChartData(
                  minY: chartMinY - 3,
                  maxY: chartMaxY + 3,
                  borderData: FlBorderData(
                    show: false,
                  ),
                  lineTouchData: LineTouchData(enabled: true),
                  lineBarsData: [
                    LineChartBarData(
                      curveSmoothness: 5,
                      isCurved: true,
                      isStrokeCapRound: true,
                      preventCurveOverShooting: true,
                      colors: _isDarkMode ? [Colors.grey[100]] : [Colors.black],
                      dotData: FlDotData(show: false),
                      spots: _spots,
                    )
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                    ),
                    bottomTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
