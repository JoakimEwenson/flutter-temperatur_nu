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
            width: double.infinity,
            height: double.infinity,
            child: Column(
              children: <Widget>[
                SizedBox(height: 25,),
                Image.asset('icon/Solflinga.png', height: 100,),
                Text('temperatur.nu', style: Theme.of(context).textTheme.display2,),
                SizedBox(height: 25,),
                Text('version 1.0b', style: Theme.of(context).textTheme.subtitle,),
                SizedBox(height: 10,),
                Text('https://www.ewenson.se', style: Theme.of(context).textTheme.body1),
              ],
            )
          )
        ),
      ),
    );
  }
}