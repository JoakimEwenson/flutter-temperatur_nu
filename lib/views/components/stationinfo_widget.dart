import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

class StationInfoWidget extends StatelessWidget {
  const StationInfoWidget({Key key, @required this.station}) : super(key: key);

  final Station station;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: double.infinity,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Information om mätstationen',
                style: Theme.of(context)
                    .textTheme
                    .subtitle1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${station.sourceInfo}',
                style: Theme.of(context).textTheme.caption,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Mätstationen är placerad i ${station.kommun}, ${station.lan}.',
                      style: Theme.of(context).textTheme.caption,
                    ),
                    if (station.moh != null)
                      Text(
                        'Angiven höjd över havet: ${station.moh}m',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    if (station.uptime != null)
                      Text(
                        'Mätstationens upptid är ${station.uptime}%',
                        style: Theme.of(context).textTheme.caption,
                      ),
                  ],
                ),
              ),
              if (station.forutsattning.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Förutsättningar',
                        style: Theme.of(context).textTheme.subtitle2,
                      ),
                      Text(
                        '${station.forutsattning}',
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Senast uppdaterat kl. ${DateFormat("HH:mm").format(station.lastUpdate)} den ${DateFormat("d/M yyyy").format(station.lastUpdate)}.',
                    style: Theme.of(context).textTheme.caption.copyWith(),
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
