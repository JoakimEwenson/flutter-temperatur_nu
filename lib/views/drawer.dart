import 'package:flutter/material.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Drawer(
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 120,
            child: DrawerHeader(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: ExactAssetImage('icon/temperatur_nu.png'),
                      //image: ExactAssetImage('icon/Solflinga.png'),
                      fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.home,
              color: _isDarkMode ? darkIconColor : lightIconColor,
            ),
            title: Text('Hemstation'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
          ),
          ListTile(
            leading: Icon(
              Icons.favorite,
              color: imperialRed,
            ),
            title: Text('Favoriter'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/Favorites');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.gps_fixed,
              color: _isDarkMode ? darkIconColor : lightIconColor,
            ),
            title: Text('Närliggande mätpunkter'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/Nearby');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.list,
              color: _isDarkMode ? darkIconColor : lightIconColor,
            ),
            title: Text('Lista alla mätpunkter'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/LocationList');
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              color: _isDarkMode ? darkIconColor : lightIconColor,
            ),
            title: Text('Inställningar'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/Settings');
            },
          )
        ],
      ),
    );
  }
}
