import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/views/components/theme.dart';

// Set up SharedPreferences for loading saved data
SharedPreferences sp;

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
  }

  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          Navigator.pushNamed(context, '/LicensesListPage');
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
}
