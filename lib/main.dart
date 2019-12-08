import 'dart:async';
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

// Set up global String for location
String locationId = 'default';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

// Prepare future data
Future<Post> post;
Future<List> testList;

//void main() => runApp(MyApp());
Future<Null> main() async {
  sp = await SharedPreferences.getInstance();
  locationId = sp.getString('location') ?? 'default';
  //print("Saved location: " + sp.getString('location'));
  runApp(MyApp());
}

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
        '/Nearby': (context) => NearbyPage(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(            
        title: Text('temperatur.nu'),
      ),
      drawer: AppDrawer(),
      //body: _singleTemperatureView(),
      body: _singlePostPage(),
      floatingActionButton: _doubleFAB(),
    );
  }

  _singlePostPage() {
    return FutureBuilder(
      future: post,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              width: double.infinity,
              height: double.infinity,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 25,),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        snapshot.data.temperature + "°C",
                        style: Theme.of(context).textTheme.display4
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        snapshot.data.title,
                        style: Theme.of(context).textTheme.display3,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        snapshot.data.county,
                        style: Theme.of(context).textTheme.display1,
                      ),
                    ),
                    SizedBox(height: 20),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        snapshot.data.amm,
                        style: Theme.of(context).textTheme.body2,
                      ),
                    ),
                    SizedBox(height: 10,),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        snapshot.data.sourceInfo,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      child:Text(
                        "Uppdaterad " + snapshot.data.lastUpdate,
                        style: Theme.of(context).textTheme.caption,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        else if(snapshot.hasError) {
          return Text("${snapshot.error}");
        }

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
      ],
    );
  }
}