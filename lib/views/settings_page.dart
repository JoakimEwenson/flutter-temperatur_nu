import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/views/components/aboutapp_widget.dart';
import 'package:temperatur_nu/views/components/applicenses_widget.dart';
import 'package:temperatur_nu/views/components/navbar_widget.dart';
import 'package:temperatur_nu/views/components/settings_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

// Futures for later
Future<PackageInfo> _packageInfo;
void getPackageInfo() {
  _packageInfo = PackageInfo.fromPlatform();
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    getPackageInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(page: Pages.settings),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  AboutAppCard(
                    isDarkMode: _isDarkMode,
                  ),
                  SettingsCard(
                    isDarkMode: _isDarkMode,
                  ),
                  AppLicenseWidget(),
                  FutureBuilder(
                    future: _packageInfo,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        PackageInfo packageInfo = snapshot.data;
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Appversion ${packageInfo.version} (build ${packageInfo.buildNumber})',
                            style: bodySmallText,
                          ),
                        );
                      }

                      return Container();
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
