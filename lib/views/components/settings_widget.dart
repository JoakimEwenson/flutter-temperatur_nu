import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/views/components/deleteUserHome_dialog.dart';
import 'package:temperatur_nu/model/UserSettings.dart';

// Set up SharedPreferences for accessing local storage

// Back to the futures
Future<UserSettings> userSettings;

class SettingsCard extends StatefulWidget {
  const SettingsCard({Key key}) : super(key: key);

  @override
  _SettingsCardState createState() => _SettingsCardState();
}

class _SettingsCardState extends State<SettingsCard> {
  @override
  void initState() {
    super.initState();
    userSettings = fetchUserSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Preset min/max nearby stations
    double _minNearbyAmount = 3.0;
    double _maxNearbyAmount = 25.0;

    return FutureBuilder(
      future: userSettings,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          UserSettings _userSettings = snapshot.data;
          return Card(
            elevation: 0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Inställningar',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                if (_userSettings.locationServiceEnabled)
                  ListTile(
                    title: Text(
                      'Platstjänster aktiverade',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Colors.green,
                      ),
                      onPressed: () async {
                        await Geolocator.openAppSettings();
                      },
                    ),
                  ),
                if (!_userSettings.locationServiceEnabled)
                  ListTile(
                    title: Text(
                      'Platstjänster avaktiverade',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    subtitle: Text(
                        'Klicka på ikonen för att aktivera platstjänster.'),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.report,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await Geolocator.openLocationSettings();
                      },
                    ),
                  ),
                if (_userSettings.permission != LocationPermission.whileInUse)
                  ListTile(
                    isThreeLine: true,
                    title: Text(
                      'Behörighet saknas',
                      style: Theme.of(context).textTheme.subtitle2,
                    ),
                    subtitle: Text(
                        'Appen saknar behörighet att använda platstjänster. Klicka på ikonen för att åtgärda.'),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.app_settings_alt,
                        color: Colors.red,
                      ),
                      onPressed: () async {
                        await Geolocator.openAppSettings();
                      },
                    ),
                  ),
                ListTile(
                  title: Text(
                    'Nuvarande hemstation',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  subtitle: Text(
                      '${_userSettings.userHome != null ? _userSettings.userHome : "Ingen vald"}'),
                  trailing: _userSettings.userHome != null
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            bool result = await deleteUserHomeConfirmationAlert(
                                context, _userSettings);
                            if (result) {
                              setState(() {
                                _userSettings.userHome = null;
                                saveUserSettings(_userSettings);
                              });
                            }
                          },
                        )
                      : IconButton(icon: Icon(Icons.clear), onPressed: null),
                ),
                ListTile(
                  isThreeLine: true,
                  title: Text(
                    'Närliggande mätpunkter',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  subtitle: Text(
                    'Bestämmer antalet kompletterande mätpunkter som ska hämtas till varje station, mellan ${_minNearbyAmount.toInt()} och ${_maxNearbyAmount.toInt()}.',
                  ),
                ),
                Slider(
                  min: _minNearbyAmount,
                  max: _maxNearbyAmount,
                  divisions: _maxNearbyAmount.toInt(),
                  value: _userSettings.nearbyStationDetails,
                  label: _userSettings.nearbyStationDetails.toInt().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _userSettings.nearbyStationDetails =
                          value.roundToDouble();
                    });
                  },
                ),
                /*
                ListTile(
                  isThreeLine: true,
                  title: Text(
                    'Närliggande mätpunkter',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  subtitle: Text(
                    'Bestämmer antalet närliggande mätpunkter som ska hämtas, mellan ${_minNearbyAmount.toInt()} och ${_maxNearbyAmount.toInt()}.',
                  ),
                ),
                Slider(
                  min: _minNearbyAmount,
                  max: _maxNearbyAmount,
                  divisions: _maxNearbyAmount.toInt(),
                  value: _userSettings.nearbyStationsPage,
                  label: _userSettings.nearbyStationsPage.toInt().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _userSettings.nearbyStationsPage = value.roundToDouble();
                    });
                  },
                ),
                */
                Center(
                  child: TextButton(
                      onPressed: () async {
                        bool _settingsSaved =
                            await saveUserSettings(_userSettings);
                        if (_settingsSaved) {
                          print('Saved settings');
                        } else {
                          print('Error saving user settings');
                        }
                        setState(() {
                          userSettings = fetchUserSettings();
                        });
                      },
                      child: Text('Spara inställningarna')),
                )
              ],
            ),
          );
        }
        return Container();
      },
    );
  }
}
