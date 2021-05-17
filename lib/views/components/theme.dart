// Color palette
import 'package:flutter/material.dart';

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

Widget appInfo() {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'En app av Joakim Ewenson',
          style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic),
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          'https://www.ewenson.se',
          style: TextStyle(fontSize: 8, fontStyle: FontStyle.italic),
        ),
        SizedBox(
          height: 16,
        ),
      ],
    ),
  );
}
