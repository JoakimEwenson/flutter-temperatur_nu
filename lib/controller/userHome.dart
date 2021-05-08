import 'package:shared_preferences/shared_preferences.dart';

Future<String> fetchUserHome() async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  if (_sharedPreferences.containsKey('userHome')) {
    return _sharedPreferences.getString('userHome');
  }
  return 'default';
}

Future<bool> isUserHome(String _query) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  if (_sharedPreferences.containsKey('userHome')) {
    if (_sharedPreferences.getString('userHome') == _query) {
      return true;
    }
  }
  return false;
}

saveUserHome(String _home) async {
  SharedPreferences _sharedPreferences = await SharedPreferences.getInstance();
  _sharedPreferences.setString('userHome', _home);
}
