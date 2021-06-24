import 'package:geolocator/geolocator.dart';

class UserSettings {
  UserSettings(this.locationServiceEnabled, this.permission, this.userHome,
      this.nearbyStationDetails, this.nearbyStationsPage, this.graphRange);

  bool locationServiceEnabled = false;
  LocationPermission permission;
  String userHome;
  double nearbyStationDetails;
  double nearbyStationsPage;
  String graphRange;
}
