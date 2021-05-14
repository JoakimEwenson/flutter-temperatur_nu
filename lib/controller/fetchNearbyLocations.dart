import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/apiCaller.dart';
import 'package:temperatur_nu/controller/fetchPosition.dart';
import 'package:temperatur_nu/controller/responseTranslator.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

Future<StationNameVerbose> fetchNearbyLocations(bool getCache,
    {String latitude, String longitude, int amount = 10}) async {
  final prefs = await SharedPreferences.getInstance();

  // Initialize empty list of locations for now
  var output;
  Position position;

  // Check if cached data should be fetched
  if (getCache) {
    if (prefs.containsKey('nearbyLocationListCache') &&
        prefs.getString('nearbyLocationListCache') != "") {
      String data = prefs.getString('nearbyLocationListCache');
      output = responseTranslator(data);
    }
  } else {
    Map<String, dynamic> settingsParams = {
      "amm": "true",
      "verbose": "true",
      "num": amount.toString(),
    };
    Map<String, String> locationParams = {};
    if (latitude != null && longitude != null) {
      print('Lat: $latitude, long: $longitude');

      locationParams = {"lat": latitude, "lon": longitude};
    } else {
      position = await fetchPosition();

      if (position != null) {
        locationParams = {
          "lat": position.latitude.toString(),
          "lon": position.longitude.toString()
        };
      } else {
        throw TimeoutException("Kunde inte hitta din position.");
      }
    }
    Map<String, dynamic> urlParams = {};
    urlParams.addAll(locationParams);
    urlParams.addAll(settingsParams);

    String data = await apiCaller(urlParams);

    // Write response to cache
    prefs.setString('nearbyLocationListCache', data);

    output = responseTranslator(data);
  }

  return output;
}
