import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/theme.dart';

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
    if (dateTime.millisecondsSinceEpoch > (timestamp + timeLimit)) {
      timestamp = dateTime.millisecondsSinceEpoch;
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

    // Min/Max times
    DateTime maxTime = DateTime.tryParse(amm.maxTime);
    DateTime minTime = DateTime.tryParse(amm.minTime);

    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Text(
              'Temperaturgraf',
              style: cardTitle,
            ),
          ),
          Card(
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: chartHeight,
                  width: chartWidth,
                  margin: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                  child: LineChart(
                    LineChartData(
                      minY: (chartMinY - 5).floorToDouble(),
                      maxY: (chartMaxY + 5).ceilToDouble(),
                      borderData: FlBorderData(
                        show: false,
                      ),
                      gridData: FlGridData(
                        drawHorizontalLine: true,
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
                          barWidth: 2,
                          curveSmoothness: 1,
                          isCurved: true,
                          preventCurveOverShooting: true,
                          colors:
                              _isDarkMode ? [Colors.grey[100]] : [Colors.black],
                          dotData: FlDotData(show: false),
                          spots: _spots,
                        )
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: SideTitles(
                          showTitles: true,
                          getTitles: (value) => '${value.toStringAsFixed(0)}°',
                          getTextStyles: (value) => TextStyle(
                            color:
                                _isDarkMode ? Colors.grey[100] : Colors.black,
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
                  Container(
                    margin: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Table(
                            columnWidths: <int, TableColumnWidth>{
                              0: FractionColumnWidth(0.5),
                              1: FlexColumnWidth(),
                            },
                            children: [
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Text(
                                      'max',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${amm.max}°',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                          textAlign: TextAlign.right,
                                        ),
                                        Text(
                                          '$maxTime',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Text(
                                      'medel',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Text(
                                      '${amm.average}°',
                                      style:
                                          Theme.of(context).textTheme.caption,
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  TableCell(
                                    child: Text(
                                      'min',
                                      style: Theme.of(context)
                                          .textTheme
                                          .caption
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  TableCell(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${amm.min}°',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                          textAlign: TextAlign.right,
                                        ),
                                        Text(
                                          '$minTime',
                                          style: Theme.of(context)
                                              .textTheme
                                              .caption,
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Vald period:',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${DateFormat(longDateTimeFormat).format(spanStart)} - ${DateFormat(longDateTimeFormat).format(spanEnd)}',
                          style: Theme.of(context).textTheme.caption,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
