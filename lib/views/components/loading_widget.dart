import 'package:flutter/material.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: Text(
              'Hämtar data',
              style: pageTitle,
            ),
          ),
          LinearProgressIndicator(
            backgroundColor: lightModeTextColor,
            minHeight: 2,
          ),
        ],
      ),
    );
  }
}
