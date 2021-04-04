import 'dart:convert';
import 'dart:developer';

import 'package:temperatur_nu/model/StationName.dart';

/// This function takes in JSON string, translates it into JSON and does
/// some magic to end up with a list of StationName objects

Future<List<StationName>> responseTranslator(String input) async {
  // Intizialize empty output list and fill it with StationName objects
  List<StationName> output = [];
  try {
    // Translate input to json, iterate JSON response into list
    var json = await jsonDecode(input);
    List<dynamic> response = json["stations"].values.toList();

    response.forEach((row) {
      output.add(StationName.fromRawJson(row));
    });
  } catch (e) {
    inspect(e);
  }

  return output;
}
