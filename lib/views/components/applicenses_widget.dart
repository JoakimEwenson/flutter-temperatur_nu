import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/views/components/theme.dart';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

// Futures for later
Future<PackageInfo> _applicationInfo;
void getApplicationInfo() {
  _applicationInfo = PackageInfo.fromPlatform();
}

class AppLicenseWidget extends StatefulWidget {
  const AppLicenseWidget({
    Key key,
  }) : super(key: key);

  @override
  _AppLicenseWidgetState createState() => _AppLicenseWidgetState();
}

class _AppLicenseWidgetState extends State<AppLicenseWidget> {
  @override
  void initState() {
    super.initState();
    getApplicationInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return FutureBuilder(
      future: _applicationInfo,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          PackageInfo packageInfo = snapshot.data;
          return Container(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () {
                showLicensePage(
                  context: context,
                  applicationVersion:
                      'Version ${packageInfo.version} (build ${packageInfo.buildNumber})',
                  applicationIcon: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(cardBorderRadius),
                      child: Image.asset(
                        'icon/icon.png',
                        width: 128,
                      ),
                    ),
                  ),
                  useRootNavigator: true,
                );
              },
              icon: Icon(
                Icons.article_outlined,
                color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
              ),
              label: Text(
                'Visa applicenser',
                style: bodyText.copyWith(
                  color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
