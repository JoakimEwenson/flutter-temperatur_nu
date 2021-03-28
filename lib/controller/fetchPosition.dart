// Get location
import 'package:geolocator/geolocator.dart';

Future<Position> fetchPosition() async {
  Position position = await Geolocator.getCurrentPosition()
      .timeout(Duration(seconds: 15))
      .then((pos) {
    //getting position without problems
    return pos;
  }).catchError((e) {
    return null;
  });
  return position;
}
