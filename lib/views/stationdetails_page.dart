import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/fetchSinglePost.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/nearbystations_widget.dart';
import 'package:temperatur_nu/views/components/stationdetails_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';
import 'package:temperatur_nu/views/drawer.dart';

Future<StationNameVerbose> post;

class StationDetailsPage extends StatefulWidget {
  @override
  _StationDetailsPageState createState() => _StationDetailsPageState();
}

class _StationDetailsPageState extends State<StationDetailsPage> {
  GlobalKey<RefreshIndicatorState> _mainRefreshKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final LocationArguments args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      setState(() {
        post = fetchStation(args.locationId);
      });
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        key: _mainRefreshKey,
        child: FutureBuilder(
          future: post,
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              Station station = snapshot.data.stations[0];
              return Container(
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      StationDetailsWidget(station: station),
                      NearbyStationsWidget(
                        latitude: station.lat,
                        longitude: station.lon,
                      ),
                      appInfo(),
                    ],
                  ),
                ),
              );
            }

            return Container(
              child: Center(
                child: Text('Hittade inga uppgifter för ${args.locationId}'),
              ),
            );
          },
        ),
        onRefresh: () async {
          setState(() {
            post = fetchStation(args.locationId);
          });
        },
      ),
    );
  }
}
