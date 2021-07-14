import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class NavigationBarWidget extends StatefulWidget {
  const NavigationBarWidget({Key key, this.page}) : super(key: key);

  final Pages page;

  @override
  _NavigationBarWidgetState createState() => _NavigationBarWidgetState();
}

class _NavigationBarWidgetState extends State<NavigationBarWidget> {
  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      padding: EdgeInsets.only(
          bottom: Theme.of(context).platform == TargetPlatform.iOS ? 24 : 0),
      //width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: tnuYellow),
        ),
        color: _isDarkMode ? tempCardDarkBackground : tempCardDarkBackground,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: Icon(Icons.home),
            color: widget.page == Pages.home ? tnuYellow : Colors.white70,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: Icon(Icons.favorite),
            color: widget.page == Pages.favorites ? tnuYellow : Colors.white70,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Favorites');
            },
          ),
          IconButton(
            icon: Icon(Icons.gps_fixed),
            color: widget.page == Pages.nearby ? tnuYellow : Colors.white70,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Nearby');
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            color: widget.page == Pages.locations ? tnuYellow : Colors.white70,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/LocationList');
            },
          ),
          IconButton(
            icon: Icon(Icons.settings),
            color: widget.page == Pages.settings ? tnuYellow : Colors.white70,
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/Settings');
            },
          ),
        ],
      ),
    );
  }
}
