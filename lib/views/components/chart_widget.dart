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
    double chartHeight = chartWidth * 0.7;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Senaste dygnet',
                style: Theme.of(context).textTheme.subtitle2,
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: chartHeight,
                width: chartWidth,
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
                        colors: [
                          Colors.black,
                        ],
                        dotData: FlDotData(show: false),
                        spots: _spots,
                      )
                    ],
                    titlesData: FlTitlesData(
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
      ),
    );
  }
}
