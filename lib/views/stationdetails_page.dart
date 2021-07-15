import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/fetchSinglePost.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/chart_widget.dart';
import 'package:temperatur_nu/views/components/navbar_widget.dart';
import 'package:temperatur_nu/views/components/nearbystations_widget.dart';
import 'package:temperatur_nu/views/components/stationinfo_widget.dart';
import 'package:temperatur_nu/views/components/temperaturecard_widget.dart';
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
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    final LocationArguments args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      setState(() {
        post = fetchStation(args.locationId, graphRange: graphRange);
        //print('State set with $graphRange');
      });
    }

    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(),
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
                        /*
                        Align(
                          alignment: Alignment.topLeft,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(
                              Icons.chevron_left,
                              color: _isDarkMode
                                  ? darkModeTextColor
                                  : lightModeTextColor,
                            ),
                            label: Text(
                              'Tillbaka',
                              style: bodyText.copyWith(
                                color: _isDarkMode
                                    ? darkModeTextColor
                                    : lightModeTextColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        */
                        TemperatureCardWidget(
                          station: station,
                          isDarkMode: _isDarkMode,
                        ),
                        if (station.data != null)
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            padding: const EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: _isDarkMode
                                  ? tempCardDarkBackground
                                  : tempCardLightBackground,
                              borderRadius:
                                  BorderRadius.circular(cardBorderRadius),
                            ),
                            child: Column(
                              children: [
                                ChartWidget(
                                  dataposts:
                                      station.data != null ? station.data : [],
                                  amm: station.amm != null ? station.amm : null,
                                ),
                                SizedBox(
                                  height: 16,
                                ),
                                Container(
                                  width: double.infinity,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Välj grafens tidsspann',
                                          style: cardInnerTitle,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color:
                                                Theme.of(context).canvasColor,
                                          ),
                                          margin: const EdgeInsets.only(top: 8),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                          ),
                                          width: double.infinity,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton(
                                              elevation: 3,
                                              isExpanded: true,
                                              icon: Icon(Icons.timeline),
                                              value: graphRange,
                                              onChanged: (value) {
                                                setState(() {
                                                  graphRange = value;
                                                  setGraphRange(value);
                                                  post = fetchStation(
                                                    station.id,
                                                    graphRange: value,
                                                  );
                                                });
                                                //print('Chosen value: $value');
                                              },
                                              items: [
                                                DropdownMenuItem(
                                                  value: '1day',
                                                  child: Text(
                                                    'Senaste dygnet',
                                                    style: dropdownMenuItem,
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: '1week',
                                                  child: Text(
                                                    'Senaste veckan',
                                                    style: dropdownMenuItem,
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: '1month',
                                                  child: Text(
                                                    'Senaste månaden',
                                                    style: dropdownMenuItem,
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: '1year',
                                                  child: Text(
                                                    'Senaste året',
                                                    style: dropdownMenuItem,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        NearbyStationsWidget(
                          latitude: station.lat,
                          longitude: station.lon,
                          isDarkMode: _isDarkMode,
                        ),
                        StationInfoWidget(
                          station: station,
                          isDarkMode: _isDarkMode,
                        ),
                        SizedBox(
                          height: 32,
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Hittade inga uppgifter för ${args.locationId}.',
                      style: bodyText,
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.chevron_left,
                        size: 24,
                        color: _isDarkMode
                            ? darkModeTextColor
                            : lightModeTextColor,
                      ),
                      label: Text(
                        'Tillbaka',
                        style: bodyText.copyWith(
                          color: _isDarkMode
                              ? darkModeTextColor
                              : lightModeTextColor,
                        ),
                      ),
                    ),
                  ],
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
