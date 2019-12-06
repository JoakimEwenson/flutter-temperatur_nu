import 'dart:core';
import 'package:flutter/material.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/post.dart';

List<Post> favorites = [
    Post(
      title: 'Karlstad',
      id: 'karlstad',
      temperature: '6,6°C',
      amm: '',
      lastUpdate: '2019-12-06 13:17:10',
      sourceInfo: 'Temperaturdata från Magnus väderstation i Karlstad.',
      sourceUrl: 'https://www.temperatur.nu/karlstad.html'
    ),
    Post(
      title: 'Karlstad/Haga',
      id: 'karlstad_haga',
      temperature: '-7,1°C',
      amm: '',
      lastUpdate: '2019-12-06 13:15:12',
      sourceInfo: '',
      sourceUrl: 'https://www.temperatur.nu/karlstad_haga.html'
    ),
    Post(
      title: 'Karlstad/Kronoparken',
      id: 'kronoparken',
      temperature: '6,1°C',
      amm: '',
      lastUpdate: '2019-12-06 13:16:12',
      sourceInfo: 'Temperaturdata från Örjan Almén.',
      sourceUrl: 'https://www.temperatur.nu/kronoparken.html'
    ),
    Post(
      title: 'Karlstad/Romstad',
      id: 'romstad',
      temperature: '6,2',
      amm: '',
      lastUpdate: '2019-12-06 13:15:30',
      sourceInfo: 'Temperaturdata från Lars Hultqvist.',
      sourceUrl: 'https://www.temperatur.nu/romstad.html',
    ),
    Post(
      title: 'Karlstad/Skåre',
      id: 'skare',
      temperature: '5,8',
      amm: '',
      lastUpdate: '2019-12-06 13:16:13',
      sourceInfo: 'Temperaturdata från Magnus Larsgården.',
      sourceUrl: 'https://www.temperatur.nu/skare.html',
    ),
    Post(
      title: 'Karlstad/Skåreberget',
      id: 'skareberget',
      temperature: '6,2',
      amm: '',
      lastUpdate: '2019-12-06 13:16:20',
      sourceInfo: 'Temperaturdata från Henrik Lönnroth Hartelius.',
      sourceUrl: 'https://www.temperatur.nu/skareberget.html',
    )
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