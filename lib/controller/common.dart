import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xml/xml.dart' as xml;

import '../model/post.dart';
import '../model/locationlistitem.dart';

// Make global base URL for API
String baseUrl = "https://api.temperatur.nu/tnu_1.15.php";

// Constant for deciding amount of maximum favorites
const int maxFavorites = 9999;
// Constant for setting cache timeout
const int cacheTimeout = 60000;
const int cacheTimeoutLong = 300000;

// Create a random CLI string until further notice.
// This is to not be locked out from the API until a proper key can be put in place.
class Utils {
  static final Random _random = Random.secure();

  static String createCryptoRandomString([int length = 12]) {
    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

// Class for carrying locationId from one screen to another
class LocationArguments {
  final String locationId;

  LocationArguments(this.locationId);
}

class CustomError {
  final String message;

  CustomError(this.message);

  @override
  String toString() => message;

  // USAGE:
  // on SocketException {
  //   throw Failing('message');
  // }
}

class TooManyFavoritesException implements Exception {
  String errorMsg() {
    return 'För många favoriter sparade, max antal är $maxFavorites.';
  }
}

// Fetch saved favorites from local storage
Future<List> fetchLocalFavorites() async {
  var sp = await SharedPreferences.getInstance();
  var favorites = sp.getString('favorites') ?? "";
  var favList = [];
  if ((favorites != "") || (favorites != null)) {
    favList = favorites.split(',');
  }

  return favList;
}

// Save favorites to local storage
saveLocalFavorites(List favorites) async {
  String favoritesString = favorites.join(',');
  var sp = await SharedPreferences.getInstance();
  sp.setString('favorites', favoritesString);
}

// Add location id to local stored favorites
Future<bool> addToFavorites(String locationId) async {
  var favList = await fetchLocalFavorites();
  favList = await cleanupFavoritesList(favList);

  if (!(await existsInFavorites(locationId)) &&
      (favList.length < maxFavorites)) {
    favList.add(locationId);
    saveLocalFavorites(favList.toSet().toList());
    return true;
  } else {
    //throw Exception('För många favoriter sparade, max antal är enligt konstant maxFavorites.');
    throw TooManyFavoritesException();
    //return false;
  }
}

Future<bool> existsInFavorites(String locationId) async {
  var favList = await fetchLocalFavorites();
  favList = await cleanupFavoritesList(favList);

  return favList.contains(locationId);
}

// Remove location id from local saved favorites
Future<bool> removeFromFavorites(String locationId) async {
  var favList = await fetchLocalFavorites();
  favList = await cleanupFavoritesList(favList);

  if (favList.remove(locationId)) {
    saveLocalFavorites(favList);
    return true;
  } else {
    throw Exception(
        'Kunde inte ta bort $locationId från listan över favoriter.');
    //return false;
  }
}

// Clear empty list result
cleanupFavoritesList(List favorites) async {
  favorites.removeWhere((item) => item == "" || item == null);
  return favorites;
}

// Setting and getting timestamps
setTimeStamp(String title) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setString(title, DateTime.now().millisecondsSinceEpoch.toString());
}

Future<String> getTimeStamp(String title) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  String timestamp = sp.getString(title);

  return timestamp;
}

num compareTimeStamp(num saved, num current) {
  return current - saved;
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

// Get location
Future<Position> fetchPosition() async {
  Position position = await Geolocator()
      .getCurrentPosition()
      .timeout(Duration(seconds: 15))
      .then((pos) {
    //getting position without problems
    return pos;
  }).catchError((e) {
    return null;
  });
  return position;
}

// Fetch cached single post data
Future<Post> fetchSinglePostCache() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('singlePostCache')) {
    var content = xml.parse(prefs.getString('singlePostCache'));
    return Post.fromXml(content);
  } else {
    return new Post();
  }
}

// Another fetch API function
Future<Post> fetchSinglePost(String location) async {
  // Set up API URL
  String urlOptions = "&amm=true&dc=true&verbose=true&num=1&cli=" +
      Utils.createCryptoRandomString();
  String url;

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
        url = baseUrl +
            "?lat=" +
            position.latitude.toString() +
            "&lon=" +
            position.longitude.toString() +
            urlOptions;
      } else {
        throw TimeoutException("Kunde inte hämta position");
      }
    } else if (location == 'default') {
      url = baseUrl + "?p=" + defaultLocation + urlOptions;
    } else {
      // Check if location id is stored in local storage or else, use default
      if (prefs.getString('location') != null) {
        locationId = prefs.getString('location');
      } else {
        locationId = defaultLocation;
      }
      url = baseUrl + "?p=" + locationId + urlOptions;
    }
    // Get data from API
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      // If server returns OK, parse XML result
      var content = xml.parse(response.body);
      // Save XML string as cache
      prefs.setString('singlePostCache', response.body);

      // var locationTitle = content.findAllElements("item").map((node) => node.findElements("title").single.text);
      var locationId = content
          .findAllElements("item")
          .map((node) => node.findElements("id").single.text);

      // Save location id to local storage for later
      prefs.setString('location', locationId.single.trim().toString());

      //return output;
      return Post.fromXml(content);
    } else {
      throw Exception('Misslyckades med att hämta data');
    }
  } on TimeoutException catch (e) {
    return new Post(
      title: "Begäran tog för lång tid",
      sourceInfo: e.toString(),
      lastUpdate: DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
    );
  } on SocketException catch (e) {
    return new Post(
      title: "Kunde inte att nå nätverket",
      sourceInfo: e.toString(),
      lastUpdate: DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
    );
  }
  // Handle empty or no result
  on StateError catch (e) {
    return new Post(
      title: "Tomt resultat",
      sourceInfo: e.toString(),
      lastUpdate: DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
    );
  } catch (e) {
    return new Post(
      title: "Något gick snett",
      sourceInfo: e.toString(),
      lastUpdate: DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
    );
  }
}

Future<List> fetchFavorites(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();
  // Save and fetch locally saved data
  List searchLocationList = await fetchLocalFavorites();
  String searchLocations = searchLocationList.join(',');
  String urlOptions =
      "&dc=true&verbose=true&cli=" + Utils.createCryptoRandomString();
  String url = baseUrl + "?p=" + searchLocations + urlOptions;
  List favoritesList = new List();

  if (getCache) {
    if (prefs.containsKey('favoritesListCache') &&
        prefs.getString('favoritesListCache') != "") {
      // Fetch cached data
      var content = xml.parse(prefs.getString('favoritesListCache'));
      favoritesList = new List();

      // Iterate results and make into list
      content.findAllElements("item").forEach((row) {
        var output = new Post(
          title: row.findElements("title").single.text.trim().toString(),
          id: row.findElements("id").single.text.trim().toString(),
          temperature: row.findElements("temp").single.text.trim().toString(),
          amm: '',
          lastUpdate:
              row.findElements("lastUpdate").single.text.trim().toString(),
          municipality:
              row.findElements("kommun").single.text.trim().toString(),
          county: row.findElements("lan").single.text.trim().toString(),
          sourceInfo:
              row.findElements("sourceInfo").single.text.trim().toString(),
          sourceUrl: row.findElements("url").single.text.trim().toString(),
        );
        favoritesList.add(output);
      });

      return favoritesList;
    } else {
      return fetchFavorites(false);
    }
  } else {
    favoritesList = new List();
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var content = xml.parse(response.body);

        content.findAllElements("item").forEach((row) {
          var locationTitle =
              row.findElements('title').single.text.trim().toString();
          var locationId = row.findElements('id').single.text.trim().toString();
          var currentTemp =
              row.findElements('temp').single.text.trim().toString();
          var amm = "";
          var lastUpdate =
              row.findElements('lastUpdate').single.text.trim().toString();
          var municipality =
              row.findElements('kommun').single.text.trim().toString();
          var county = row.findElements('lan').single.text.trim().toString();
          var sourceInfo =
              row.findElements('sourceInfo').single.text.trim().toString();
          var sourceUrl = row.findElements('url').single.text.trim().toString();

          var output = new Post(
              title: locationTitle,
              id: locationId,
              temperature: currentTemp,
              amm: amm,
              lastUpdate: lastUpdate,
              municipality: municipality,
              county: county,
              sourceInfo: sourceInfo,
              sourceUrl: sourceUrl);
          favoritesList.add(output);
        });

        return favoritesList;
      } else {
        throw Exception('Misslyckades med att hämta data.');
      }
    } on TimeoutException catch (e) {
      var output = new Post(
        title: "Hämtning av data tog för lång tid",
        sourceInfo: e.toString(),
        lastUpdate:
            DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
      );
      favoritesList.add(output);

      return favoritesList;
    } on SocketException catch (e) {
      var output = new Post(
        title: "Kunde inte att nå nätverket",
        sourceInfo: e.toString(),
        lastUpdate:
            DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
      );
      favoritesList.add(output);

      return favoritesList;
    } catch (e) {
      print(e);
      var output = new Post(
        title: "Något gick snett",
        sourceInfo: e.toString(),
        lastUpdate:
            DateFormat("yyyy-MM-dd HH:mm:ss").format(new DateTime.now()),
      );

      favoritesList.add(output);

      return favoritesList;
    }
  }
}

Future<List> fetchNearbyLocations(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();
  // Set up API URL
  String urlOptions = "&num=10&amm=true&dc=true&verbose=true&cli=" +
      Utils.createCryptoRandomString();
  String url;

  // Create empty list for later
  List nearbyLocations;
  Position position;

  if (getCache) {
    if (prefs.containsKey('nearbyLocationListCache') &&
        prefs.getString('nearbyLocationListCache') != "") {
      var content = xml.parse(prefs.getString('nearbyLocationListCache'));
      nearbyLocations = new List();

      content.findAllElements("item").forEach((row) {
        var output = new Post(
          title: row.findElements("title").single.text.trim().toString(),
          id: row.findElements("id").single.text.trim().toString(),
          temperature: row.findElements("temp").single.text.trim().toString(),
          distance: row.findElements("dist").single.text.trim().toString(),
          lastUpdate:
              row.findElements("lastUpdate").single.text.trim().toString(),
          municipality:
              row.findElements("kommun").single.text.trim().toString(),
          county: row.findElements("lan").single.text.trim().toString(),
          sourceInfo:
              row.findElements("sourceInfo").single.text.trim().toString(),
          sourceUrl: row.findElements("url").single.text.trim().toString(),
        );

        nearbyLocations.add(output);
      });

      return nearbyLocations;
    } else {
      return fetchNearbyLocations(false);
    }
  } else {
    nearbyLocations = new List();
    try {
      position = await fetchPosition();
    } catch (e) {
      position = null;
    }

    if (position != null) {
      url = baseUrl +
          "?lat=" +
          position.latitude.toString() +
          "&lon=" +
          position.longitude.toString() +
          urlOptions;

      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // If server returns OK, parse XML result
        var content = xml.parse(response.body);

        content.findAllElements("item").forEach((row) {
          var locationTitle =
              row.findElements("title").single.text.trim().toString();
          var locationId = row.findElements("id").single.text.trim().toString();
          var currentTemp =
              row.findElements("temp").single.text.trim().toString();
          var distance = row.findElements("dist").single.text.trim().toString();
          var lastUpdated =
              row.findElements("lastUpdate").single.text.trim().toString();
          var municipality =
              row.findElements("kommun").single.text.trim().toString();
          var county = row.findElements("lan").single.text.trim().toString();
          var sourceInfo =
              row.findElements("sourceInfo").single.text.trim().toString();
          var sourceUrl = row.findElements("url").single.text.trim().toString();
          // Average, min, max data
          var averageTemp =
              row.findElements("average").single.text.trim().toString();
          var minTemp = row.findElements("min").single.text.trim().toString();
          var maxTemp = row.findElements("max").single.text.trim().toString();

          var output = new Post(
            title: locationTitle,
            id: locationId,
            temperature: currentTemp,
            distance: distance,
            amm: "min " +
                minTemp +
                "°C ◦ medel " +
                averageTemp +
                "°C ◦ max " +
                maxTemp +
                "°C",
            lastUpdate: lastUpdated,
            municipality: municipality,
            county: county,
            sourceInfo: sourceInfo,
            sourceUrl: sourceUrl,
          );
          nearbyLocations.add(output);
        });

        return nearbyLocations;
      }
    } else if (position == null) {
      nearbyLocations.add(new Post(title: "Kunde inte hämta din position"));
      return nearbyLocations;
    } else {
      //throw Exception('Misslyckades med att hämta position');
      nearbyLocations.add(new Post(
        title: "Något gick snett",
      ));
      return nearbyLocations;
    }

    return nearbyLocations;
  }
}

Future<List<LocationListItem>> fetchLocationList(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();
  List<LocationListItem> locationList = [];

  if (getCache) {
    if (prefs.containsKey('locationListCache') &&
        prefs.getString('locationListCache') != "") {
      locationList = [];
      // Fetch locally saved cache and turn into XML
      var content = xml.parse(prefs.getString('locationListCache'));

      // Iterate results and make into list
      content.findAllElements('item').forEach((row) {
        var output = new LocationListItem(
          title: row.findElements('title').single.text.trim().toString(),
          id: row.findElements('id').single.text.trim().toString(),
          temperature: row.findElements('temp').single.text.trim().toString(),
        );
        locationList.add(output);
      });

      return locationList;
    } else {
      return fetchLocationList(false);
    }
  } else {
    // Set up API URL
    String urlOptions = "?cli=" + Utils.createCryptoRandomString();
    String url = baseUrl + urlOptions;
    print(url);

    // Collect data from API
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // If server responds with OK, parse XML result
        // Save XML string as cache
        prefs.setString('locationListCache', response.body);
        var content = xml.parse(response.body);
        locationList = [];

        // Iterate results and make into list
        content.findAllElements('item').forEach((row) {
          var output = new LocationListItem(
            title: row.findElements('title').single.text.trim().toString(),
            id: row.findElements('id').single.text.trim().toString(),
            temperature: row.findElements('temp').single.text.trim().toString(),
          );
          locationList.add(output);
        });

        return locationList;
      } else {
        throw Exception('Misslyckades med att hämta data.');
      }
    } on TimeoutException {
      var output = new LocationListItem(
        title: "Hämtning av data tog för lång tid",
      );
      locationList.add(output);

      return locationList;
    } on SocketException {
      var output = new LocationListItem(
        title: "Kunde inte att nå nätverket",
      );
      locationList.add(output);

      return locationList;
    } catch (e) {
      var output = new LocationListItem(
        title: "Något gick snett",
      );
      locationList.add(output);

      return locationList;
    }
  }
}
