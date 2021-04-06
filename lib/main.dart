import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/controller/timestamps.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/model/TooManyFavoritesException.dart';

// Import views
import 'controller/favorites.dart';
import 'controller/fetchSinglePost.dart';
import 'views/drawer.dart';
import 'views/favoritespage.dart';
import 'views/nearbypage.dart';
import 'views/locationlistpage.dart';
import 'views/settingspage.dart';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  sp = await SharedPreferences.getInstance();
  locationId = sp.getString('location') ?? 'default';
  if (sp.containsKey('singlePostCache')) {
    //print("Cached string:\n" + sp.getString('singlePostCache'));
  }

  runApp(MyApp());
}

// Set up global String for location
String locationId = 'default';

// Prepare future data
Future<StationNameVerbose> post;

// Begin app
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'temperatur.nu',
      theme: ThemeData(
        appBarTheme: AppBarTheme(brightness: Brightness.dark),
        brightness: Brightness.light,
        accentColor: Colors.grey[100],
        primaryColor: Colors.grey[800],
        primaryColorBrightness: Brightness.dark,
        textTheme: TextTheme(),
      ),
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        accentColor: Colors.grey[100],
      ),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (context) => MyHomePage(),
        '/Favorites': (context) => FavoritesPage(),
        '/Nearby': (context) => NearbyListPage(),
        '/LocationList': (context) => LocationListPage(),
        '/Settings': (context) => SettingsPage(),
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
  final GlobalKey<RefreshIndicatorState> _mainRefreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  bool isFavorite = false;
  num timestamp;
  num timediff;
  Icon userLocationIcon = Icon(Icons.gps_not_fixed);

  @override
  void initState() {
    super.initState();
    locationId = sp.getString('location');
    Future.delayed(const Duration(milliseconds: 250), () async {
      if (!sp.containsKey('mainScreenTimeout')) {
        setTimeStamp('mainScreenTimeout');
      }

      setState(() {
        post = fetchStation(locationId);
        setTimeStamp('mainScreenTimeout');
      });
    });
    existsInFavorites(locationId).then((exists) {
      setState(() {
        isFavorite = exists;
      });
    });
  }

  Future<void> _refreshList() async {
    locationId = sp.getString('location');
    existsInFavorites(locationId).then((exists) {
      setState(() {
        isFavorite = exists;
      });
    });

    timestamp = int.tryParse(sp.getString('mainScreenTimeout'));
    timediff = compareTimeStamp(
        timestamp, DateTime.now().millisecondsSinceEpoch.toInt());
    if (timediff > cacheTimeoutLong) {
      setState(() {
        post = fetchStation(locationId);
        setTimeStamp('mainScreenTimeout');
      });
    } else {
      post = fetchStation(locationId);
    }
  }

  Future<void> _getGpsLocation() async {
    post = fetchStation('gps');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('temperatur.nu'),
        actions: [
          IconButton(
            icon: userLocationIcon,
            onPressed: () {
              setState(() {
                try {
                  _getGpsLocation();
                  userLocationIcon = Icon(Icons.gps_fixed);
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
        backgroundColor: Theme.of(context).accentColor,
        key: _mainRefreshIndicatorKey,
        onRefresh: () => _refreshList(),
      ),
    );
  }

  _singlePostPage() {
    // Get and check if arguments is passed to the screen
    final LocationArguments args = ModalRoute.of(context).settings.arguments;
    if (args != null) {
      locationId = args.locationId;
      sp.setString('location', locationId);
    } else {
      locationId = sp.getString('location');
    }
    // Check if location is in favorites
    existsInFavorites(locationId).then((exists) {
      isFavorite = exists;
    });

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
                  return LayoutBuilder(
                    builder: (BuildContext context,
                        BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        physics: AlwaysScrollableScrollPhysics(),
                        dragStartBehavior: DragStartBehavior.down,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight,
                            minWidth: viewportConstraints.maxWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              SizedBox(
                                height: 25,
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: station.temp != null
                                    ? Text(
                                        "${station.temp}°",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        "N/A",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline1,
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  station.title,
                                  style: Theme.of(context).textTheme.headline3,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Text(
                                station.kommun,
                                style: Theme.of(context).textTheme.headline5,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20),
                              if (station.amm != null &&
                                  station.amm.min != null &&
                                  station.amm.average != null &&
                                  station.amm.max != null)
                                Text(
                                  "min ${station.amm.min}° ◦ medel ${station.amm.average}° ◦ max ${station.amm.max}°",
                                  style: Theme.of(context).textTheme.bodyText1,
                                  textAlign: TextAlign.center,
                                ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                station.sourceInfo,
                                style: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                'Uppdaterad ${station.lastUpdate}',
                                style: Theme.of(context).textTheme.caption,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                child: isFavorite
                                    ? Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                        size: 50.0,
                                      )
                                    : Icon(
                                        Icons.favorite_border,
                                        size: 50,
                                      ),
                                onTap: () async {
                                  try {
                                    if (isFavorite) {
                                      if (await removeFromFavorites(
                                          station.id)) {
                                        isFavorite =
                                            await _checkFavoriteStatus();
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                            content: Text(
                                              'Tog bort ${station.title} från favoriter.',
                                            ),
                                          ));
                                        setState(() {
                                          isFavorite = false;
                                        });
                                      } else {
                                        isFavorite =
                                            await _checkFavoriteStatus();
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                            content: Text(
                                                'Det gick inte att ta bort ${station.title} från favoriter.'),
                                          ));
                                        setState(() {
                                          isFavorite = false;
                                        });
                                      }
                                    } else {
                                      if (await addToFavorites(station.id)) {
                                        isFavorite =
                                            await _checkFavoriteStatus();
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                            content: Text(
                                                'La till ${station.title} i favoriter.'),
                                          ));
                                        setState(() {
                                          isFavorite = true;
                                        });
                                      } else {
                                        isFavorite =
                                            await _checkFavoriteStatus();
                                        ScaffoldMessenger.of(context)
                                          ..removeCurrentSnackBar()
                                          ..showSnackBar(SnackBar(
                                            content: Text(
                                                'Det gick inte att lägga till ${station.title} i favoriter.'),
                                          ));
                                        setState(() {
                                          isFavorite = false;
                                        });
                                      }
                                      setState(() {});
                                    }
                                  } on TooManyFavoritesException catch (e) {
                                    ScaffoldMessenger.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(SnackBar(
                                        content: Text(e.errorMsg()),
                                      ));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context)
                                      ..removeCurrentSnackBar()
                                      ..showSnackBar(SnackBar(
                                        content: Text(e.toString()),
                                      ));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

  _checkFavoriteStatus() async {
    isFavorite = await existsInFavorites(locationId);
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
