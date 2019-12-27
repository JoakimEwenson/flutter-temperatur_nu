import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:temperatur.nu/common.dart';
import 'package:temperatur.nu/post.dart';
import 'package:temperatur.nu/views/drawer.dart';

// Set up SharedPreferences for accessing local storage
SharedPreferences sp;

// Prepare future data
Future<List> locationList;

saveLocationId(String savedId) async {
  sp = await SharedPreferences.getInstance();
  sp.setString('location', savedId);
}


class NearbyListPage extends StatefulWidget {
  NearbyListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _NearbyListPageState createState() => _NearbyListPageState();
}

class _NearbyListPageState extends State<NearbyListPage> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 250), () {
      setState(() {
        locationList = fetchNearbyLocations();
      });
    });
  }

  Future<void> _refreshList() async {
    setState(() {
      locationList = fetchNearbyLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Närliggande mätpunkter'),),
      drawer: AppDrawer(),
      //body: nearbyList(),
      body: RefreshIndicator(
        child: nearbyList(),
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).accentColor,
        key: _refreshIndicatorKey,
        onRefresh: () => _refreshList(),
      ),
    );
  }
  Widget nearbyList() {
    return FutureBuilder(
      future: locationList,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active: {
            return loadingView();
          }
          case ConnectionState.done: {
            if (snapshot.hasData) {
              return ListView.builder(
                physics: AlwaysScrollableScrollPhysics(),
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
                        onTap: () {
                          saveLocationId(tempData.id);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                        },
                      ),
                    ),
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
      }
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