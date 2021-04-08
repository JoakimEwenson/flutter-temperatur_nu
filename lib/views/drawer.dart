import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            //color: Theme.of(context).primaryColor,
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
