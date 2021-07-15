import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/controller/favorites.dart';
import 'package:temperatur_nu/controller/fetchFavorites.dart';
import 'package:temperatur_nu/controller/timestamps.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/loading_widget.dart';
import 'package:temperatur_nu/views/components/navbar_widget.dart';
import 'package:temperatur_nu/views/components/nodata_widget.dart';
import 'package:temperatur_nu/views/components/temperaturecard_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

// Set up SharedPreferences for accessing local storage
SharedPreferences sp;

Future<StationNameVerbose> favorites;

Future<List> getFavoritesString() async {
  sp = await SharedPreferences.getInstance();
  var favString = sp.getString('favorites');
  var favList = favString.split(',');

  return favList;
}

class FavoritesPage extends StatefulWidget {
  FavoritesPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  GlobalKey<RefreshIndicatorState> _refreshFavoritesKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchSharedPreferences();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!sp.containsKey('favoritesListTimeout')) {
        setTimeStamp('favoritesListTimeout');
      }
      setState(() {
        favorites = fetchFavorites(false);
        setTimeStamp('favoritesListTimeout');
      });
    });
  }

  Future<void> _fetchSharedPreferences() async {
    sp = await SharedPreferences.getInstance();
  }

  Future<void> _refreshList() async {
    setState(() {
      favorites = fetchFavorites(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(
        page: Pages.favorites,
      ),
      extendBody: true,
      extendBodyBehindAppBar: false,
      body: SafeArea(
        child: RefreshIndicator(
          child: favoritesList(),
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).accentColor,
          key: _refreshFavoritesKey,
          onRefresh: () => _refreshList(),
        ),
      ),
    );
  }

  Widget favoritesList() {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: FutureBuilder(
            future: favorites,
            builder: (context, snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.active:
                  {
                    return LoadingWidget();
                  }
                case ConnectionState.done:
                  {
                    if (!snapshot.hasData) {
                      return NoDataWidget(
                          title: 'Inga favoriter',
                          msg:
                              'Du har inga sparade favoriter än. Tryck på hjärtat för att favoritmarkera en station och försök igen.');
                    }
                    if (snapshot.hasData) {
                      List<Station> stations = snapshot.data.stations;
                      if (stations.length == 1 && stations[0].title.isEmpty) {
                        return NoDataWidget(
                            title: 'Inga favoriter',
                            msg:
                                'Du har inga sparade favoriter än. Tryck på hjärtat för att favoritmarkera en station och försök igen.');
                      }
                      if (stations.length > 0) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Text(
                                'Mina favoritstationer',
                                style: pageTitle,
                              ),
                            ),
                            Container(
                              child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: stations.length,
                                itemBuilder: (context, index) {
                                  Station station = stations[index];
                                  return GestureDetector(
                                    onTap: () {
                                      //saveLocationId(station.id);
                                      Navigator.pushNamed(
                                        context,
                                        '/SingleStation',
                                        arguments:
                                            LocationArguments(station.id),
                                      );
                                    },
                                    child: TemperatureCardWidget(
                                      station: station,
                                      isDarkMode: _isDarkMode,
                                    ),
                                  );
                                  /*
                                  return ListTile(
                                    dense: true,
                                    isThreeLine: false,
                                    leading: IconButton(
                                      icon: station.isFavorite
                                          ? Icon(
                                              Icons.favorite,
                                              color: imperialRed,
                                            )
                                          : Icon(Icons.favorite_outline),
                                      onPressed: () async {
                                        try {
                                          if (station.isFavorite) {
                                            if (await removeFromFavorites(
                                                station.id)) {
                                              station.isFavorite =
                                                  await existsInFavorites(
                                                      station.id);
                                              setState(() {
                                                station.isFavorite = false;
                                              });
                                            } else {
                                              station.isFavorite =
                                                  await existsInFavorites(
                                                      station.id);
                                              setState(() {
                                                station.isFavorite = false;
                                              });
                                            }
                                          } else {
                                            if (await addToFavorites(
                                                station.id)) {
                                              station.isFavorite =
                                                  await existsInFavorites(
                                                      station.id);
                                              setState(() {
                                                station.isFavorite = true;
                                              });
                                            } else {
                                              station.isFavorite =
                                                  await existsInFavorites(
                                                      station.id);
                                              setState(() {
                                                station.isFavorite = false;
                                              });
                                            }
                                            setState(() {});
                                          }
                                        } on TooManyFavoritesException catch (e) {
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  e.errorMsg(),
                                                  style: bodyText,
                                                ),
                                              ),
                                            );
                                        } catch (e) {
                                          ScaffoldMessenger.of(context)
                                            ..removeCurrentSnackBar()
                                            ..showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  e.toString(),
                                                  style: bodyText,
                                                ),
                                              ),
                                            );
                                        }
                                      },
                                    ),
                                    title: Text(
                                      station.title,
                                      style: locationListTileTitle,
                                    ),
                                    subtitle: Text(
                                      "${station.kommun}",
                                      style: locationListTileSubtitle,
                                    ),
                                    trailing: station.temp != null
                                        ? Text(
                                            "${station.temp}°",
                                            style: locationListTileTemperature,
                                          )
                                        : Text(
                                            '$noTempDataString',
                                            style: locationListTileTemperature,
                                          ),
                                    onTap: () {
                                      //saveLocationId(station.id);
                                      Navigator.pushNamed(
                                        context,
                                        '/SingleStation',
                                        arguments:
                                            LocationArguments(station.id),
                                      );
                                    },
                                  );
                                  */
                                },
                                /*
                                separatorBuilder:
                                    (BuildContext context, int index) =>
                                        StationListDivider(),
                                */
                              ),
                            ),
                            SizedBox(
                              height: 32,
                            )
                          ],
                        );
                      } else {
                        return NoDataWidget(
                            msg: 'Du har inga sparade favoriter än.');
                      }
                    } else if (snapshot.hasError) {
                      return NoDataWidget(msg: snapshot.error);
                    }

                    break;
                  }
                case ConnectionState.none:
                  {
                    break;
                  }
                case ConnectionState.waiting:
                  {
                    return LoadingWidget();
                  }
              }

              return LoadingWidget();
            }),
      ),
    );
  }

  favoritesDialog(BuildContext context, Station station, String type) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Ta bort favorit?",
            style: bodyText,
          ),
          content: Text(
            "Är du säker på att du vill ta bort ${station.title} som favorit?",
            style: bodyText,
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (await removeFromFavorites(station.id)) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(SnackBar(
                      content: Text(
                        'Tog bort ${station.title} från favoriter.',
                        style: bodyText,
                      ),
                    ));
                  setState(() {
                    favorites = fetchFavorites(false);
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text(
                'Ja',
                style: bodyText,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Nej',
                style: bodyText,
              ),
            ),
          ],
        );
      },
    );
  }
}
