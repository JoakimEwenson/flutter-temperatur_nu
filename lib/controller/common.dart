import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// Constant for deciding amount of maximum favorites
const int maxFavorites = 9999;
// Constant for setting cache timeout
// const int cacheTimeout = 300000;
const int cacheTimeout = 10000;
const int cacheTimeoutLong = cacheTimeout;

// Create a random CLI string until further notice.
// This is to not be locked out from the API until a proper key can be put in place.
class Utils {
  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 12]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

// Saving location for start screen
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
