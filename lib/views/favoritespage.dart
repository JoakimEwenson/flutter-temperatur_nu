import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur.nu/controller/common.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/model/post.dart';

// Set up SharedPreferences for accessing local storage
SharedPreferences sp;

Future<List> favorites;

Future<List> getFavoritesString() async {
  sp = await SharedPreferences.getInstance();
  var favString = sp.getString('favorites');
  var favList  = favString.split(',');

  return favList;
}

// List of favorites, maximum 5 returns!
//List tempFav = ['romstad','chalmers','asbro','kungsholmen','jarvastaden'];

class FavoritesPage extends StatefulWidget {
  FavoritesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final GlobalKey<RefreshIndicatorState> _refreshFavoritesKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchSharedPreferences();
    Future.delayed(const Duration(milliseconds: 250), () {
      if(!sp.containsKey('favoritesListTimeout')) {
        setTimeStamp('favoritesListTimeout');
      }
      setState(() {
        favorites = fetchFavorites();
        setTimeStamp('favoritesListTimeout');
      });
    });
  }

  Future<void> _fetchSharedPreferences() async {
    sp = await SharedPreferences.getInstance();
  }

  Future<void> _refreshList() async {
    num timestamp = int.tryParse(sp.getString('mainScreenTimeout'));
    num timediff = compareTimeStamp(timestamp, DateTime.now().millisecondsSinceEpoch.toInt());
    if (timediff > 300000) {
      setState(() {
        favorites = fetchFavorites();
        setTimeStamp('favoritesListTimeout');
      });
    }
    else {
      var time = (timediff / 60000).toStringAsFixed(1);
      //print('Det har passerat $time minuter sedan senaste uppdateringen.'); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favoriter'),),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        child: favoritesList(),
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).accentColor,
        key: _refreshFavoritesKey,
        onRefresh: () => _refreshList(),
      ),
    );
  }

  Widget favoritesList() {
    return FutureBuilder(
      future: favorites,
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
                  Post tempData = snapshot.data[index];
                  return GestureDetector(
                    child: Card(
                      child: ListTile(
                        leading: Icon(Icons.ac_unit),
                        title: Text(tempData.title),
                        subtitle: Text(tempData.municipality + " - " + tempData.county),
                        trailing: Text(tempData.temperature + "°C", style: Theme.of(context).textTheme.display1,),
                        onTap: () {
                          //saveLocationId(tempData.id);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false, arguments: LocationArguments(tempData.id));
                        },
                      )
                    )
                  );
                },
              );
            }
            else if(snapshot.hasError) {
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