import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

class ChartSpotList {
  ChartSpotList(this.spots, this.timestamps);
  List<FlSpot> spots;
  List<DateTime> timestamps;
}

ChartSpotList dataPostToFlSpot(List<DataPost> _dataPosts) {
  List<FlSpot> spots = [];
  List<DateTime> timestamps = [];
  int position = 0;
  _dataPosts.forEach((_dataPost) {
    // Parse datetime string into DateTime objects for null check
    double temperature = double.tryParse(_dataPost.temperatur);
    DateTime dateTime = DateTime.tryParse(_dataPost.datetime);
    if (temperature == null) {
      spots.add(FlSpot.nullSpot);
      timestamps.add(dateTime);
    }
    if (temperature != null && !temperature.isNaN) {
      spots.add(
        FlSpot(
          position.toDouble(),
          temperature,
        ),
      );
      timestamps.add(dateTime);
      position++;
    }
  });

  return ChartSpotList(spots, timestamps);
}

class ChartWidget extends StatelessWidget {
  const ChartWidget({Key key, this.dataposts, this.amm}) : super(key: key);

  final List<DataPost> dataposts;
  final Amm amm;

  @override
  Widget build(BuildContext context) {
    ChartSpotList spotList = dataPostToFlSpot(dataposts);
    final List<FlSpot> _spots = spotList.spots;
    DateTime spanStart = DateTime.tryParse(dataposts[0].datetime);
    DateTime spanEnd =
        DateTime.tryParse(dataposts[dataposts.length - 1].datetime);
    double chartMinY = _spots[0].y;
    double chartMaxY = _spots[0].y;
    // Check for highest and lowest temp to set graph limits, use 0 as baseline
    _spots.forEach((element) {
      chartMinY = chartMinY < element.y ? chartMinY : element.y;
      chartMaxY = chartMaxY > element.y ? chartMaxY : element.y;
    });
    chartMinY = chartMinY > 0 ? 0 : chartMinY;

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
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Text(
                'Temperaturgraf',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                'Visar perioden mellan ${DateFormat("d/M -yy HH:mm").format(spanStart)} och kl. ${DateFormat("d/M -yy HH:mm").format(spanEnd)}',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
            SizedBox(
              height: 8,
            ),
            Container(
              height: chartHeight,
              width: chartWidth,
              margin: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: LineChart(
                LineChartData(
                  minY: (chartMinY - 5).floorToDouble(),
                  maxY: (chartMaxY + 5).ceilToDouble(),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    horizontalInterval: 5,
                    show: true,
                  ),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItems: (tooltips) {
                        return tooltips.map((tooltip) {
                          DateTime timestamp =
                              spotList.timestamps[tooltip.x.toInt()];
                          return LineTooltipItem(
                            '${tooltip.y}°\n${DateFormat('d/M HH:mm').format(timestamp)}',
                            TextStyle(
                              color: _isDarkMode
                                  ? Colors.grey[900]
                                  : Colors.grey[100],
                            ),
                          );
                        }).toList();
                      },
                      tooltipBgColor:
                          _isDarkMode ? Colors.grey[100] : Colors.grey[900],
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      barWidth: 1,
                      curveSmoothness: 1,
                      isCurved: true,
                      preventCurveOverShooting: true,
                      colors: _isDarkMode ? [Colors.grey[100]] : [Colors.black],
                      dotData: FlDotData(show: false),
                      spots: _spots,
                    )
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) => '${value.toStringAsFixed(0)}°',
                      getTextStyles: (value) => TextStyle(
                        color: _isDarkMode ? Colors.grey[100] : Colors.black,
                      ),
                      margin: 8,
                      interval: 5,
                    ),
                    bottomTitles: SideTitles(showTitles: false),
                  ),
                ),
              ),
            ),
            if (amm != null &&
                amm.min != null &&
                amm.average != null &&
                amm.max != null)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Samlade värden för perioden',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    Text(
                      "min ${amm.min}° ◦ medel ${amm.average}° ◦ max ${amm.max}°",
                      style: Theme.of(context).textTheme.caption,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
