import 'package:flutter/material.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class AppLicenseWidget extends StatelessWidget {
  const AppLicenseWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          showLicensePage(context: context);
        },
        icon: Icon(
          Icons.read_more,
          color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
        ),
        label: Text(
          'Visa applicenser',
          style: TextStyle(
            color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
          ),
        ),
      ),
    );
  }
}
