import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/apiCaller.dart';
import 'package:temperatur_nu/controller/favorites.dart';
import 'package:temperatur_nu/controller/responseTranslator.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

Future<StationNameVerbose> fetchFavorites(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();

  // Output list of favorites
  var output;

  // Check if cached data should be fetched or if API call should be made
  if (getCache) {
    if (prefs.containsKey('favoritesListCache') &&
        prefs.getString('favoritesListCache') != "") {
      var json = prefs.getString('favoritesListCache');
      output = responseTranslator(json);
    }
  } else {
    // Save and fetch locally saved data
    List searchLocationList = await fetchLocalFavorites();
    String searchLocations = searchLocationList.join(',');
    // JSON based response
    Map<String, dynamic> settingsParams = {
      "verbose": "true",
    };
    Map<String, String> locationParams = {
      "p": searchLocations,
    };
    Map<String, dynamic> urlParams = {};
    urlParams.addAll(locationParams);
    urlParams.addAll(settingsParams);

    String data = await apiCaller(urlParams);

    // Write response to cache
    prefs.setString('favoritesListCache', data);

    output = responseTranslator(data);
  }

  return output;
}
