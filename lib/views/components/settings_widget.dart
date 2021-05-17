import 'dart:developer';

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
    double _minNearbyAmount = 5.0;
    double _maxNearbyAmount = 25.0;

    return FutureBuilder(
      future: userSettings,
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          UserSettings _userSettings = snapshot.data;
          print('Home: ${_userSettings.userHome}');
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
                ListTile(
                  title: Text(
                    'Platstjänster aktiverade?',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  trailing: IconButton(
                    icon: _userSettings.locationServiceEnabled
                        ? Icon(
                            Icons.check,
                            color: Colors.green,
                          )
                        : Icon(
                            Icons.report,
                            color: Colors.red,
                          ),
                    onPressed: () async {
                      await Geolocator.openLocationSettings();
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
                    'Kompletterande mätpunkter',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  subtitle: Text(
                    'Bestämmer antalet närliggande mätpunkter som ska hämtas till varje station, mellan 5 och 25.',
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
                ListTile(
                  isThreeLine: true,
                  title: Text(
                    'Närliggande mätpunkter',
                    style: Theme.of(context).textTheme.subtitle2,
                  ),
                  subtitle: Text(
                    'Bestämmer antalet närliggande mätpunkter som ska hämtas till listan, mellan 5 och 25.',
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
