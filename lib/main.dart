import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Import local files
import 'common.dart';
import 'post.dart';

void main() => runApp(MyApp());


// Get location
Future<Position> fetchPosition() async {
  Position position = await Geolocator().getCurrentPosition().timeout(Duration(seconds: 15)).then((position) {
      //getting position without problems
      return position;
    }).catchError((error) {
        //handle the exception
        print(error);
    });

    return position;
}

// Another fetch API function
Future<Post> fetchPost() async {
  // Set up API URL
  String baseUrl = "https://api.temperatur.nu/tnu_1.15.php";
  String urlOptions = "&amm=true&dc=true&verbose=true&num=1&cli=" + Utils.createCryptoRandomString();
  String url;

  // Set up default location and empty location string for later use
  String defaultLocation = "kayravuopio";
  String location;

  // Setting up local data
  final prefs = await SharedPreferences.getInstance();
  //print("Saved location id: " + prefs.getString('location'));

  // Collect position
  Position position = await fetchPosition();

  if (position != null) {
    url = baseUrl + "?lat=" + position.latitude.toString() + "&lon=" + position.longitude.toString() + urlOptions;
  } 
  else {
    // Check if location id is stored in local storage or else, use default
    if (prefs.getString('location') != null) {
      location = prefs.getString('location');
    } 
    else {
      location = defaultLocation;
    }
    url = baseUrl + "?p=" + location + urlOptions;
  }



  // Get data from API
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // If server returns OK, parse XML result
    Post result = Post.fromXml(response.body);
    // Save location id to local storage for later
    prefs.setString('location', result.id.toString());
    print("Saving location id: " + result.id.toString());

    return Post.fromXml(response.body);
  } else {
    throw Exception('Misslyckades med att hämta data.');
  }
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
      ),
      home: MyHomePage(title: 'temperatur.nu'),
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
  // Prepare future data
  Future<Post> post;

  @override
  void initState() {
    super.initState();
    post = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(            
        title: Text('temperatur.nu'),
        backgroundColor: Colors.grey[800],
      ),
      drawer: _drawerList(),
      body: _singleTemperatureView(),
      floatingActionButton: new FloatingActionButton(
        onPressed: () {
          setState(() {
            post = fetchPost();
          });
        },
        tooltip: "Uppdatera",
        child: new Icon(Icons.update),
        backgroundColor: Colors.grey[800],
      ),
    );
  }

  _drawerList() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 150,
            child: DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.ac_unit, color: Colors.white,),
                    title: Text('HUVUDMENY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.grey[800],
              ),
            ),
          ),
          
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Startsida'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favoriter'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Mätpunkter'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Inställningar'),
            onTap: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
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
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 180,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            )
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
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                            )
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.normal
                          ),
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
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w200
                          ),
                        
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
}
