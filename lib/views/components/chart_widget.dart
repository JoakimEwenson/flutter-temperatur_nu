import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/ammdata_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

// This function cleans up the list of spots, removing empty ones at the tail
// to avoid problems drawing the temperature chart.
List<FlSpot> cleanSpotsList(List<FlSpot> spots) {
  if (spots.length > 0) {
    if (spots.last.y.isNaN == false) {
      return spots;
    }
    spots.removeLast();
    return cleanSpotsList(spots);
  }
  return null;
}

class ChartSpotList {
  ChartSpotList(this.spots, this.timestamps);
  List<FlSpot> spots;
  List<DateTime> timestamps;
}

ChartSpotList dataPostToFlSpot(List<DataPost> _dataPosts) {
  List<FlSpot> spots = [];
  List<DateTime> timestamps = [];
  int position = 0;
  int timestamp = 0;
  int timeLimit = 900000; // 900 000 ms == 15 minutes
  _dataPosts.forEach((_dataPost) {
    // Parse datetime string into DateTime objects for null check
    double temperature = double.tryParse(_dataPost.temperatur);
    DateTime dateTime = DateTime.tryParse(_dataPost.datetime);
    if (temperature.isNaN) {
      if (position != 0 && position != _dataPosts.length) {
        spots.add(
          //FlSpot(position.toDouble(), double.maxFinite),
          FlSpot.nullSpot,
        );
      }
      timestamps.add(dateTime);
      position++;
    }
    if (_dataPosts.length > 100 &&
        dateTime.millisecondsSinceEpoch > (timestamp + timeLimit)) {
      timestamp = dateTime.millisecondsSinceEpoch;
      if (temperature != null && !temperature.isNaN) {
        spots.add(
          FlSpot(
            position.toDouble(),
            temperature,
          ),
        );
      }
      timestamps.add(dateTime);
      position++;
    }
  });

  List<FlSpot> output = cleanSpotsList(spots);

  return ChartSpotList(output, timestamps);
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
    double chartMinY = _spots != null ? _spots[0].y : 0;
    double chartMaxY = _spots != null ? _spots[0].y : 30;
    // Check for highest and lowest temp to set graph limits, use 0 as baseline
    if (_spots != null) {
      _spots.forEach((element) {
        if (element.y.isNaN == false) {
          chartMinY = chartMinY < element.y ? chartMinY : element.y;
          chartMaxY = chartMaxY > element.y ? chartMaxY : element.y;
        }
      });
    }
    chartMinY = chartMinY > 0 ? 0 : chartMinY;

    double chartWidth = MediaQuery.of(context).size.width;
    double chartHeight = chartWidth * 0.6;

    // Min/Max times
    DateTime maxTime = amm != null ? DateTime.tryParse(amm.maxTime) : null;
    DateTime minTime = amm != null ? DateTime.tryParse(amm.minTime) : null;

    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    if (_spots != null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: chartHeight,
              width: chartWidth,
              margin: const EdgeInsets.fromLTRB(8, 8, 8, 8),
              child: LineChart(
                LineChartData(
                  minY: (chartMinY - 5).floorToDouble(),
                  maxY: (chartMaxY + 5).ceilToDouble(),
                  borderData: FlBorderData(
                    border: Border(
                      left: BorderSide(
                        color: _isDarkMode ? Colors.white12 : Colors.black12,
                        width: 2,
                      ),
                      top: BorderSide(
                        color: _isDarkMode ? Colors.white12 : Colors.black12,
                        width: 0,
                      ),
                      right: BorderSide(
                        color: _isDarkMode ? Colors.white12 : Colors.black12,
                        width: 0,
                      ),
                      bottom: BorderSide(
                        color: _isDarkMode ? Colors.white12 : Colors.black12,
                        width: 2,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: _isDarkMode ? Colors.white12 : Colors.black12,
                      strokeWidth: 1,
                    ),
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
                            bodyText.copyWith(
                              color: _isDarkMode
                                  ? lightModeTextColor
                                  : darkModeTextColor,
                            ),
                          );
                        }).toList();
                      },
                      tooltipBgColor: _isDarkMode
                          ? tempCardLightBackground
                          : tempCardDarkBackground,
                    ),
                  ),
                  lineBarsData: [
                    if (_spots != null)
                      LineChartBarData(
                        barWidth: 2,
                        //curveSmoothness: 1,
                        isCurved: false,
                        isStepLineChart: false,
                        preventCurveOverShooting: false,
                        colors: _isDarkMode ? [tnuYellow] : [tnuBlue],
                        dotData: FlDotData(show: false),
                        spots: _spots,
                      ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) => '${value.toStringAsFixed(0)}°',
                      getTextStyles: (value) => GoogleFonts.robotoMono(
                        color: _isDarkMode
                            ? darkModeTextColor
                            : lightModeTextColor,
                      ),
                      margin: 5,
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
              AmmDataWidget(
                amm: amm,
                maxTime: maxTime,
                minTime: minTime,
                spanStart: spanStart,
                spanEnd: spanEnd,
                isDarkMode: _isDarkMode,
              ),
          ],
        ),
      );
    }
    return Container();
  }
}
