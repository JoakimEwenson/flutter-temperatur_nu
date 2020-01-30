import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            color: Theme.of(context).primaryColor,
            height: 135,
            child: DrawerHeader(
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: ExactAssetImage('icon/temperatur_nu.png'),
                    fit: BoxFit.contain
                  ),
                ),
              ),
          //     child: Column(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         ListTile(
          //           leading: Icon(Icons.ac_unit, ),
          //           title: Text('temperatur.nu', style: Theme.of(context).textTheme.title, ),
          //         ),
          //       ],
          //     ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Startsida'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favoriter'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/Favorites');
            },
          ),
          ListTile(
            leading: Icon(Icons.gps_fixed),
            title: Text('Närliggande mätpunkter'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/Nearby');
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Lista alla mätpunkter'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, '/LocationList');
            },
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('Om appen'),
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