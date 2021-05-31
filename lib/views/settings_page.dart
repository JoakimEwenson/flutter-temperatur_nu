import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/views/components/aboutapp_widget.dart';
import 'package:temperatur_nu/views/components/settings_widget.dart';
import 'package:temperatur_nu/views/drawer.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //title: Text('Om appen'),
      ),
      drawer: AppDrawer(),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            FutureBuilder(
              future: _packageInfo,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  PackageInfo packInfo = snapshot.data;
                  return AboutAppCard(
                    packageInfo: packInfo,
                  );
                }

                return Container();
              },
            ),
            SettingsCard(),
            SizedBox(
              height: 48,
            ),
          ],
        ),
      ),
    );
  }
}
