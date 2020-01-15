import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur.nu/controller/common.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/model/locationlistitem.dart';

// Set up Shared Preferences for accessing local storage
SharedPreferences sp;
// Set up ScrollController for saving list position
ScrollController _controller;


// Prepare future data
Future<List> locations;


class LocationListPage extends StatefulWidget {
  LocationListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  final GlobalKey<RefreshIndicatorState> _refreshLocationsKey = new GlobalKey<RefreshIndicatorState>();

  double scrollPosition = 0.0;


  _getScrollPosition() async {
    sp = await SharedPreferences.getInstance();
    if(sp.containsKey('position')) {
      scrollPosition = sp.getDouble('position');
    }
  }

  _setScrollPosition() async {
    sp = await SharedPreferences.getInstance();
    sp.setDouble('position', _controller.position.pixels);
  }

  @override 
  void initState() {
    super.initState();
    _getScrollPosition();

    Future.delayed(const Duration(milliseconds: 250), () {
      _controller = ScrollController(initialScrollOffset: scrollPosition ?? 0.0);
      _controller.addListener(_setScrollPosition);
      if(!sp.containsKey('locationListTimeout')) {
        setTimeStamp('locationListTimeout');
      }
      setState(() {
        locations = fetchLocationList();
        setTimeStamp('locationListTimeout');
      });
    });
  }

  Future<void> _refreshList() async {
    num timestamp = int.tryParse(sp.getString('locationListTimeout'));
    num timediff = compareTimeStamp(timestamp, DateTime.now().millisecondsSinceEpoch.toInt());
    if (timediff > 300000) {
      setState(() {
        locations = fetchLocationList();
        setTimeStamp('locationListTimeout');
      });
    }
    else {
      var time = (timediff / 60000).toStringAsFixed(1);
      print('Det har passerat $time minuter sedan senaste uppdateringen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mätstationer'),),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        child: locationList(),
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).accentColor,
        key: _refreshLocationsKey,
        onRefresh: () => _refreshList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget locationList() {
    return FutureBuilder(
      future: locations,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active: {
            return loadingView();
          }
          case ConnectionState.done: {
            if (snapshot.hasData) {
              return ListView.builder(
                controller: _controller,
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  LocationListItem listItem = snapshot.data[index];
                  return GestureDetector(
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.ac_unit),
                        title: Text(listItem.title),
                        trailing: Text(listItem.temperature + "°C", style: Theme.of(context).textTheme.display1,),
                        onTap: () {
                          //saveLocationId(listItem.id);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false, arguments: LocationArguments(listItem.id));
                        },
                      )
                    )
                  );
                },
              );
            }
            else if (snapshot.hasError) {
              return noDataView(snapshot.error);
            }

            break;
          }
          case ConnectionState.none: {
            break;
          }
          case ConnectionState.waiting: {
            return loadingView();
          }
        }

        return loadingView();
      },
    );
  }

  // Loading indicator
  loadingView() {
    return Center(
      child: Column(
        children: <Widget>[
          SizedBox(height: 25,),
          CircularProgressIndicator(backgroundColor: Theme.of(context).primaryColor,),
          Text('Hämtar data', style: Theme.of(context).textTheme.display2,),
        ],
      ),
    );
  }

  // Error/No data view
  noDataView(String msg) {
    return Center(
      child: Column(
        children: <Widget>[
          Text('Något gick fel!', style: Theme.of(context).textTheme.display2,),
          Text(msg, style: Theme.of(context).textTheme.body2,),
        ],
      ),
    );
  }
}