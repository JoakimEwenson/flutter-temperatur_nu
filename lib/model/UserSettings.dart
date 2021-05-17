import 'package:geolocator/geolocator.dart';

class UserSettings {
  UserSettings(this.locationServiceEnabled, this.permission, this.userHome,
      this.nearbyStationDetails, this.nearbyStationsPage);

  bool locationServiceEnabled = false;
  LocationPermission permission;
  String userHome;
  double nearbyStationDetails;
  double nearbyStationsPage;
}
