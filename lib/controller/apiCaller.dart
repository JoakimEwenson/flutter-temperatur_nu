import 'dart:developer';
import 'package:http/http.dart' as http;

// Make global base URL for API
String baseUrl = "api.temperatur.nu";
String apiVersion = "/tnu_1.17.php";

Future<String> apiCaller(Map<String, dynamic> urlParams) async {
  Uri url = new Uri.https(baseUrl, apiVersion, urlParams);
  //print("Fetching from $url");

  // Prepare empty content string
  String content;
  final response = await http.get(url).timeout(const Duration(seconds: 15));

  if (response.statusCode == 200) {
    content = response.body;
  } else {
    inspect(response.statusCode);
    throw Exception("HTTP Status: ${response.statusCode}");
  }
  return content;
}
