import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:temperatur.nu/common.dart';
import 'package:temperatur.nu/post.dart';
import 'package:temperatur.nu/views/drawer.dart';

SharedPreferences sp;

saveLocationId(String savedId) async {
  sp = await SharedPreferences.getInstance();
  sp.setString('location', savedId);
}

Widget nearbyList() {
  return FutureBuilder(
    future: fetchNearbyLocations(),
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        return ListView.builder(
          itemCount: snapshot.data.length,
          itemBuilder: (context, index) {
            Post tempData = snapshot.data[index];
            return GestureDetector(
              child: Card(
                child: ListTile(
                  leading: Icon(Icons.ac_unit),
                  title: Text(tempData.title),
                  subtitle: Text(
                    "Avstånd " + tempData.distance + " km\n" + 
                    tempData.municipality + " - " + tempData.county
                  ),
                  trailing: Text(tempData.temperature + "°C", style: Theme.of(context).textTheme.display1,),
                  onLongPress: () {
                    saveLocationId(tempData.id);
                    Navigator.pushNamed(context, '/');
                  },
                ),
              ),
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
        ),
      );
    }
  );
}

class NearbyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Närliggande mätpunkter'),),
      drawer: AppDrawer(),
      body: nearbyList(),
    );
  }
}