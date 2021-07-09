import 'package:flutter/material.dart';

Color getColorTemperature(double temperature, bool isDarkMode) {
  // Check temperature and set color accordingly, return default if outside
  // if (temperature < -24) return Color.fromRGBO(21, 57, 150, 1);
  // if (temperature < -18) return Color.fromRGBO(42, 113, 205, 1);
  // if (temperature < 12) return Color.fromRGBO(63, 169, 245, 1);
  // if (temperature < -6) return Color.fromRGBO(127, 198, 248, 1);
  // if (temperature < 0) return Color.fromRGBO(58, 58, 58, 1);
  // if (temperature > 24) return Color.fromRGBO(171, 2, 2, 1);
  // if (temperature > 18) return Color.fromRGBO(232, 3, 3, 1);
  // if (temperature > 12) return Color.fromRGBO(244, 64, 64, 1);
  // if (temperature > 6) return Color.fromRGBO(247, 129, 129, 1);
  // if (temperature >= 0)
  //   return Color.fromRGBO(249, 192, 192, 1);

  return isDarkMode ? Colors.white : Colors.black;
}
