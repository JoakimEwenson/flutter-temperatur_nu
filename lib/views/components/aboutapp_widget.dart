import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AboutAppCard extends StatelessWidget {
  const AboutAppCard({
    Key key,
    @required this.packageInfo,
  }) : super(key: key);

  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Image.asset(
              'icon/temperatur_nu.png',
              height: 72,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: Text(
                'Appversion ${packageInfo.version} (build ${packageInfo.buildNumber})',
                style: Theme.of(context).textTheme.caption,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Om appen',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detta är en enkel tredjepartsapplikation för att hämta temperaturdata från webbtjänsten temperatur.nu och deras databas över mätpunkter runt om i landet. ',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Appen är skapad av Joakim Ewenson och använder namnet med tillåtelse från temperatur.nu skapare.',
                  style: Theme.of(context).textTheme.bodyText2,
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    'https://www.ewenson.se',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
