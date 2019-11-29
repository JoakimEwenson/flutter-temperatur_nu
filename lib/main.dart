import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
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
  final String temperature;
  final String lastUpdate;
  final String sourceInfo;
  final String sourceUrl;

  Post({
    this.title, 
    this.temperature, 
    this.lastUpdate,
    this.sourceInfo,
    this.sourceUrl
  });

  // Parsing XML return from API
  factory Post.fromXml(String body) {
    // Parse API result as XML
    var content = xml.parse(body);
    // Locate and bind data
    var currentTemp = content.findAllElements("item").map((node) => node.findElements("temp").single.text);
    var locationTitle = content.findAllElements("item").map((node) => node.findElements("title").single.text);
    var lastUpdated = content.findAllElements("item").map((node) => node.findElements("lastUpdate").single.text);
    var sourceInfo = content.findAllElements("item").map((node) => node.findElements("sourceInfo").single.text);
    var sourceUrl = content.findAllElements("item").map((node) => node.findElements("url").single.text);
    // Average, min, max data
    var averageTemp = content.findAllElements("item").map((node) => node.findElements("average").single.text);
    var minTemp = content.findAllElements("item").map((node) => node.findElements("min").single.text);
    var maxTemp = content.findAllElements("item").map((node) => node.findElements("max").single.text);
    var minTime = content.findAllElements("item").map((node) => node.findElements("minTime").single.text);
    var maxTime = content.findAllElements("item").map((node) => node.findElements("maxTime").single.text);

    return Post(
      temperature: currentTemp.single.toString() + "°C", 
      title: locationTitle.single.toString(), 
      lastUpdate: "Senast uppdaterad: " + lastUpdated.single.toString(),
      sourceInfo: sourceInfo.single.toString(),
      sourceUrl: sourceUrl.single.toString()
    );
  }
}

// Get location
Future<Position> fetchPosition() async {
  Position position = await Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

  return position;
}

// Another fetch API function
Future<Post> fetchPost(String url) async {
  // Collect position
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // If server returns OK, parse XML result
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
      home: MyHomePage(title: 'Temperatur.nu'),
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
    post = fetchPost(apiUrl);
    position = fetchPosition();
  }

  // Set up API call
  static String cli = Utils.createCryptoRandomString();
  static String locationId = "kayravuopio";
  //String apiUrl = "https://api.temperatur.nu/tnu_1.15.php?p=" + locationId + "&amm=true&dc=true&verbose&cli=" + cli;
  String apiUrl = "https://api.temperatur.nu/tnu_1.15.php?lat=58.376761&lon=15.562916&amm=true&dc=true&verbose=true&num=1&cli=" + cli;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(            
        title: Text('temperatur.nu'),            
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Temperature results
              FutureBuilder<Post>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.temperature, 
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 84,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      )
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
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
                    return Text(snapshot.data.title,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24
                    )
                  );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  // By default, return placeholder text
                  return Text("Loading data");
                }
              ),
              SizedBox(height: 10),
              // Last updated at timestamp
              FutureBuilder<Post>(
                future: post,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Text(snapshot.data.lastUpdate, 
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
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
                    cli = Utils.createCryptoRandomString();
                    post = fetchPost(apiUrl);
                  });
                },
                padding: EdgeInsets.all(10),
                color: Colors.blue,
                textColor: Colors.white,
                child: Text('Uppdatera', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold) ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
