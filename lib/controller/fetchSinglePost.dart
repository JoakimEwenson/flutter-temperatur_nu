import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/apiCaller.dart';
import 'package:temperatur_nu/controller/fetchPosition.dart';
import 'package:temperatur_nu/controller/responseTranslator.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

// Fetch data and return a single StationName object
Future<StationNameVerbose> fetchStation(locationId) async {
  String data = await fetchSinglePost(locationId);
  var output = await responseTranslator(data);

  // Save location id to local storage for later, including gps if that was last requested
  //final prefs = await SharedPreferences.getInstance();
  // prefs.setString(
  //     'location', output != null ? output.stations[0].id : "default");

  return output;
}

// Fetch cached single post data
Future<String> fetchSinglePostCache() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('singlePostCache')) {
    return prefs.getString('singlePostCache');
  } else {
    return "";
  }
}

// Fetching API data and return as string
Future<String> fetchSinglePost(String location) async {
  // Set up url parameters
  Map<String, dynamic> settingsParams = {
    "amm": "true",
    "data": "true",
    "verbose": "true",
    "num": "1",
  };
  Map<String, dynamic> locationParams;

  // Set up default location and empty location string for later use
  String defaultLocation = "kayravuopio";
  String locationId;

  // Setting up local data
  final prefs = await SharedPreferences.getInstance();

  // Check if GPS search or location ID search
  if (location == 'gps') {
    // Collect position (will return null if unable)
    Position position = await fetchPosition();

    if (position != null) {
      locationParams = {
        "lat": position.latitude.toString(),
        "lon": position.longitude.toString()
      };
    } else {
      throw TimeoutException("Kunde inte hitta din position.");
    }
  } else if (location == 'default') {
    locationParams = {
      "p": defaultLocation,
    };
  } else {
    if (location != null) {
      locationId = location;
    } else {
      locationId = defaultLocation;
    }
    locationParams = {
      "p": locationId,
    };
  }

  // Combine url parameters with location
  Map<String, dynamic> urlParams = {};
  urlParams.addAll(locationParams);
  urlParams.addAll(settingsParams);

  // Get data from API
  var content = await apiCaller(urlParams);
  // Save response string as cache
  prefs.setString('singlePostCache', content);

  //return output;
  return content;
}
