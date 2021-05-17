import 'dart:async';

import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/userSettings.dart';
import 'package:temperatur_nu/model/UserSettings.dart';

FutureOr<bool> deleteUserHomeConfirmationAlert(
    BuildContext context, UserSettings _settings) async {
  bool _output = false;
  AlertDialog alert = AlertDialog(
    content: Text(
        'Vill du verkligen ta bort \"${_settings.userHome}\" som hemstation?'),
    actions: [
      TextButton(
        onPressed: () async {
          Navigator.of(context).pop(true);
        },
        child: Text('TA BORT'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop(false);
        },
        child: Text('AVBRYT'),
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
