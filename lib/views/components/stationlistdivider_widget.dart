import 'package:flutter/material.dart';

class StationListDivider extends StatelessWidget {
  const StationListDivider({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Divider(
      indent: 16,
      endIndent: 16,
    );
  }
}
