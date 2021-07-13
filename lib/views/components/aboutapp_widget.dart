import 'package:flutter/material.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class AboutAppCard extends StatelessWidget {
  const AboutAppCard({
    Key key,
    this.isDarkMode,
  }) : super(key: key);

  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDarkMode ? tempCardDarkBackground : tempCardLightBackground,
        borderRadius: BorderRadius.circular(cardBorderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(cardBorderRadius),
                child: Image.asset(
                  'icon/icon.png',
                  height: 96,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Om appen',
              style: cardTitle,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detta är en enkel tredjepartsapplikation för att hämta temperaturdata från webbtjänsten temperatur.nu och deras databas över mätstationer runt om i landet. ',
                  style: bodyText,
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  'Appen är skapad av Joakim Ewenson och använder namnet med tillåtelse från temperatur.nu skapare.',
                  style: bodyText,
                ),
                SizedBox(
                  height: 16,
                ),
                Center(
                  child: Text(
                    'https://www.ewenson.se',
                    style: bodySmallText,
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
