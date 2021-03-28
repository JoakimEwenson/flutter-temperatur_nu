import 'dart:async';
import 'dart:convert';
// ignore: unused_import
import 'dart:developer';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/controller/fetchPosition.dart';
import 'package:http/http.dart' as http;
import 'package:temperatur_nu/model/StationName.dart';

// Fetch data and return a single StationName object
Future<StationName> fetchStation(locationId) async {
  String data = await fetchSinglePost(locationId);
  var json = await jsonDecode(data);
  var stationList = json["stations"].values.toList();

  return StationName.fromRawJson(stationList[0]);
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
  Map<String, dynamic> urlParams = {
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
    urlParams.addAll(locationParams);
    Uri url = new Uri.https(apiUrl, apiVersion, urlParams);
    print("Fetching from $url");
    // Get data from API
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      // If server returns OK, parse response
      var content = response.body;
      // Save response string as cache
      prefs.setString('singlePostCache', content);

      // TODO: Fix saving of location id
      /*
      var locationId = content
          .findAllElements("item")
          .map((node) => node.findElements("id").single.text);

      // Save location id to local storage for later
      prefs.setString('location', locationId.single.trim().toString());
      */

      //return output;
      return content;
    } else {
      throw Exception('Misslyckades med att hämta data');
    }
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
