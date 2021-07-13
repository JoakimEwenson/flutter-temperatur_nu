import 'package:flutter/material.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({Key key, this.msg}) : super(key: key);

  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            'Något gick fel!',
            style: pageTitle,
          ),
          Text(
            "$msg",
            style: bodyText,
          ),
        ],
      ),
    );
  }
}
