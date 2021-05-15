import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/fetchNearbyLocations.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/stationlisttile_widget.dart';

Future<StationNameVerbose> nearby;

Future<StationNameVerbose> _getNearbyStations(String lat, String lon) {
  return fetchNearbyLocations(false, latitude: lat, longitude: lon, amount: 6);
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
            return Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Närliggande mätpunkter',
                      style: Theme.of(context)
                          .textTheme
                          .subtitle1
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) {
                      return Divider();
                    },
                    itemCount: _nearbyStations.stations.length - 1,
                    itemBuilder: (BuildContext context, int index) {
                      Station _station = _nearbyStations.stations[index + 1];
                      return StationListTile(station: _station);
                    },
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
