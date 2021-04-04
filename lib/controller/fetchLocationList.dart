import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/apiCaller.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/controller/responseTranslator.dart';
import 'package:temperatur_nu/model/StationName.dart';

Future<List<StationName>> fetchLocationList(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();
  var output;

  if (getCache) {
    if (prefs.containsKey('locationListCache') &&
        prefs.getString('locationListCache') != "") {
      String data = prefs.getString('locationListCache');
      output = responseTranslator(data);
    }
  } else {
    Map<String, dynamic> urlParams = {
      "json": "true",
      "cli": Utils.createCryptoRandomString(),
    };

    String data = await apiCaller(urlParams);
    prefs.setString('locationListCache', data);

    output = responseTranslator(data);
  }

  return output;
}
