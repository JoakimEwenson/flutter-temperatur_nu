import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:temperatur_nu/controller/common.dart';

Future<String> apiCaller(Map<String, dynamic> urlParams) async {
  Uri url = new Uri.https(apiUrl, apiVersion, urlParams);
  print("Fetching from $url");

  // Prepare empty content string
  String content;
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      content = response.body;
    } else {
      inspect(response.statusCode);
      throw Exception("HTTP Status: ${response.statusCode}");
    }
  } catch (e) {
    inspect(e);
  }
  return content;
}
