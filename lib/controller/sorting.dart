// Saving sorting order
import 'package:shared_preferences/shared_preferences.dart';

saveSortingOrder(String choice) async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  sp.setString('sortingOrder', choice);
}

// Fetching sorting order
Future<String> fetchSortingOrder() async {
  SharedPreferences sp = await SharedPreferences.getInstance();
  return sp.getString('sortingOrder');
}
