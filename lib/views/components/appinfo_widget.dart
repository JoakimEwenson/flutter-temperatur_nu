import 'package:flutter/material.dart';
import 'package:temperatur_nu/views/components/theme.dart';

Widget appInfo() {
  return Padding(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'En app av Joakim Ewenson',
          style: bodySmallText,
        ),
        SizedBox(
          height: 4,
        ),
        Text(
          'https://www.ewenson.se',
          style: bodySmallText,
        ),
        SizedBox(
          height: 16,
        ),
      ],
    ),
  );
}
