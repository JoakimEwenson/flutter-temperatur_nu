import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 135,
            child: DrawerHeader(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.ac_unit, color: Theme.of(context).accentColor),
                    title: Text('HUVUDMENY', style: TextStyle(color: Theme.of(context).accentColor, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Startsida'),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Icon(Icons.favorite),
            title: Text('Favoriter'),
            onTap: () {
              Navigator.pushNamed(context, '/Favorites');
            },
          ),
          ListTile(
            leading: Icon(Icons.list),
            title: Text('Mätpunkter'),
            onTap: () {
              Navigator.pushNamed(context, '/LocationList');
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Inställningar'),
            onTap: () {
              Navigator.pushNamed(context, '/Settings');
            },
          )
        ],
      ),
    );
  }
}