import 'dart:core' as prefix0;
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/post.dart';

List<Post> favorites = [
    Post(
      title: 'Test',
      id: 'test',
      temperature: '25,0°C',
      amm: '',
      lastUpdate: '',
      sourceInfo: '',
      sourceUrl: 'https://www.ewenson.se'
    ),
    Post(
      title: 'Test 2',
      id: 'test',
      temperature: '-15,0°C',
      amm: '',
      lastUpdate: '',
      sourceInfo: '',
      sourceUrl: 'https://www.temperatur.nu'
    ),
    Post(
      title: 'Test 3',
      id: 'test',
      temperature: '0,0°C',
      amm: '',
      lastUpdate: '',
      sourceInfo: '',
      sourceUrl: 'https://www.utf.nu'
    ),
  ];


class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favoriter'),),
      drawer: AppDrawer(),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            margin: EdgeInsets.all(20),
            width: double.infinity,
            height: double.infinity,
            child: ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.ac_unit),
                    title: Text(favorites[index].title),
                    subtitle: Text(favorites[index].temperature),
                  ),
                );
              },
            )
          )
        ),
      ),
    );
  }
}