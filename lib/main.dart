import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


// Import views
import 'views/drawer.dart';
import 'views/favoritespage.dart';
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

//void main() => runApp(MyApp());
Future<Null> main() async {
  sp = await SharedPreferences.getInstance();
  locationId = sp.getString('location') ?? 'default';
  print("Saved location: " + sp.getString('location'));
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
  
  //String locationId = 'default';

  @override
  void initState() {
    super.initState();
    //post = fetchPost(locationId);
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        post = fetchPost(locationId);
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
      body: _singleTemperatureView(),
      floatingActionButton: _doubleFAB(),
    );
  }


  _singleTemperatureView() {
    return Builder(
      builder: (context) => Center(
        child: Container(
          margin: EdgeInsets.all(20),
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Temperature results
                FutureBuilder<Post>(
                  future: post,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return FittedBox(fit: BoxFit.fitWidth,
                        child:
                          Text(snapshot.data.temperature, 
                          style: Theme.of(context).textTheme.display4,
                        )
                      );
                    } else if (snapshot.hasError) {
                      return Text("n/a");
                    }
                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  }
                ),
                // Location Title
                FutureBuilder<Post>(
                  future: post,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return FittedBox(fit: BoxFit.fitWidth,
                        child:
                          Text(snapshot.data.title,
                          style: Theme.of(context).textTheme.display3,
                      )
                      );
                    } else if (snapshot.hasError) {
                      return Text("- - -");
                    }
                    // By default, return placeholder text
                    return Text("Hämtar data");
                  }
                ),
                SizedBox(height: 10),
                // Min, max, average title
                FutureBuilder<Post>(
                  future: post,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.amm,
                        style: Theme.of(context).textTheme.body2
                      );
                    } else if (snapshot.hasError) {
                      return Text("- - -");
                    }

                    return Text("");
                  }
                ),
                SizedBox(height: 10,),
                // Last updated at timestamp
                FutureBuilder<Post>(
                  future: post,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(snapshot.data.lastUpdate, 
                        style: Theme.of(context).textTheme.caption
                      
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    return Text("");
                  }
                ),
              ],
            ),
          ),
        ),
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
              post = fetchPost('gps');
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
              post = fetchPost(locationId);
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