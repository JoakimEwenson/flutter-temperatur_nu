import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

void main() => runApp(MyApp());

// Create a random CLI string until further notice.
// This is to not be locked out from the API until a proper key can be put in place.
class Utils {
  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 12]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

// Custom class for the post results
class Post {
  final String title;
  final String id;
  final String temperature;
  final String amm;
  final String lastUpdate;
  final String sourceInfo;
  final String sourceUrl;

  Post({
    this.title, 
    this.id,
    this.temperature, 
    this.amm,
    this.lastUpdate,
    this.sourceInfo,
    this.sourceUrl
  });

  // Parsing XML return from API
  factory Post.fromXml(String body) {
    // Parse API result as XML
    var content = xml.parse(body);
    // Locate and bind data
    var locationTitle = content.findAllElements("item").map((node) => node.findElements("title").single.text);
    var locationId = content.findAllElements("item").map((node) => node.findElements("id").single.text);
    var currentTemp = content.findAllElements("item").map((node) => node.findElements("temp").single.text);
    var lastUpdated = content.findAllElements("item").map((node) => node.findElements("lastUpdate").single.text);
    var sourceInfo = content.findAllElements("item").map((node) => node.findElements("sourceInfo").single.text);
    var sourceUrl = content.findAllElements("item").map((node) => node.findElements("url").single.text);
    // Average, min, max data
    var averageTemp = content.findAllElements("item").map((node) => node.findElements("average").single.text);
    var minTemp = content.findAllElements("item").map((node) => node.findElements("min").single.text);
    var maxTemp = content.findAllElements("item").map((node) => node.findElements("max").single.text);
    // var minTime = content.findAllElements("item").map((node) => node.findElements("minTime").single.text);
    // var maxTime = content.findAllElements("item").map((node) => node.findElements("maxTime").single.text);

    return Post(
      title: locationTitle.single.toString(), 
      id: locationId.single.toString(),
      temperature: currentTemp.single.toString() + "°C", 
      amm: "min " + minTemp.single.toString() + "°C ● medel " + averageTemp.single.toString() + "°C ● max " + maxTemp.single.toString() + "°C",
      lastUpdate: "Senast uppdaterad: " + lastUpdated.single.toString(),
      sourceInfo: sourceInfo.single.toString(),
      sourceUrl: sourceUrl.single.toString()
    );
  }
}

// Get location
Future<Position> fetchPosition() async {
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high).timeout(Duration(seconds: 10)).then((position) {
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
        primarySwatch: Colors.blue,
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
  Future<Position> position;

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
      body: Builder(
        builder: (context) => Center(
          child: Container(
            margin: EdgeInsets.all(20),
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  // Image
                  Image.asset(
                    'icon/Solflinga.png',
                    height: 100,
                  ),
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
                              fontSize: 100,
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
                              fontSize: 28,
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
                  FutureBuilder<Post>(
                    future: post,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Text(snapshot.data.amm,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 11,
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
                            fontSize: 10,
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
                  SizedBox(height: 20,),
                  RaisedButton(
                    onPressed: () {
                      setState(() {
                        post = fetchPost();
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: new BorderRadius.circular(18.0),
                    ),
                    padding: EdgeInsets.all(15),
                    color: Colors.grey[800],
                    textColor: Colors.white,
                    child: Text('UPPDATERA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold) ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
