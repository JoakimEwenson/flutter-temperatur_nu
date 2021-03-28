import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/controller/favorites.dart';
import 'package:temperatur_nu/model/post.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<List> fetchFavorites(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();
  // Save and fetch locally saved data
  List searchLocationList = await fetchLocalFavorites();
  String searchLocations = searchLocationList.join(',');
  String urlOptions = "&verbose=true&cli=" + Utils.createCryptoRandomString();
  String url = baseUrl + "?p=" + searchLocations + urlOptions;
  List favoritesList = [];

  if (getCache) {
    if (prefs.containsKey('favoritesListCache') &&
        prefs.getString('favoritesListCache') != "") {
      // Fetch cached data
      var content =
          xml.XmlDocument.parse(prefs.getString('favoritesListCache'));
      favoritesList = [];

      // Iterate results and make into list
      content.findAllElements("item").forEach((row) {
        var output = new Post(
          title: row.findElements("title").single.text.trim().toString(),
          id: row.findElements("id").single.text.trim().toString(),
          temperature:
              double.tryParse(row.findElements("temp").single.text.trim()),
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
    favoritesList = [];
    try {
      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        var content = xml.XmlDocument.parse(response.body);

        content.findAllElements("item").forEach((row) {
          var locationTitle =
              row.findElements('title').single.text.trim().toString();
          var locationId = row.findElements('id').single.text.trim().toString();
          var currentTemp =
              double.tryParse(row.findElements('temp').single.text.trim());
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
