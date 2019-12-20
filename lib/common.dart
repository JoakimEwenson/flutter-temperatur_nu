import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
//import 'package:crypto/crypto.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

import 'post.dart';
import 'locationlistitem.dart';

// Make global base URL for API
String baseUrl = "https://api.temperatur.nu/tnu_1.15.php";

// Create a random CLI string until further notice.
// This is to not be locked out from the API until a proper key can be put in place.
class Utils {
  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 12]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

saveLocationId(String savedId) async {
  var sp = await SharedPreferences.getInstance();
  sp = await SharedPreferences.getInstance();
  sp.setString('location', savedId);
}

Future<String> fetchLocallySavedData() async {
  // Setting up local data
  final prefs = await SharedPreferences.getInstance();
  String location = prefs.getString('location') ?? 'default';

  return location;
}

// Get location
Future<Position> fetchPosition() async {
  Position position = await Geolocator().getCurrentPosition().then((position) {
      //getting position without problems
      return position;
    }).catchError((error) {
        //handle the exception
        print(error);
    });

    return position;
}

// Another fetch API function
Future<Post> fetchSinglePost(String location) async {
  // Set up API URL
  String urlOptions = "&amm=true&dc=true&verbose=true&num=1&cli=" + Utils.createCryptoRandomString();
  String url;

  // Set up default location and empty location string for later use
  String defaultLocation = "kayravuopio";
  String locationId;

  // Setting up local data
  final prefs = await SharedPreferences.getInstance();

  if (location == 'gps') {
    // Collect position
    Position position = await fetchPosition();

    if (position != null) {
      url = baseUrl + "?lat=" + position.latitude.toString() + "&lon=" + position.longitude.toString() + urlOptions;
    }
    else {
      if (prefs.getString('location') != null) {
        locationId = prefs.getString('location');
      } 
      else {
        locationId = defaultLocation;
      }
    url = baseUrl + "?p=" + locationId + urlOptions;
    }
    //print("GPS searching...");
  }
  else if (location == 'default') {
    url = baseUrl + "?p=" + defaultLocation + urlOptions;

    //print("Using " + defaultLocation);
  }
  else {
    // Check if location id is stored in local storage or else, use default
    if (prefs.getString('location') != null) {
      locationId = prefs.getString('location');
    } 
    else {
      locationId = defaultLocation;
    }
    url = baseUrl + "?p=" + locationId + urlOptions;

    //print("Using " + location);
  }

  try {
    // Get data from API
    final response = await 
    http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      // If server returns OK, parse XML result
      //Post result = Post.fromXml(response.body);

      var content = xml.parse(response.body);

      var locationTitle = content.findAllElements("item").map((node) => node.findElements("title").single.text);
      var locationId = content.findAllElements("item").map((node) => node.findElements("id").single.text);
      var currentTemp = content.findAllElements("item").map((node) => node.findElements("temp").single.text);
      var lastUpdated = content.findAllElements("item").map((node) => node.findElements("lastUpdate").single.text);
      var municipality = content.findAllElements("item").map((node) => node.findElements("kommun").single.text);
      var county = content.findAllElements("item").map((node) => node.findElements("lan").single.text);
      var sourceInfo = content.findAllElements("item").map((node) => node.findElements("sourceInfo").single.text);
      var sourceUrl = content.findAllElements("item").map((node) => node.findElements("url").single.text);
      // Average, min, max data
      var averageTemp = content.findAllElements("item").map((node) => node.findElements("average").single.text);
      var minTemp = content.findAllElements("item").map((node) => node.findElements("min").single.text);
      var maxTemp = content.findAllElements("item").map((node) => node.findElements("max").single.text);
      // Currently not used but available data
      // var minTime = content.findAllElements("item").map((node) => node.findElements("minTime").single.text);
      // var maxTime = content.findAllElements("item").map((node) => node.findElements("maxTime").single.text);

      var output = new Post(
        title: locationTitle.single.trim().toString(),
        id: locationId.single.trim().toString(),
        temperature: currentTemp.single.toString(),
        amm: "min " + minTemp.single.toString() + "°C ◦ medel " + averageTemp.single.toString() + "°C ◦ max " + maxTemp.single.toString() + "°C",
        lastUpdate: lastUpdated.single.toString(),
        municipality: municipality.single.toString(),
        county: county.single.toString(),
        sourceInfo: sourceInfo.single.toString(),
        sourceUrl: sourceUrl.single.toString(),
      );

      // Save location id to local storage for later
      prefs.setString('location', output.id);

      //return Post.fromXml(response.body);
      return output;
    } else {
      throw Exception('Misslyckades med att hämta data.');
    }
  }
  on TimeoutException catch (e) {
    var output = new Post(
      title: "Hämtning av data tog för lång tid.",
      lastUpdate: DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
    );
    return output;
  }
  catch (e) {
    return new Post(
      title: "Något gick snett.",
      lastUpdate: DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
    );
  }
}

Future<List> fetchFavorites(List favlist) async {
  String searchLocations = favlist.join(',');
  String urlOptions = "&amm=true&dc=true&verbose=true&cli=" + Utils.createCryptoRandomString();
  String url = baseUrl + "?p=" + searchLocations + urlOptions;

  final response = await http.get(url);

  if (response.statusCode == 200) {
    var content = xml.parse(response.body);
    List favoritesList = new List();

    content.findAllElements("item").forEach((row) {
      var locationTitle = row.findElements('title').single.text.trim().toString();
      var locationId = row.findElements('id').single.text.trim().toString();
      var currentTemp = row.findElements('temp').single.text.trim().toString();
      var amm = "min " + row.findElements('min').single.text.trim().toString() + "°C ◦ medel " + row.findElements('average').single.text.trim().toString() + "°C ◦ max " + row.findElements('max').single.text.trim().toString() + "°C";
      var lastUpdate = row.findElements('lastUpdate').single.text.trim().toString();
      var municipality = row.findElements('kommun').single.text.trim().toString();
      var county = row.findElements('lan').single.text.trim().toString();
      var sourceInfo = row.findElements('sourceInfo').single.text.trim().toString();
      var sourceUrl = row.findElements('url').single.text.trim().toString();

      var output = new Post(
        title: locationTitle,
        id: locationId,
        temperature: currentTemp,
        amm: amm,
        lastUpdate: lastUpdate,
        municipality: municipality,
        county: county,
        sourceInfo: sourceInfo,
        sourceUrl: sourceUrl 
      );
      favoritesList.add(output);
    });

    return favoritesList;
  }
  else {
    throw Exception('Misslyckades med att hämta data.');
  }
}

Future<List> fetchNearbyLocations() async {
  // Set up API URL
  String urlOptions = "&amm=true&dc=true&verbose=true&num=5&cli=" + Utils.createCryptoRandomString();
  String url;

  // Create empty list for later
  List nearbyLocations = new List();

  Position position = await fetchPosition();

  if (position != null) {
    url = baseUrl + "?lat=" + position.latitude.toString() + "&lon=" + position.longitude.toString() + urlOptions;

    final response = await http.get(url);

    if (response.statusCode == 200) {
      // If server returns OK, parse XML result
      var content = xml.parse(response.body);

      content.findAllElements("item").forEach((row) {
        var locationTitle = row.findElements("title").single.text.trim().toString();
        var locationId = row.findElements("id").single.text.trim().toString();
        var currentTemp = row.findElements("temp").single.text.trim().toString();
        var distance = row.findElements("dist").single.text.trim().toString();
        var lastUpdated = row.findElements("lastUpdate").single.text.trim().toString();
        var municipality = row.findElements("kommun").single.text.trim().toString();
        var county = row.findElements("lan").single.text.trim().toString();
        var sourceInfo = row.findElements("sourceInfo").single.text.trim().toString();
        var sourceUrl = row.findElements("url").single.text.trim().toString();
        // Average, min, max data
        var averageTemp = row.findElements("average").single.text.trim().toString();
        var minTemp = row.findElements("min").single.text.trim().toString();
        var maxTemp = row.findElements("max").single.text.trim().toString();

        var output = new Post(
          title: locationTitle,
          id: locationId,
          temperature: currentTemp,
          distance: distance,
          amm: "min " + minTemp + "°C ◦ medel " + averageTemp + "°C ◦ max " + maxTemp + "°C",
          lastUpdate: lastUpdated,
          municipality: municipality,
          county: county,
          sourceInfo: sourceInfo,
          sourceUrl: sourceUrl,
        );
        nearbyLocations.add(output);
      });

      return nearbyLocations;
    }
  }
  else {
    throw Exception('Misslyckades med att hämta position');
  }

  return nearbyLocations;
}

Future<List> fetchLocationList() async {
  // Set up API URL
  String urlOptions = "?cli=" + Utils.createCryptoRandomString();
  String url = baseUrl + urlOptions;

  // Collect data from API
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // If server responds with OK, parse XML result
    var content = xml.parse(response.body);
    List locationList = new List();

    // Iterate results and make into list
    content.findAllElements('item').forEach((row) {
      var locationTitle = row.findElements('title').single.text.trim().toString();
      var locationId = row.findElements('id').single.text.trim().toString();
      var locationTemperature = row.findElements('temp').single.text.trim().toString();
      var output  = new LocationListItem(
        title: locationTitle, 
        id: locationId, 
        temperature: locationTemperature
      );
      locationList.add(output);
    });
  
    return locationList;
  }
  else {
    throw Exception('