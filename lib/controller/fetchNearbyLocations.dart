import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/apiCaller.dart';
import 'package:temperatur_nu/controller/fetchPosition.dart';
import 'package:temperatur_nu/controller/responseTranslator.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

Future<StationNameVerbose> fetchNearbyLocations(bool getCache) async {
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
    position = await fetchPosition();

    if (position != null) {
      Map<String, dynamic> settingsParams = {
        "amm": "true",
        "verbose": "true",
        "num": "10",
      };
      Map<String, String> locationParams = {
        "lat": position.latitude.toString(),
        "lon": position.longitude.toString()
      };
      Map<String, dynamic> urlParams = {};
      urlParams.addAll(locationParams);
      urlParams.addAll(settingsParams);

      String data = await apiCaller(urlParams);

      // Write response to cache
      prefs.setString('nearbyLocationListCache', data);

      output = responseTranslator(data);
    } else {
      throw TimeoutException("Kunde inte hitta din position.");
    }
  }

  return output;
}
