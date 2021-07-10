import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/fetchNearbyLocations.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/model/UserSettings.dart';
import 'package:temperatur_nu/views/components/stationlistdivider_widget.dart';
import 'package:temperatur_nu/views/components/stationlisttile_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

Future<StationNameVerbose> nearby;
Future<UserSettings> userSettings;

Future<StationNameVerbose> _getNearbyStations(String lat, String lon) async {
  UserSettings _settings = await _getUserSettings();
  int amount =
      _settings != null ? _settings.nearbyStationDetails.toInt() + 1 : 6;

  return fetchNearbyLocations(
    false,
    latitude: lat,
    longitude: lon,
    amount: amount,
  );
}

Future<UserSettings> _getUserSettings() async {
  return await fetchUserSettings();
}

class NearbyStationsWidget extends StatefulWidget {
  const NearbyStationsWidget({
    Key key,
    this.latitude,
    this.longitude,
  }) : super(key: key);

  final String latitude;
  final String longitude;

  @override
  _NearbyStationsWidgetState createState() => _NearbyStationsWidgetState();
}

class _NearbyStationsWidgetState extends State<NearbyStationsWidget> {
  @override
  void initState() {
    super.initState();
    setState(() {
      nearby = _getNearbyStations(widget.latitude, widget.longitude);
    });
  }

  @override
  void dispose() {
    nearby = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: nearby,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            StationNameVerbose _nearbyStations = snapshot.data;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Närliggande mätstationer',
                      style: cardTitle,
                    ),
                  ),
                  Card(
                    elevation: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ListView.separated(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          separatorBuilder: (BuildContext context, int index) {
                            return StationListDivider();
                          },
                          itemCount: _nearbyStations.stations.length - 1,
                          itemBuilder: (BuildContext context, int index) {
                            Station _station =
                                _nearbyStations.stations[index + 1];
                            return StationListTile(station: _station);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return Container();
        });
  }
}
