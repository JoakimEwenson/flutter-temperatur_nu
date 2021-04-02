import 'dart:async';
import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/model/StationName.dart';
import 'package:temperatur_nu/model/locationlistitem.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<List<StationName>> newFetchLocationList(bool getCache) async {}

Future<List<LocationListItem>> fetchLocationList(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();
  List<LocationListItem> locationList = [];

  if (getCache) {
    if (prefs.containsKey('locationListCache') &&
        prefs.getString('locationListCache') != "") {
      locationList = [];
      // Fetch locally saved cache and turn into XML
      var content = xml.XmlDocument.parse(prefs.getString('locationListCache'));

      // Iterate results and make into list
      content.findAllElements('item').forEach((row) {
        var output = new LocationListItem(
          title: row.findElements('title').single.text.trim().toString(),
          id: row.findElements('id').single.text.trim().toString(),
          temperature:
              double.tryParse(row.findElements('temp').single.text.trim()),
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
    //print(url);

    // Collect data from API
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // If server responds with OK, parse XML result
        // Save XML string as cache
        prefs.setString('locationListCache', response.body);
        var content = xml.XmlDocument.parse(response.body);
        locationList = [];

        // Iterate results and make into list
        content.findAllElements('item').forEach((row) {
          var output = new LocationListItem(
            title: row.findElements('title').single.text.trim().toString(),
            id: row.findElements('id').single.text.trim().toString(),
            temperature:
                double.tryParse(row.findElements('temp').single.text.trim()),
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
