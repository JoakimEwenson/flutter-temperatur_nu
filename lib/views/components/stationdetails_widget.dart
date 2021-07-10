import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/controller/colorTemperature.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/favhome_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class StationDetailsWidget extends StatefulWidget {
  const StationDetailsWidget({
    Key key,
    @required this.station,
    @required this.showBackButton,
  }) : super(key: key);

  final Station station;
  final bool showBackButton;

  @override
  _StationDetailsWidgetState createState() => _StationDetailsWidgetState();
}

class _StationDetailsWidgetState extends State<StationDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.showBackButton)
                IconButton(
                    icon: Icon(Icons.chevron_left),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Text(
                    widget.station.title,
                    style: pageTitle,
                  ),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: widget.station.temp != null
                              ? Semantics(
                                  label:
                                      'Just nu är det ${widget.station.temp}°C vid mätstationen ${widget.station.title}. Temperaturen senast uppdaterad ${DateFormat("yyyy-MM-dd HH:mm").format(widget.station.lastUpdate)}.',
                                  child: Text(
                                    "${widget.station.temp}°",
                                    style: temperatureHuge.copyWith(
                                        color: getColorTemperature(
                                            widget.station.temp, _isDarkMode)),
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Semantics(
                                  label:
                                      'Just nu finns det inget värde för mätstationen ${widget.station.title}.',
                                  child: Text(
                                    "$noTempDataString",
                                    style:
                                        Theme.of(context).textTheme.headline1,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                        ),
                        FavoriteHomeWidget(
                          station: widget.station,
                        ),
                        if (isTemperatureOld(widget.station.lastUpdate))
                          Container(
                            width: double.infinity,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  'Observera',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Temperaturen är senast uppdaterad för ${getTimeDifference(widget.station.lastUpdate)} minuter sedan.',
                                  style: TextStyle(color: Colors.red),
                                )
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
