import 'dart:async';
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/appinfo_widget.dart';
import 'package:temperatur_nu/views/components/chart_widget.dart';
import 'package:temperatur_nu/views/components/loading_widget.dart';
import 'package:temperatur_nu/views/components/nearbystations_widget.dart';
import 'package:temperatur_nu/views/components/stationdetails_widget.dart';
import 'package:temperatur_nu/views/components/stationinfo_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';
import 'package:temperatur_nu/views/stationdetails_page.dart';
import 'controller/fetchSinglePost.dart';
import 'views/favorites_page.dart';
import 'views/nearby_page.dart';
import 'views/locationlist_page.dart';
import 'views/settings_page.dart';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

// Set up global String for location and graph range
String defaultLocation = 'kayravuopio';
String defaultGraphRange = '1day';
String locationId;
String graphRange;

// Set up navigation
int _selectedTab = 0;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  /*
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.dark, // this one for iOS
    ),
  );
  */

  sp = await SharedPreferences.getInstance();
  locationId = sp.getString('userHome') ?? defaultLocation;
  graphRange = sp.getString('graphRange') ?? defaultGraphRange;

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
    /*
    var platform = Theme.of(context).platform;
    var appBarThemeiOS = AppBarTheme(
      brightness: Brightness.light,
    );
    var appBarTheme = AppBarTheme(
      backgroundColor: Colors.black,
      brightness: Brightness.dark,
    );
    */

    return MaterialApp(
      //debugShowCheckedModeBanner: false,
      title: 'temperatur.nu',
      theme: ThemeData(
        /* appBarTheme:
            platform == TargetPlatform.iOS ? appBarThemeiOS : appBarTheme, */
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

  @override
  void initState() {
    super.initState();
    locationId = sp.getString('userHome') ?? defaultLocation;
    graphRange = sp.getString('graphRange') ?? defaultGraphRange;

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
    super.dispose();
  }

  // ignore: unused_element
  Future<void> _getGpsLocation() async {
    try {
      post = fetchStation('gps', graphRange: graphRange);
    } catch (e) {
      inspect(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Specify list of page childrens
    final List<Widget> _children = [
      _singlePostPage(),
      FavoritesPage(),
      NearbyListPage(),
      LocationListPage(),
      SettingsPage(),
    ];
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: _selectedTab,
        //selectedItemColor: Colors.grey[200],
        //unselectedItemColor: Colors.grey[400],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (int index) {
          setState(() {
            _selectedTab = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Hem',
            tooltip: 'Gå till hemstationen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoriter',
            tooltip: 'Visa mina favoriter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.gps_fixed),
            label: 'Nära dig',
            tooltip: 'Lista närliggande mätstationer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Lista alla',
            tooltip: 'Lista alla mätstationer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Inställningar',
            tooltip: 'Inställningar',
          ),
        ],
      ),
      body: SafeArea(
        child: _children[_selectedTab],
      ),
    );
  }

  _singlePostPage() {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      backgroundColor: Theme.of(context).accentColor,
      key: _mainRefreshIndicatorKey,
      onRefresh: () async {
        if (locationId != null) {
          locationId = sp.getString('userHome') ?? locationId;
          setState(() {
            post = fetchStation(locationId, graphRange: graphRange);
          });
        }
      },
      child: FutureBuilder(
          future: post,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                {
                  return LoadingWidget();
                }
              case ConnectionState.active:
                {
                  return LoadingWidget();
                }
              case ConnectionState.done:
                {
                  if (snapshot.hasData) {
                    Station station = snapshot.data.stations[0];
                    //inspect(station);
                    return phoneMainScreen(station, context, _isDarkMode);
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
            return LoadingWidget();
          }),
    );
  }

  Widget tabletMainScreen(
      Station station, BuildContext context, bool _isDarkMode) {
    return Container(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        dragStartBehavior: DragStartBehavior.down,
        child: Row(
          children: [
            StationDetailsWidget(
              station: station,
              showBackButton: false,
            ),
            if (station.data != null)
              Column(
                children: [
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
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

  Widget phoneMainScreen(
      Station station, BuildContext context, bool _isDarkMode) {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      dragStartBehavior: DragStartBehavior.down,
      child: Column(
        children: [
          StationDetailsWidget(
            station: station,
            showBackButton: false,
          ),
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
                            setState(() {
                              graphRange = value;
                              setGraphRange(value);
                              post =
                                  fetchStation(locationId, graphRange: value);
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
