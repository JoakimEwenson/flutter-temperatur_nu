import 'package:http/http.dart' as http;

// Make global base URL for API
String baseUrl = "api.temperatur.nu";
String apiVersion = "/tnu_1.17.php";
String apiCli = "ewenson";
String apiToken = "75bc346ecd42428015caa1cdf40150ea";

Future<String> apiCaller(Map<String, dynamic> urlParams) async {
  Map<String, dynamic> authParams = {
    "cli": apiCli,
    "token": apiToken,
  };
  urlParams.addAll(authParams);
  Uri url = new Uri.https(baseUrl, apiVersion, urlParams);
  //print("Fetching from $url");

  // Prepare empty content string
  String content;
  final response = await http.get(url).timeout(const Duration(seconds: 15));
  //print('Api called at ${DateTime.now().toIso8601String()}');

  if (response.statusCode == 200) {
    content = response.body;
  } else {
    //print("HTTP Status: ${response.statusCode}");
    throw Exception("HTTP Status: ${response.statusCode}");
  }
  return content;
}
