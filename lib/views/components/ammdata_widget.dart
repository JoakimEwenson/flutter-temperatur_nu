import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class AmmDataWidget extends StatelessWidget {
  const AmmDataWidget({
    Key key,
    @required this.amm,
    @required this.maxTime,
    @required this.minTime,
    @required this.spanStart,
    @required this.spanEnd,
    @required this.isDarkMode,
  }) : super(key: key);

  final Amm amm;
  final DateTime maxTime;
  final DateTime minTime;
  final DateTime spanStart;
  final DateTime spanEnd;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 8),
            child: Table(
              columnWidths: <int, TableColumnWidth>{
                0: FractionColumnWidth(0.3),
                1: FlexColumnWidth(),
              },
              border: TableBorder(
                horizontalInside: BorderSide(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                  width: 2,
                ),
                bottom: BorderSide(
                  color: isDarkMode ? Colors.white12 : Colors.black12,
                  width: 2,
                ),
              ),
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Text(
                          'max',
                          style: ammHeader,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${amm.max}°',
                              style: ammValue,
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              '${DateFormat(shortDateTimeFormat).format(maxTime)}',
                              style: ammTime,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Text(
                          'min',
                          style: ammHeader,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${amm.min}°',
                              style: ammValue,
                              textAlign: TextAlign.right,
                            ),
                            Text(
                              '${DateFormat(shortDateTimeFormat).format(minTime)}',
                              style: ammTime,
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Text(
                          'medel',
                          style: ammHeader,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Text(
                          '${amm.average}°',
                          style: ammValue,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            'Vald period:',
            style: ammHeader,
          ),
          Text(
            'Mellan ${DateFormat(shortDateTimeFormat).format(spanStart)} och ${DateFormat(shortDateTimeFormat).format(spanEnd)}.',
            style: ammTime,
          ),
        ],
      ),
    );
  }
}
