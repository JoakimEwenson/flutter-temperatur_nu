class UserSettings {
  UserSettings(this.locationServiceEnabled, this.userHome,
      this.nearbyStationDetails, this.nearbyStationsPage);

  bool locationServiceEnabled = false;
  String userHome;
  double nearbyStationDetails;
  double nearbyStationsPage;
}
