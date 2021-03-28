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

// Fetch cached single post data
Future<String> fetchSinglePostCache() async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('singlePostCache')) {
    return prefs.getString('singlePostCache');
  } else {
    return "";
  }
}

Future<StationName> fetchStation(locationId) async {
  String data = await fetchSinglePost(locationId);
  //String data = '{"title":"Temperatur.nu API 1.16 -  Din url är inte korrekt signerad, clientnyckeln kan tillfälligt blockeras /tnu_1.16.php","clientkey":"unsigned","stations":{"Karlstad":{"title":"Karlstad","id":"karlstad","temp":"N/A","lat":"59.40701","lon":"13.59238","lastUpdate":"2020-09-15 07:57:21","kommun":"Karlstad","lan":"Värmlands län","sourceInfo":"Temperaturdata från Magnus väderstation i Karlstad.","forutsattning":"Temperaturen mäts med hjälp av väderstationen LaCrosse WS-2300. Sensorn sitter på husets nordvästsida.","uptime":"46","start":"2005-08-17 21:26:29","moh":"81.3342","url":"https://www.temperatur.nu/karlstad.html","ammRange":"2021-03-27 06:09 - 2021-03-28 07:09","average":"","min":"","minTime":"---------- --:--","max":"","maxTime":"---------- --:--"},"Karlstad/Orrholmen":{"title":"Karlstad/Orrholmen","id":"orrholmen","temp":"4.9","lat":"59.372421","lon":"13.498473","lastUpdate":"2021-03-28 19:07:13","kommun":"Karlstad","lan":"Värmlands län","sourceInfo":"Temperaturdata från Joakim Ewenson.","forutsattning":"Mätning primärt på norrsida av hyreshus med kompletterande data från södra sidan för att säkra merparten av dygnet.","uptime":"99.5","start":"2020-02-05 12:01:07","moh":"50.1523","url":"https://www.temperatur.nu/orrholmen.html","ammRange":"2021-03-27 06:09 - 2021-03-28 07:09","average":"3.7","min":"-1.1","minTime":"2021-03-28 07:12","max":"9.1","maxTime":"2021-03-28 15:08"},"Karlstad/Romstad":{"title":"Karlstad/Romstad","id":"romstad","temp":"5.4","lat":"59.378191","lon":"13.474149","lastUpdate":"2021-03-28 19:09:24","kommun":"Karlstad","lan":"Värmlands län","sourceInfo":"Temperaturdata från Lars Hultqvist.","forutsattning":"Norrsida i skugga, ca 3 meter från huset. Mäts med Fibaro universal sensor","uptime":"99.5","start":"2018-10-16 17:42:26","moh":"52.1151","url":"https://www.temperatur.nu/romstad.html","ammRange":"2021-03-27 06:09 - 2021-03-28 07:09","average":"4.3","min":"0.1","minTime":"2021-03-28 06:40","max":"10.4","maxTime":"2021-03-28 13:48"}}}';
  var json = await jsonDecode(data);
  var stationList = json["stations"].values.toList();

  return StationName.fromRawJson(stationList[0]);
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
