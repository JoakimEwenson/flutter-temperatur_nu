import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Coolors set https://coolors.co/0b090a-161a1d-660708-a4161a-ba181b-e5383b-b1a7a6-d3d3d3-f5f3f4-ffffff
Color richBlack = Color.fromRGBO(11, 9, 10, 1);
Color eerieBlack = Color.fromRGBO(22, 26, 29, 1);
Color bloodRed = Color.fromRGBO(102, 7, 8, 1);
Color rubyRed = Color.fromRGBO(164, 22, 26, 1);
Color carnelian = Color.fromRGBO(186, 24, 27, 1);
Color imperialRed = Color.fromRGBO(229, 56, 59, 1);
Color silverChalice = Color.fromRGBO(177, 167, 166, 1);
Color lightGray = Color.fromRGBO(211, 211, 211, 1);
Color cultured = Color.fromRGBO(245, 243, 244, 1);

// App theme
Color appCanvasColor = cultured;
Color darkIconColor = cultured;
Color lightIconColor = eerieBlack;

Color darkModeTextColor = Colors.grey[200];
Color lightModeTextColor = Colors.grey[800];

// Default string values
String noTempDataString = "--.-°";

// DateFormat styles
String shortDateFormat = "d/M -yy";
String shortTimeFormat = "HH:mm";

// Text styles
TextStyle temperatureHuge = GoogleFonts.robotoMono(
  textStyle: TextStyle(
    fontSize: 96,
    fontWeight: FontWeight.w800,
    shadows: <Shadow>[
      Shadow(
        offset: Offset(1.0, 1.0),
        blurRadius: 2.0,
        color: Color.fromARGB(255, 0, 0, 0),
      ),
    ],
  ),
);
TextStyle temperatureBig = GoogleFonts.roboto(
  textStyle: TextStyle(
    fontSize: 60,
    fontWeight: FontWeight.w300,
  ),
);

TextStyle stationTitleSmall = TextStyle(fontSize: 12);

TextStyle pageTitle = GoogleFonts.roboto(textStyle: TextStyle(fontSize: 24));
TextStyle cardTitle = TextStyle(fontSize: 16);
TextStyle stationOwner = TextStyle(fontSize: 12);

TextStyle bodyText = GoogleFonts.roboto(
  textStyle: TextStyle(
    fontSize: 12,
  ),
);

// Location List Tile
TextStyle locationListTileTitle = GoogleFonts.roboto(
  textStyle: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
  ),
);
TextStyle locationListTileSubtitle = GoogleFonts.roboto(
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
