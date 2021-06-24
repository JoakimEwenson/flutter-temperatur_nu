import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/fetchSinglePost.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/chart_widget.dart';
import 'package:temperatur_nu/views/components/nearbystations_widget.dart';
import 'package:temperatur_nu/views/components/stationdetails_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';
import 'package:temperatur_nu/views/drawer.dart';

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
                                      icon: Icon(Icons.bar_chart),
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
                                /*
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    TextButton.icon(
                                      icon: Icon(
                                        Icons.history,
                                        color: _isDarkMode
                                            ? Colors.grey[100]
                                            : Colors.grey[900],
                                      ),
                                      label: Text(
                                        'Dygn',
                                        style: TextStyle(
                                          color: _isDarkMode
                                              ? Colors.grey[100]
                                              : Colors.grey[900],
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          graphRange = '1day';
                                        });
                                        setGraphRange('1day');
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: Icon(
                                        Icons.view_week,
                                        color: _isDarkMode
                                            ? Colors.grey[100]
                                            : Colors.grey[900],
                                      ),
                                      label: Text(
                                        'Vecka',
                                        style: TextStyle(
                                          color: _isDarkMode
                                              ? Colors.grey[100]
                                              : Colors.grey[900],
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          graphRange = '1week';
                                        });
                                        setGraphRange('1week');
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: Icon(
                                        Icons.calendar_today,
                                        color: _isDarkMode
                                            ? Colors.grey[100]
                                            : Colors.grey[900],
                                      ),
                                      label: Text(
                                        'Månad',
                                        style: TextStyle(
                                          color: _isDarkMode
                                              ? Colors.grey[100]
                                              : Colors.grey[900],
                                        ),
                                      ),
                                      style: ButtonStyle(),
                                      onPressed: () {
                                        setState(() {
                                          graphRange = '1month';
                                        });
                                        setGraphRange('1month');
                                      },
                                    ),
                                    TextButton.icon(
                                      icon: Icon(
                                        Icons.wb_sunny,
                                        color: _isDarkMode
                                            ? Colors.grey[100]
                                            : Colors.grey[900],
                                      ),
                                      label: Text(
                                        'År',
                                        style: TextStyle(
                                          color: _isDarkMode
                                              ? Colors.grey[100]
                                              : Colors.grey[900],
                                        ),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          graphRange = '1year';
                                        });
                                        setGraphRange('1year');
                                      },
                                    ),
                                  ],
                                )
                                */
                              ],
                            ),
                          ),
                        ),
                      ),
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
