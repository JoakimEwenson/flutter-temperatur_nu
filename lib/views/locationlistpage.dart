import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur.nu/common.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/locationlistitem.dart';

// Set up Shared Preferences for accessing local storage
SharedPreferences sp;

// Prepare future data
Future<List> locations;

/* 
class OldLocationListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mätstationer'),),
      drawer: AppDrawer(),
      body: locationList(),
    );
  }
}
 */

class LocationListPage extends StatefulWidget {
  LocationListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  final GlobalKey<RefreshIndicatorState> _refreshLocationsKey = new GlobalKey<RefreshIndicatorState>();

  @override 
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        locations = fetchLocationList();
      });
    });
  }

  Future<void> _refreshList() async {
    setState(() {
      locations = fetchLocationList();
    });
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
                          saveLocationId(listItem.id);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                        },
                        onLongPress: () async {
                          await showMenu(
                            position: RelativeRect.fromLTRB(100, 100, 100, 400),
                            context: context,
                            items: [
                              PopupMenuItem(
                                child: Text('Test 1'),
                                value: 1,
                              ),
                              PopupMenuItem(
                                child: Text('Test 2'),
                                value: 2,
                              ),
                              PopupMenuItem(
                                child: Text('Test 3'),
                                value: 3,
                              )
                            ]
                          );
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