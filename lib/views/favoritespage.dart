import 'dart:core';
import 'package:flutter/material.dart';
import 'package:temperatur.nu/common.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/post.dart';

List tempFav = ['karlstad','karlstad_haga','kronoparken','romstad','skare','skareberget'];

Widget favoritesList(List favSearch) {
  return FutureBuilder(
    future: fetchFavorites(tempFav),
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
                  subtitle: Text(tempData.municipality + " - " + tempData.county),
                  trailing: Text(tempData.temperature + "°C", style: Theme.of(context).textTheme.display2,),
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
    }
  );
}



class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favoriter'),),
      drawer: AppDrawer(),
      body: favoritesList(tempFav),
    );
  }
}