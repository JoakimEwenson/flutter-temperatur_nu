import 'package:flutter/material.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({Key key, this.title, this.msg}) : super(key: key);

  final String title;
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          title == null
              ? Text(
                  'Något gick fel!',
                  style: pageTitle,
                )
              : Text(
                  '$title',
                  style: pageTitle,
                ),
          if (msg.isNotEmpty)
            Text(
              "$msg",
              style: bodyText,
            ),
        ],
      ),
    );
  }
}
