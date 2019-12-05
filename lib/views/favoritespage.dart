import 'package:flutter/material.dart';
import 'package:temperatur.nu/views/drawer.dart';

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favoriter'),),
      drawer: AppDrawer(),
    );
  }
}