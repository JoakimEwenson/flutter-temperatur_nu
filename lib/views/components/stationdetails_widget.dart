import 'package:flutter/material.dart';
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
                              ? Text(
                                  "${widget.station.temp}°",
                                  style: temperatureHuge,
                                  textAlign: TextAlign.center,
                                )
                              : Text(
                                  "N/A",
                                  style: Theme.of(context).textTheme.headline1,
                                  textAlign: TextAlign.center,
                                ),
                        ),
                        FavoriteHomeWidget(
                          station: widget.station,
                        )
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
