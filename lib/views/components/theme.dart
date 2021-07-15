import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Temperatur.nu logotype colors
Color tnuBlue = Color.fromRGBO(37, 33, 105, 1);
Color tnuYellow = Color.fromRGBO(252, 194, 79, 1);

// Coolors set https://coolors.co/0b090a-161a1d-660708-a4161a-ba181b-e5383b-b1a7a6-d3d3d3-f5f3f4-ffffff
Color richBlack = Color.fromRGBO(11, 9, 10, 1);
Color eerieBlack = Color.fromRGBO(22, 26, 29, 1);
Color bloodRed = Color.fromRGBO(102, 7, 8, 1);
Color rubyRed = Color.fromRGBO(164, 22, 26, 1);
Color carnelian = Color.fromRGBO(186, 24, 27, 1);
Color imperialRed = Color.fromRGBO(229, 56, 59, 1);
Color silverChalice = Color.fromRGBO(177, 167, 166, 1);
Color lightGray = Color.fromRGBO(240, 240, 240, 1);
Color cultured = Color.fromRGBO(245, 243, 244, 1);

// App theme
Color appCanvasColor = lightGray;
Color darkIconColor = cultured;
Color lightIconColor = eerieBlack;

Color darkModeTextColor = Colors.grey[200];
Color lightModeTextColor = Colors.grey[800];

// Default string values
String noTempDataString = "--.-°";

// DateFormat styles
String longDateFormat = "yyyy-MM-dd";
String longDateTimeFormat = "yyyy-MM-dd 'kl.' HH:mm";
String longTimeFormat = "HH:mm:ss";
String shortDateFormat = "d/M -yy";
String shortDateTimeFormat = "'kl.' HH:mm 'den' d/M -yy";
String shortTimeFormat = "HH:mm";

// Design elements
double cardBorderRadius = 25;

// Text styles
TextStyle temperatureHuge = GoogleFonts.robotoMono(
  textStyle: TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w400,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 2.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ],
  ),
);
TextStyle temperatureBig = GoogleFonts.robotoMono(
  textStyle: TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w300,
  ),
);

TextStyle stationTitleSmall = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 12),
);

TextStyle pageTitle = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 24),
);
TextStyle cardTitle = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
);
TextStyle cardInnerTitle = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 16),
);
TextStyle stationOwner = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 12),
);

TextStyle bodyText = GoogleFonts.inter(textStyle: TextStyle(fontSize: 14));
TextStyle bodySmallText = GoogleFonts.inter(
  textStyle: TextStyle(fontSize: 11),
);

TextStyle dropdownMenuItem = bodyText.copyWith(fontWeight: FontWeight.bold);

TextStyle licenseText = GoogleFonts.robotoMono(
  textStyle: TextStyle(fontSize: 11),
);

// Temperature Card styles
Color tempCardLightBackground = Colors.white;
Color tempCardDarkBackground = Color.fromRGBO(26, 26, 26, 1.0);

TextStyle tempCardTitle = GoogleFonts.inter(
  textStyle: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
  ),
);
TextStyle tempCardSubtitle = GoogleFonts.inter(
  textStyle: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  ),
);
TextStyle tempCardTemperature = GoogleFonts.robotoMono(
  textStyle: TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w800,
  ),
);

// Average, Max, Min table
TextStyle ammHeader = GoogleFonts.robotoMono(
  fontSize: 12,
  fontWeight: FontWeight.bold,
);
TextStyle ammValue = GoogleFonts.robotoMono(
  fontSize: 12,
  fontWeight: FontWeight.bold,
);
TextStyle ammTime = GoogleFonts.robotoMono(
  fontSize: 11,
);

// Location List Tile
TextStyle locationListTileTitle = GoogleFonts.inter(
  textStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  ),
);
TextStyle locationListTileSubtitle = GoogleFonts.inter(
  textStyle: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
  ),
);
TextStyle locationListTileTemperature = GoogleFonts.robotoMono(
  textStyle: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
  ),
);
