import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/apiCaller.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/controller/fetchPosition.dart';
import 'package:temperatur_nu/model/StationName.dart';
import 'package:temperatur_nu/controller/responseTranslator.dart';

// Fetch data and return a single StationName object
Future<StationName> fetchStation(locationId) async {
  final prefs = await SharedPreferences.getInstance();

  String data = await fetchSinglePost(locationId);
  var stationList = await responseTranslator(data);
  var output = stationList[0];

  // Save location id to local storage for later, including gps if that was last requested
  prefs.setString('location', locationId);

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
    "json": "true",
    "amm": "true",
    "verbose": "true",
    "num": "1",
    "cli": Utils.createCryptoRandomString()
  };
  Map<String, dynamic> locationParams;

  // Set up default location and empty location string for later use
  String defaultLocation = "kayravuopio";
  String locationId;

  // Setting up local data
  final prefs = await SharedPreferences.getInstance();

  try {
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
        throw TimeoutException("Kunde inte hämta position");
      }
    } else if (location == 'default') {
      locationParams = {
        "p": defaultLocation,
      };
    } else {
      // Check if location id is stored in local storage or else, use default
      if (prefs.getString('location') != null) {
        locationId = prefs.getString('location');
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
  } on TimeoutException catch (e) {
    return e.toString();
  } on SocketException catch (e) {
    return e.toString();
  }
  // Handle empty or no result
  on StateError catch (e) {
    return e.toString();
  } catch (e) {
    return e.toString();
  }
}
