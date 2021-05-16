import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/userHome.dart';

void deleteUserHomeConfirmationAlert(
    BuildContext context, String location) async {
  AlertDialog alert = AlertDialog(
    content: Text('Vill du verkligen ta bort \"$location\" som hemstation?'),
    actions: [
      TextButton(
        onPressed: () async {
          await removeUserHome();
          Navigator.of(context).pop(true);
        },
        child: Text('TA BORT'),
      ),
      TextButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: Text('AVBRYT'),
      ),
    ],
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return alert;
        });
      });
}
