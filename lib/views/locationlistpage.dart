import 'dart:core';
import 'package:flutter/material.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/locationlistitem.dart';

List<LocationListItem> locationList = [
  LocationListItem(title:' Attsjö',id:'attsjo',temperature:'7.9',),LocationListItem(title:'Aareavaara',id:'aareavaara',temperature:'-15.7',),LocationListItem(title:'Abisko/Utsikten',id:'utsikten_abisko',temperature:'-5.3',),LocationListItem(title:'Adak',id:'adak',temperature:'-4.9',),LocationListItem(title:'Alfta',id:'alfta',temperature:'3.8',),LocationListItem(title:'Alfta/Born',id:'born',temperature:'3.6',),LocationListItem(title:'Alfta/Centrum',id:'alfta_centrum',temperature:'3.9',),LocationListItem(title:'Alfta/Industricenter',id:'alfta_industricenter',temperature:'4.2',),LocationListItem(title:'Alingsås/Centrum',id:'alingsas_c',temperature:'8.9',),LocationListItem(title:'Alingsås/Väst',id:'alingsas-vast',temperature:'N/A',),LocationListItem(title:'Alnö/Gustavsberg',id:'gustavsberg1',temperature:'2.1',),LocationListItem(title:'Alsike',id:'alsike',temperature:'6.5',),LocationListItem(title:'Ankarsund',id:'ankarsund',temperature:'-3.4',),LocationListItem(title:'Antnäs',id:'antnas',temperature:'-5.1',),LocationListItem(title:'Arboga/Assartorp',id:'assartorp',temperature:'6.1',),LocationListItem(title:'Arboga/Centrum',id:'arboga',temperature:'N/A',),LocationListItem(title:'Arboga/Nybyholm',id:'nybyholm',temperature:'7.4',),LocationListItem(title:'Arboga/Teknikbacken',id:'teknikbacken',temperature:'N/A',),LocationListItem(title:'Arboga/Tyringe',id:'tyringe',temperature:'6.8',),LocationListItem(title:'Arvidsjaur',id:'arvidsjaur',temperature:'-3.5',),LocationListItem(title:'Arvika/Rackstad',id:'rackstad',temperature:'3.6',),LocationListItem(title:'Arvslindan',id:'arvslindan',temperature:'3.5',),LocationListItem(title:'Asa',id:'asa',temperature:'8.1',),LocationListItem(title:'Askeby',id:'askeby',temperature:'8.9',),LocationListItem(title:'Askersund/Gålsjö',id:'galsjo',temperature:'7.6',),LocationListItem(title:'Asklanda',id:'asklanda',temperature:'7.1',),
];


class LocationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mätstationer'),),
      drawer: AppDrawer(),
      body: Builder(
        builder: (context) => Center(
          child: Container(
            margin: EdgeInsets.all(20.0),
            width: double.infinity,
            height: double.infinity,
            child: ListView.builder(
              itemCount: locationList.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    leading: Icon(Icons.ac_unit),
                    title: Text(locationList[index].title.trim()),
                    subtitle: Text(locationList[index].temperature),
                  )
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}