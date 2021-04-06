import 'dart:developer';
import 'package:temperatur_nu/model/StationNameVerbose.dart';

/// This function takes in JSON string, translates it into JSON and does
/// some magic to end up with a list of StationName objects

Future<StationNameVerbose> responseTranslator(String input) async {
  // Intizialize empty output list and fill it with StationName objects
  try {
    StationNameVerbose output = stationNameVerboseFromJson(input);
    return output;
  } catch (e) {
    inspect(e);
  }
  return null;
}
