import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur.nu/common.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/locationlistitem.dart';

SharedPreferences sp;

saveLocationId(String savedId) async {
  sp = await SharedPreferences.getInstance();
  sp.setString('location', savedId);
}

Widget locationList() {
  return FutureBuilder(
    future: fetchLocationList(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            LocationListItem listItem = snapshot.data[index];
            return GestureDetector(
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.ac_unit),
                  title: Text(listItem.title),
                  trailing: Text(listItem.temperature + "°C", style: Theme.of(context).textTheme.display1,),
                  onTap: () => Scaffold.of(context).showSnackBar(SnackBar(content: Text("Mätstationens id: " + listItem.id),)),
                  onLongPress: () {
                    saveLocationId(listItem.id);
                    Navigator.pushNamed(context, '/');
                  },
                )
              )
            );
          },
        );
      }

      return Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 25,),
            CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,),
            Text('Hämtar data', style: Theme.of(context).textTheme.display2,)
          ],
        )
      );
    },
  );
}

class LocationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mätstationer'),),
      drawer: AppDrawer(),
      body: locationList(),
    );
  }
}