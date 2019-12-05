import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'post.dart';

// Create a random CLI string until further notice.
// This is to not be locked out from the API until a proper key can be put in place.
class Utils {
  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 12]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

Future<String> fetchLocallySavedData() async {
  // Setting up local data
  final prefs = await SharedPreferences.getInstance();
  String location = prefs.getString('location') ?? 'default';

  return location;
}

// Get location
Future<Position> fetchPosition() async {
  Position position = await Geolocator().getCurrentPosition().timeout(Duration(seconds: 15)).then((position) {
      //getting position without problems
      return position;
    }).catchError((error) {
        //handle the exception
        print(error);
    });

    return position;
}

// Another fetch API function
Future<Post> fetchPost(String location) async {
  // Set up API URL
  String baseUrl = "https://api.temperatur.nu/tnu_1.15.php";
  String urlOptions = "&amm=true&dc=true&verbose=true&num=1&cli=" + Utils.createCryptoRandomString();
  String url;

  // Set up default location and empty location string for later use
  String defaultLocation = "kayravuopio";
  String locationId;

  // Setting up local data
  final prefs = await SharedPreferences.getInstance();

  if (location == 'gps') {
    // Collect position
    Position position = await fetchPosition();

    if (position != null) {
      url = baseUrl + "?lat=" + position.latitude.toString() + "&lon=" + position.longitude.toString() + urlOptions;
    } 
    print("GPS searching...");
  }
  else if (location == 'default') {
    url = baseUrl + "?p=" + defaultLocation + urlOptions;

    print("Using " + defaultLocation);
  }
  else {
    // Check if location id is stored in local storage or else, use default
    if (prefs.getString('location') != null) {
      location = prefs.getString('location');
    } 
    else {
      locationId = defaultLocation;
    }
    url = baseUrl + "?p=" + locationId + urlOptions;

    print("Using " + location);
  }

  // Get data from API
  final response = await http.get(url);

  if (response.statusCode == 200) {
    // If server returns OK, parse XML result
    Post result = Post.fromXml(response.body);
    // Save location id to local storage for later
    prefs.setString('location', result.id.toString());
    print("Saving location id: " + result.id.toString());

    return Post.fromXml(response.body);
  } else {
    throw Exception('Misslyckades med att hämta data.');
  }
}