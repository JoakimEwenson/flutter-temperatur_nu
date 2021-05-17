import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/userHome.dart';
import 'package:temperatur_nu/model/UserSettings.dart';

// Set up global shared preferences
SharedPreferences sp;

Future<UserSettings> fetchUserSettings() async {
  sp = await SharedPreferences.getInstance();
  String _userHome = await fetchUserHome();
  double _nearbyDetailsNumber = await fetchNearbyDetailsNumber();
  double _nearbyPageNumber = await fetchNearbyPageNumber();
  bool _isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  LocationPermission _permission = await Geolocator.checkPermission();

  return UserSettings(_isLocationServiceEnabled, _permission, _userHome,
      _nearbyDetailsNumber, _nearbyPageNumber);
}

Future<bool> saveUserSettings(UserSettings settings) async {
  try {
    sp = await SharedPreferences.getInstance();
    if (settings.userHome == null) {
      removeUserHome();
    } else {
      saveUserHome(settings.userHome);
    }
    setNearbyDetailsNumber(settings.nearbyStationDetails);
    setNearbyPageNumber(settings.nearbyStationsPage);
    return true;
  } catch (e) {
    inspect(e);
    return false;
  }
}

// Fetch and set nearbystations_widget amount of stations
Future<double> fetchNearbyDetailsNumber() async {
  sp = await SharedPreferences.getInstance();

  return sp.containsKey('nearbyDetailsNumber')
      ? sp.getDouble('nearbyDetailsNumber')
      : 5.0;
}

void setNearbyDetailsNumber(double amount) async {
  sp = await SharedPreferences.getInstance();

  sp.setDouble('nearbyDetailsNumber', amount);
}

// Fetch and set nearby_page amount of stations
Future<double> fetchNearbyPageNumber() async {
  sp = await SharedPreferences.getInstance();

  return sp.containsKey('nearbyPageNumber')
      ? sp.getDouble('nearbyPageNumber')
      : 10.0;
}

void setNearbyPageNumber(double amount) async {
  sp = await SharedPreferences.getInstance();

  sp.setDouble('nearbyPageNumber', amount);
}
