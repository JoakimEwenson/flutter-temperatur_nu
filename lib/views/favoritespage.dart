import 'dart:core';
import 'package:flutter/material.dart';
import 'package:temperatur.nu/common.dart';
import 'package:temperatur.nu/views/drawer.dart';
import 'package:temperatur.nu/post.dart';

// List of favorites, maximum 5 returns!
List tempFav = ['romstad','chalmers','asbro','kungsholmen','jarvastaden'];

Future<List> favorites;

/* 
class OldFavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favoriter'),),
      drawer: AppDrawer(),
      body: favoritesList(tempFav),
    );
  }
}
 */

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
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        favorites = fetchFavorites(tempFav);
      });
    });
  }

  Future<void> _refreshList() async {
    setState(() {
      favorites = fetchFavorites(tempFav);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Favoriter'),),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        child: favoritesList(tempFav),
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).accentColor,
        key: _refreshFavoritesKey,
        onRefresh: () => _refreshList(),
      ),
    );
  }

  Widget favoritesList(List favSearch) {
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
                          saveLocationId(tempData.id);
                          Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false);
                        },
                        onLongPress: () {
                          // Add popup menu...
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