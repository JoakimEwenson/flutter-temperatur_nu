import 'package:flutter/material.dart';

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
