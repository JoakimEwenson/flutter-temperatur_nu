import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Import views
import 'views/drawer.dart';
import 'views/favoritespage.dart';
import 'views/nearbypage.dart';
import 'views/locationlistpage.dart';
import 'views/settingspage.dart';

// Import local files
import 'common.dart';
import 'post.dart';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  sp = await SharedPreferences.getInstance();
  locationId = sp.getString('location') ?? 'default';

  runApp(MyApp());
}

// Set up global String for location
String locationId = 'default';

// Prepare future data
Future<Post> post;
Future<List> testList;

// Begin app
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'temperatur.nu',
      theme: ThemeData(
        brightness: Brightness.light,
        accentColor: Colors.grey[100],
        primaryColor: Colors.grey[800],
        
        textTheme: TextTheme(
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        accentColor: Colors.grey[100],
      ),
      //home: MyHomePage(title: 'temperatur.nu'),
      initialRoute: '/',
      routes: <String, WidgetBuilder> {
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
  final GlobalKey<RefreshIndicatorState> _mainRefreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    //post = fetchSinglePost(locationId);
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        post = fetchSinglePost(locationId);
      });
    });
  }

  Future<void> _refreshList() async {
    _mainRefreshIndicatorKey.currentState?.show();
    
    setState(() {
      post = fetchSinglePost(locationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(            
        title: Text('temperatur.nu'),
      ),
      drawer: AppDrawer(),
      //body: _singleTemperatureView(),
      body: RefreshIndicator(
        child: _singlePostPage(),
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).accentColor,
        key: _mainRefreshIndicatorKey,
        onRefresh:  () => _refreshList(),
      ),
      floatingActionButton: _doubleFAB(),
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
              return LayoutBuilder(
                // alignment: Alignment.topCenter,
                // margin: EdgeInsets.symmetric(horizontal: 20),
                builder: (BuildContext context, BoxConstraints viewportConstraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    physics: AlwaysScrollableScrollPhysics(),
                    dragStartBehavior: DragStartBehavior.down,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: viewportConstraints.maxHeight,
                        minWidth: viewportConstraints.maxWidth
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 25,),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              child: Text(snapshot.data.temperature + "°C",style: Theme.of(context).textTheme.display4),
                            ), 
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              child: Text(snapshot.data.title,style: Theme.of(context).textTheme.display3,),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              child: Text(snapshot.data.county,style: Theme.of(context).textTheme.display1,),
                              ),
                          ),
                          SizedBox(height: 20),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              child: Text(snapshot.data.amm,style: Theme.of(context).textTheme.body2,),
                            ),
                          ),
                          SizedBox(height: 10,),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              child: Text(snapshot.data.sourceInfo,style: Theme.of(context).textTheme.caption,),
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Container(
                              child: Text("Uppdaterad " + snapshot.data.lastUpdate,style: Theme.of(context).textTheme.caption,),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              );
            }
            else if(snapshot.hasError) {
              return noDataView(snapshot.error);
            }

            break;
          }
          case ConnectionState.none: 
          {
            return noDataView('Anslutningsfel');
          }
          
        }
        return loadingView();
      }
    );
  }

  // Loading indicator
  loadingView() {
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 25,),
          CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,),
          Text('Hämtar data', style: Theme.of(context).textTheme.display2,),
        ],
      ),
    );
  }

  noDataView(String msg) {
    return Center(
      child: Column(
        children: <Widget>[
          Text('Något gick fel!', style: Theme.of(context).textTheme.display2,),
          Text(msg, style: Theme.of(context).textTheme.body2,),
        ],
      ),
    );
  }

  // Multiple Floating Action Buttons setup
  _doubleFAB() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).accentColor,
          onPressed: () {
            setState(() {
              post = fetchSinglePost('gps');
            });
          },
          tooltip: 'Hämta position',
          child: new Icon(Icons.location_searching),
          heroTag: 'gpsFAB',
        ),
        /*
        SizedBox(
          height: 10,
        ),
        FloatingActionButton(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Theme.of(context).accentColor,
          onPressed: () {
            setState(() {
              post = fetchSinglePost(locationId);
            });
          },
          tooltip: 'Uppdatera temperaturdata',
          child: Icon(Icons.update),
          heroTag: 'updateFAB',
        ),
        */
      ],
    );
  }
}