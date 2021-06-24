import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/chart_widget.dart';
import 'package:temperatur_nu/views/components/nearbystations_widget.dart';
import 'package:temperatur_nu/views/components/stationdetails_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';
import 'package:temperatur_nu/views/stationdetails_page.dart';
import 'controller/fetchSinglePost.dart';
import 'views/drawer.dart';
import 'views/favorites_page.dart';
import 'views/nearby_page.dart';
import 'views/locationlist_page.dart';
import 'views/settings_page.dart';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

// Set up global String for location and graph range
String locationId;
String graphRange = '1day';

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.light, // this one for iOS
    ),
  );
  sp = await SharedPreferences.getInstance();
  locationId = sp.getString('userHome ');
  //graphRange = sp.getString('graphRange');

  runApp(MyApp());
}

// Set title
String pageTitle = "temperatur.nu";

// Prepare future data
Future<StationNameVerbose> post;
Future<StationNameVerbose> nearby;

// Begin app
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    var platform = Theme.of(context).platform;
    var appBarThemeiOS = AppBarTheme(
      brightness: Brightness.light,
    );
    var appBarTheme = AppBarTheme(
      backgroundColor: Colors.black,
      brightness: Brightness.dark,
    );
    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: 'temperatur.nu',
      theme: ThemeData(
        appBarTheme:
            platform == TargetPlatform.iOS ? appBarThemeiOS : appBarTheme,
        brightness: Brightness.light,
        canvasColor: appCanvasColor,
        accentColor: Colors.grey[100],
        primaryColor: Colors.grey[800],
        primaryColorBrightness: Brightness.light,
        textTheme: TextTheme(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          brightness: Brightness.dark,
        ),
        brightness: Brightness.dark,
        accentColor: Colors.grey[100],
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => MyHomePage(),
        '/Favorites': (context) => FavoritesPage(),
        '/LocationList': (context) => LocationListPage(),
        '/Nearby': (context) => NearbyListPage(),
        '/Settings': (context) => SettingsPage(),
        '/SingleStation': (context) => StationDetailsPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GlobalKey<RefreshIndicatorState> _mainRefreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  num timestamp;
  num timediff;
  Icon userLocationIcon = Icon(Icons.gps_not_fixed);

  @override
  void initState() {
    super.initState();
    locationId = sp.getString('userHome');
    //graphRange = sp.getString('graphRange');

    //print(locationId);
    Future.delayed(const Duration(milliseconds: 250), () async {
      setState(() {
        post = fetchStation(locationId, graphRange: graphRange);
      });
    });
  }

  @override
  void dispose() {
    post = null;
    nearby = null;
    userLocationIcon = Icon(Icons.gps_not_fixed);
    super.dispose();
  }

  Future<void> _getGpsLocation() async {
    try {
      post = fetchStation('gps', graphRange: graphRange);
    } catch (e) {
      inspect(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //title: Text(pageTitle),
        actions: [
          IconButton(
            icon: userLocationIcon,
            onPressed: () {
              setState(() {
                try {
                  _getGpsLocation();
                  userLocationIcon = Icon(
                    Icons.gps_fixed,
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(e.toString()),
                  ));
                }
              });
            },
          )
        ],
      ),
      drawer: AppDrawer(),
      //body: _singleTemperatureView(),
      body: RefreshIndicator(
        child: _singlePostPage(),
        color: Theme.of(context).primaryColor,
        key: _mainRefreshIndicatorKey,
        onRefresh: () async {
          if (locationId != null) {
            setState(() {
              post = fetchStation(locationId, graphRange: graphRange);
            });
          }
        },
      ),
    );
  }

  _singlePostPage() {
    return FutureBuilder(
        future: post,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              {
                return loadingView();
              }
            case ConnectionState.active:
              {
                return loadingView();
              }
            case ConnectionState.done:
              {
                if (snapshot.hasData) {
                  Station station = snapshot.data.stations[0];
                  //inspect(station);
                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    dragStartBehavior: DragStartBehavior.down,
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
                                          setState(() {
                                            graphRange = value;
                                            setGraphRange(value);
                                            post = fetchStation(locationId,
                                                graphRange: value);
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                            post = fetchStation(locationId,
                                                graphRange: '1day');
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
                                            post = fetchStation(locationId,
                                                graphRange: '1week');
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
                                            post = fetchStation(locationId,
                                                graphRange: '1month');
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
                                            post = fetchStation(locationId,
                                                graphRange: '1year');
                                          });
                                          setGraphRange('1year');
                                        },
                                      ),
                                    ],
                                  ),
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
                  );
                } else if (snapshot.hasError) {
                  return noDataView(snapshot.error);
                }

                break;
              }
            case ConnectionState.none:
              {
                break;
              }
          }
          return loadingView();
        });
  }

  // Loading indicator
  loadingView() {
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 25,
          ),
          CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          Text(
            'Hämtar data',
            style: Theme.of(context).textTheme.headline3,
          ),
        ],
      ),
    );
  }

  // Error/No data view
  noDataView(var msg) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          physics: AlwaysScrollableScrollPhysics(),
          dragStartBehavior: DragStartBehavior.down,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: viewportConstraints.maxHeight,
              maxWidth: viewportConstraints.maxWidth,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  'Något gick fel!',
                  style: Theme.of(context).textTheme.headline3,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "$msg",
                  style: Theme.of(context).textTheme.caption,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
