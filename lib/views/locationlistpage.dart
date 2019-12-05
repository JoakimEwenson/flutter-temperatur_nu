import 'package:flutter/material.dart';
import 'package:temperatur.nu/views/drawer.dart';

class LocationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mätstationer'),),
      drawer: AppDrawer(),
    );
  }
}