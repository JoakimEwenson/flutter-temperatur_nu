import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/controller/fetchPosition.dart';
import 'package:temperatur_nu/model/post.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

Future<List> fetchNearbyLocations(bool getCache) async {
  final prefs = await SharedPreferences.getInstance();
  // Set up API URL
  String urlOptions =
      "&num=10&amm=true&verbose=true&cli=" + Utils.createCryptoRandomString();
  String url;

  // Create empty list for later
  List nearbyLocations;
  Position position;

  if (getCache) {
    if (prefs.containsKey('nearbyLocationListCache') &&
        prefs.getString('nearbyLocationListCache') != "") {
      var content =
          xml.XmlDocument.parse(prefs.getString('nearbyLocationListCache'));
      nearbyLocations = [];

      content.findAllElements("item").forEach((row) {
        var output = new Post(
          title: row.findElements("title").single.text.trim().toString(),
          id: row.findElements("id").single.text.trim().toString(),
          temperature:
              double.tryParse(row.findElements("temp").single.text.trim()),
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
    nearbyLocations = [];
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

      final response =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        // If server returns OK, parse XML result
        var content = xml.XmlDocument.parse(response.body);

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
            temperature: double.tryParse(currentTemp),
            distance: distance,
            amm: "min " +
                minTemp +
                "° ◦ medel " +
                averageTemp +
                "° ◦ max " +
                maxTemp +
                "°",
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
