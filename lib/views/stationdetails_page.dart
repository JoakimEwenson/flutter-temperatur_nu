import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/favorites.dart';
import 'package:temperatur_nu/controller/fetchSinglePost.dart';
import 'package:temperatur_nu/controller/userHome.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/appinfo_widget.dart';
import 'package:temperatur_nu/views/components/chart_widget.dart';
import 'package:temperatur_nu/views/components/nearbystations_widget.dart';
import 'package:temperatur_nu/views/components/stationdetails_widget.dart';
import 'package:temperatur_nu/views/components/stationinfo_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

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

    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;

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
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: double.infinity,
                          child: Card(
                            elevation: 0,
                            child: Column(
                              children: [
                                TextButton.icon(
                                  icon: station.isFavorite
                                      ? Icon(
                                          Icons.favorite_outline,
                                          color: _isDarkMode
                                              ? Colors.grey[200]
                                              : Colors.grey[800],
                                        )
                                      : Icon(
                                          Icons.favorite,
                                          color: imperialRed,
                                        ),
                                  label: station.isFavorite
                                      ? Text(
                                          'Ta bort ${station.title} som favorit',
                                          style: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.grey[200]
                                                : Colors.grey[800],
                                          ),
                                        )
                                      : Text(
                                          'Lägg till ${station.title} som favorit',
                                          style: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.grey[200]
                                                : Colors.grey[800],
                                          )),
                                  onPressed: () async {
                                    try {
                                      if (station.isFavorite) {
                                        if (await removeFromFavorites(
                                            station.id)) {
                                          station.isFavorite =
                                              await existsInFavorites(
                                                  station.id);
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Tog bort ${station.title} från favoriter.',
                                                ),
                                              ),
                                            );
                                          setState(() {
                                            station.isFavorite = false;
                                          });
                                        } else {
                                          station.isFavorite =
                                              await existsInFavorites(
                                                  station.id);
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Det gick inte att ta bort ${station.title} från favoriter.'),
                                              ),
                                            );
                                          setState(() {
                                            station.isFavorite = false;
                                          });
                                        }
                                      } else {
                                        if (await addToFavorites(station.id)) {
                                          station.isFavorite =
                                              await existsInFavorites(
                                                  station.id);
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'La till ${station.title} i favoriter.'),
                                              ),
                                            );
                                          setState(() {
                                            station.isFavorite = true;
                                          });
                                        } else {
                                          station.isFavorite =
                                              await existsInFavorites(
                                                  station.id);
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Det gick inte att lägga till ${station.title} i favoriter.'),
                                              ),
                                            );
                                          setState(() {
                                            station.isFavorite = false;
                                          });
                                        }
                                        setState(() {});
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context)
                                        ..removeCurrentSnackBar()
                                        ..showSnackBar(
                                          SnackBar(
                                            content: Text(e.toString()),
                                          ),
                                        );
                                    }
                                  },
                                ),
                                TextButton.icon(
                                  onPressed: () async {
                                    try {
                                      if (station.isHome) {
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Du har tagit bort ${station.title} som hemstation'),
                                            ),
                                          );
                                        setState(() {
                                          station.isHome = false;
                                          removeUserHome();
                                        });
                                      } else if (!station.isHome) {
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  'Du har valt ${station.title} som hemstation'),
                                            ),
                                          );
                                        setState(() {
                                          saveUserHome(station.id);
                                          station.isHome = true;
                                        });
                                      }
                                    } catch (e) {}
                                  },
                                  icon: Icon(
                                    station.isHome
                                        ? Icons.home_outlined
                                        : Icons.home,
                                    color: _isDarkMode
                                        ? Colors.grey[200]
                                        : Colors.grey[800],
                                  ),
                                  label: station.isHome
                                      ? Text(
                                          'Ta bort ${station.title} som hemstation',
                                          style: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.grey[200]
                                                : Colors.grey[800],
                                          ),
                                        )
                                      : Text(
                                          'Välj ${station.title} som hemstation',
                                          style: TextStyle(
                                            color: _isDarkMode
                                                ? Colors.grey[200]
                                                : Colors.grey[800],
                                          ),
                                        ),
                                ),
                              ],
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
