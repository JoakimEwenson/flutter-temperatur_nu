import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/favhome_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class TemperatureCardWidget extends StatefulWidget {
  const TemperatureCardWidget({
    Key key,
    @required this.station,
    @required this.isDarkMode,
  }) : super(key: key);

  final Station station;
  final bool isDarkMode;

  @override
  _TemperatureCardWidgetState createState() => _TemperatureCardWidgetState();
}

class _TemperatureCardWidgetState extends State<TemperatureCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Just nu är det ${widget.station.temp}°C vid mätstationen ${widget.station.title}. Temperaturen senast uppdaterad ${DateFormat("yyyy-MM-dd HH:mm").format(widget.station.lastUpdate)}.',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isDarkMode
              ? tempCardDarkBackground
              : tempCardLightBackground,
          borderRadius: BorderRadius.circular(cardBorderRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      '${widget.station.title}',
                      style: tempCardTitle,
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text(
                      '${widget.station.kommun} - ${widget.station.lan}',
                      style: tempCardSubtitle,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 16,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FavoriteHomeWidget(
                  station: widget.station,
                ),
                Container(
                  child: Text(
                    widget.station.temp != null
                        ? '${widget.station.temp}°'
                        : '$noTempDataString',
                    style: tempCardTemperature,
                  ),
                ),
              ],
            ),
            if (isTemperatureOld(widget.station.lastUpdate))
              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Observera',
                      style: bodyText.copyWith(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Temperaturen är senast uppdaterad för ${getTimeDifference(widget.station.lastUpdate)} minuter sedan.',
                      style: bodyText.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
