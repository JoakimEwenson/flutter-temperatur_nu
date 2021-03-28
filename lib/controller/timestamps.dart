// Setting and getting timestamps
import 'package:shared_preferences/shared_preferences.dart';

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
