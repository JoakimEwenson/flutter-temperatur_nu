import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/fetchSinglePost.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/appinfo_widget.dart';
import 'package:temperatur_nu/views/components/chart_widget.dart';
import 'package:temperatur_nu/views/components/nearbystations_widget.dart';
import 'package:temperatur_nu/views/components/stationdetails_widget.dart';
import 'package:temperatur_nu/views/components/stationinfo_widget.dart';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

Future<StationNameVerbose> post;

String graphRange = '1day';

class StationDetailsPage extends StatefulWidget {
  @override
  _StationDetailsPageState createState() => _StationDetailsPageState();
}

class _StationDetailsPageState extends State<StationDetailsPage> {
  GlobalKey<RefreshIndicatorState> _mainRefreshKey =
      new GlobalKey<RefreshIndicatorState>();

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final LocationArguments args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      setState(() {
        post = fetchStation(args.locationId, graphRange: graphRange);
        print('State set with $graphRange');
      });
    }
    return Scaffold(
      appBar: Platform.isIOS
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
            )
          : null,
      body: SafeArea(
        child: RefreshIndicator(
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
                        if (station.data != null)
                          ChartWidget(
                            dataposts: station.data != null ? station.data : [],
                            amm: station.amm != null ? station.amm : null,
                          ),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Card(
                            elevation: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'Välj grafens tidsspann',
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle1
                                        .copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton(
                                        elevation: 0,
                                        isExpanded: true,
                                        icon: Icon(Icons.timeline),
                                        value: graphRange,
                                        onChanged: (value) {
                                          setGraphRange(value);
                                          setState(() {
                                            graphRange = value;
                                          });
                                          print('Chosen value: $value');
                                        },
                                        items: [
                                          DropdownMenuItem(
                                            value: '1day',
                                            child: Text('Senaste dygnet'),
                                          ),
                                          DropdownMenuItem(
                                            value: '1week',
                                            child: Text('Senaste veckan'),
                                          ),
                                          DropdownMenuItem(
                                            value: '1month',
                                            child: Text('Senaste månaden'),
                                          ),
                                          DropdownMenuItem(
                                            value: '1year',
                                            child: Text('Senaste året'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        NearbyStationsWidget(
                          latitude: station.lat,
                          longitude: station.lon,
                        ),
                        StationInfoWidget(station: station),
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
      ),
    );
  }
}
