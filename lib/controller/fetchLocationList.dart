import 'dart:async';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/apiCaller.dart';
import 'package:temperatur_nu/controller/responseTranslator.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

Future<StationNameVerbose> fetchLocationList(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();
  var output;

  if (getCache) {
    if (prefs.containsKey('locationListCache') &&
        prefs.getString('locationListCache') != "") {
      String data = prefs.getString('locationListCache');
      output = responseTranslator(data);
    }
  } else {
    try {
      Map<String, dynamic> urlParams = {
        "coordinates": "true",
      };

      String data = await apiCaller(urlParams);

      prefs.setString('locationListCache', data);

      output = responseTranslator(data);
    } catch (e) {
      inspect(e);
      output = null;
    }
  }
  return output;
}
