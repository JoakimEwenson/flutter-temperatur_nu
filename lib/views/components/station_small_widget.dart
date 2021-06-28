import 'package:flutter/material.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class StationDataSmallWidget extends StatelessWidget {
  const StationDataSmallWidget({
    Key key,
    @required this.station,
  }) : super(key: key);

  final Station station;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/SingleStation',
          arguments: LocationArguments(station.id),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Card(
          elevation: 0,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${station.temp}°',
                        style: temperatureBig,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${station.title}',
                        style: stationTitleSmall,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
