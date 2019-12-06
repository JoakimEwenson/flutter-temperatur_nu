import 'package:flutter/material.dart';
import 'package:temperatur.nu/views/drawer.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Om appen'),),
      drawer: AppDrawer(),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            margin: EdgeInsets.all(20.0),
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: <Widget>[
                Image.asset('icon/Solflinga.png', height: 100,),
                Text('temperatur.nu', style: Theme.of(context).textTheme.display2,),
                Text('Version 1.0 beta', style: Theme.of(context).textTheme.subtitle,),
                Text('Av: Joakim Ewenson (joakim@ewenson.se)', style: Theme.of(context).textTheme.body1,)
              ],
            )
          )
        ),
      ),
    );
  }
}