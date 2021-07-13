import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/views/components/deleteUserHome_dialog.dart';
import 'package:temperatur_nu/model/UserSettings.dart';
import 'package:temperatur_nu/views/components/theme.dart';

// Set up SharedPreferences for accessing local storage

// Back to the futures
Future<UserSettings> userSettings;

class SettingsCard extends StatefulWidget {
  const SettingsCard({Key key, @required this.isDarkMode}) : super(key: key);

  final bool isDarkMode;

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
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: widget.isDarkMode
                  ? tempCardDarkBackground
                  : tempCardLightBackground,
              borderRadius: BorderRadius.circular(cardBorderRadius),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Inställningar',
                    style: cardTitle,
                  ),
                ),
                if (_userSettings.locationServiceEnabled)
                  ListTile(
                    title: Text(
                      'Platstjänster aktiverade',
                      style: bodyText.copyWith(fontWeight: FontWeight.bold),
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
                      style: bodyText.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Klicka på ikonen för att aktivera platstjänster.',
                      style: bodyText,
                    ),
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
                if (_userSettings.permission != LocationPermission.whileInUse &&
                    _userSettings.permission != LocationPermission.always)
                  ListTile(
                    isThreeLine: true,
                    title: Text(
                      'Behörighet saknas',
                      style: bodyText.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Appen saknar behörighet att använda platstjänster. Klicka på ikonen för att åtgärda.',
                      style: bodyText,
                    ),
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
                    style: bodyText.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${_userSettings.userHome != null ? _userSettings.userHome : "Ingen vald"}',
                    style: bodyText,
                  ),
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
                    'Närliggande mätstationer',
                    style: bodyText.copyWith(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Bestämmer antalet kompletterande mätstationer som ska hämtas till varje station, mellan ${_minNearbyAmount.toInt()} och ${_maxNearbyAmount.toInt()}.',
                    style: bodyText,
                  ),
                ),
                Slider(
                  activeColor: widget.isDarkMode
                      ? darkModeTextColor
                      : lightModeTextColor,
                  inactiveColor: widget.isDarkMode
                      ? darkModeTextColor
                      : lightModeTextColor,
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
                Center(
                  child: TextButton(
                    onPressed: () async {
                      bool _settingsSaved =
                          await saveUserSettings(_userSettings);
                      if (_settingsSaved) {
                        //print('Saved settings');
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                'Inställningar sparade.',
                                style: bodyText,
                              ),
                            ),
                          );
                      } else {
                        //print('Error saving user settings');
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                'Inställningar sparades ej!',
                                style: bodyText,
                              ),
                            ),
                          );
                      }
                      setState(() {
                        userSettings = fetchUserSettings();
                      });
                    },
                    child: Text(
                      'Spara inställningarna',
                      style: GoogleFonts.inter(
                        textStyle: TextStyle(
                          color: widget.isDarkMode
                              ? darkModeTextColor
                              : lightModeTextColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
