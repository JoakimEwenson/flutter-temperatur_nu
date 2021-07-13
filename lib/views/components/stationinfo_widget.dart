import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class StationInfoWidget extends StatelessWidget {
  const StationInfoWidget(
      {Key key, @required this.station, @required this.isDarkMode})
      : super(key: key);

  final Station station;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? tempCardDarkBackground : tempCardLightBackground,
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            'Information om mätstationen',
            style: cardTitle,
          ),
          Text(
            '${station.sourceInfo}',
            style: bodySmallText,
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Mätstationen är placerad i ${station.kommun}, ${station.lan}.',
                  style: bodySmallText,
                ),
                if (station.uptime != null)
                  Text(
                    'Mätstationens upptid är ${station.uptime}%',
                    style: bodySmallText,
                  ),
              ],
            ),
          ),
          if (station.lat.isNotEmpty && station.lon.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Position',
                    style: bodyText.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Latitud: ${double.tryParse(station.lat).toStringAsPrecision(6)}',
                    style: bodySmallText,
                  ),
                  Text(
                    'Longitud: ${double.tryParse(station.lon).toStringAsPrecision(6)}',
                    style: bodySmallText,
                  ),
                  if (station.moh != null)
                    Text(
                      'Angiven höjd över havet: ${station.moh} meter',
                      style: bodySmallText,
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
                    style: bodyText.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${station.forutsattning}',
                    style: bodySmallText,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Text(
                'Senast uppdaterat kl. ${DateFormat("HH:mm").format(station.lastUpdate)} den ${DateFormat("d/M yyyy").format(station.lastUpdate)}.',
                style: bodySmallText.copyWith(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
