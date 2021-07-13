import 'dart:async';
import 'package:flutter/material.dart';
import 'package:temperatur_nu/model/UserSettings.dart';
import 'package:temperatur_nu/views/components/theme.dart';

FutureOr<bool> deleteUserHomeConfirmationAlert(
    BuildContext context, UserSettings _settings) async {
  bool _output = false;
  AlertDialog alert = AlertDialog(
    content: Text(
      'Vill du verkligen ta bort \"${_settings.userHome}\" som hemstation?',
      style: bodyText,
    ),
    actions: [
      TextButton(
        onPressed: () async {
          Navigator.of(context).pop(true);
        },
        child: Text(
          'TA BORT',
          style: bodyText,
        ),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: Text(
          'AVBRYT',
          style: bodyText,
        ),
      ),
    ],
  );

  await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return alert;
        });
      }).then((result) => _output = result);

  return _output;
}
