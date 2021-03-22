import 'dart:core';
import 'dart:developer';
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
Future<List<LocationListItem>> locations;

List<String> titleList = [];

class LocationListPage extends StatefulWidget {
  LocationListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  final GlobalKey<RefreshIndicatorState> _refreshLocationsKey =
      new GlobalKey<RefreshIndicatorState>();

  double scrollPosition = 0.0;
  num timestamp;
  num timediff;

  _getScrollPosition() async {
    sp = await SharedPreferences.getInstance();
    if (sp.containsKey('position')) {
      scrollPosition = sp.getDouble('position');
    }
  }

  _setScrollPosition({bool resetPosition = false}) async {
    sp = await SharedPreferences.getInstance();
    if (resetPosition) {
      sp.setDouble('position', 0.0);
    } else {
      sp.setDouble('position', _controller.position.pixels);
    }
  }

  @override
  void initState() {
    super.initState();
    _getScrollPosition();

    Future.delayed(const Duration(milliseconds: 250), () {
      _controller =
          ScrollController(initialScrollOffset: scrollPosition ?? 0.0);
      _controller.addListener(_setScrollPosition);
      if (!sp.containsKey('locationListTimeout')) {
        setTimeStamp('locationListTimeout');
        setState(() {
          locations = fetchLocationList(false);
        });
      } else {
        timestamp = int.tryParse(sp.getString('locationListTimeout'));
        timediff = compareTimeStamp(
            timestamp, DateTime.now().millisecondsSinceEpoch.toInt());
        if (timediff > cacheTimeoutLong) {
          setState(() {
            // Fetch list of locations, getCache false
            locations = fetchLocationList(false);
            setTimeStamp('locationListTimeout');
            //print("Fetch location list from server");
          });
        } else {
          setState(() {
            locations = fetchLocationList(true);
            //print("Fetch location list from cache");
          });
        }
      }
    });
  }

  Future<void> _refreshList() async {
    timestamp = int.tryParse(sp.getString('locationListTimeout'));
    timediff = compareTimeStamp(
        timestamp, DateTime.now().millisecondsSinceEpoch.toInt());
    if (timediff > cacheTimeoutLong) {
      setState(() {
        // Fetch list of locations, getCache false
        locations = fetchLocationList(false);
        setTimeStamp('locationListTimeout');
      });
    } else {
      // Fetch list of locations, getCache true
      locations = fetchLocationList(true);
      //var time = (timediff / 60000).toStringAsFixed(1);
      //print('Det har passerat $time minuter sedan senaste uppdateringen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<LocationListItem> sortedLocationsList = [];
    return FutureBuilder(
        future: locations,
        builder: (context, snapshot) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Mätstationer'),
              actions: <Widget>[
                IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {
                      showSearch(
                          context: context,
                          delegate:
                              Search(snapshot.hasData ? snapshot.data : []));
                    }),
                PopupMenuButton<SortingChoice>(
                    onSelected: (SortingChoice choice) {
                  if (snapshot.hasData) {
                    sortedLocationsList = snapshot.data;
                    switch (choice.id) {
                      case 'alphabetical':
                        print('Alfabetiskt!');
                        setState(() {
                          sortedLocationsList
                              .sort((a, b) => a.title.compareTo(b.title));
                        });
                        break;
                      case 'highest':
                        print('Högst överst');
                        setState(() {
                          sortedLocationsList.sort((a, b) {
                            if (a.temperature == null &&
                                b.temperature == null) {
                              return 0;
                            }
                            if (a.temperature == null) {
                              return 1;
                            }
                            if (b.temperature == null) {
                              return -1;
                            } else {
                              return b.temperature.compareTo(a.temperature);
                            }
                          });
                        });
                        break;
                      case 'lowest':
                        print('Lägst överst');
                        setState(() {
                          sortedLocationsList.sort((a, b) {
                            if (a.temperature == null &&
                                b.temperature == null) {
                              return 0;
                            }
                            if (a.temperature == null) {
                              return 1;
                            }
                            if (b.temperature == null) {
                              return -1;
                            } else {
                              return a.temperature.compareTo(b.temperature);
                            }
                          });
                        });
                        break;
                    }
                  }
                }, itemBuilder: (BuildContext context) {
                  return sortingChoices.map((SortingChoice choice) {
                    return PopupMenuItem<SortingChoice>(
                      child: Text(choice.title),
                      value: choice,
                    );
                  }).toList();
                })
              ],
            ),
            drawer: AppDrawer(),
            body: RefreshIndicator(
              child: locationList(sortedLocationsList),
              color: Theme.of(context).primaryColor,
              backgroundColor: Theme.of(context).accentColor,
              key: _refreshLocationsKey,
              onRefresh: () => _refreshList(),
            ),
          );
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget locationList(List<LocationListItem> sortedLocationList) {
    //inspect(sortedLocationList);
    return FutureBuilder(
      future: locations,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.active:
            {
              return loadingView();
            }
          case ConnectionState.done:
            {
              if (snapshot.hasData) {
                titleList = [];
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
                      trailing: listItem.temperature != null
                          ? Text(
                              "${listItem.temperature}°C",
                              style: Theme.of(context).textTheme.headline4,
                            )
                          : Text(
                              'N/A',
                              style: Theme.of(context).textTheme.headline4,
                            ),
                      onTap: () {
                        //saveLocationId(listItem.id);
                        Navigator.pushNamed(context, '/',
                            arguments: LocationArguments(listItem.id));
                      },
                    )));
                  },
                );
              } else if (snapshot.hasError) {
                return noDataView(snapshot.error);
              }

              break;
            }
          case ConnectionState.none:
            {
              break;
            }
          case ConnectionState.waiting:
            {
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
          SizedBox(
            height: 25,
          ),
          CircularProgressIndicator(
            backgroundColor: Theme.of(context).primaryColor,
          ),
          Text(
            'Hämtar data',
            style: Theme.of(context).textTheme.headline3,
          ),
        ],
      ),
    );
  }

  // Error/No data view
  noDataView(String msg) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            'Något gick fel!',
            style: Theme.of(context).textTheme.headline3,
          ),
          Text(
            msg,
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}

class SortingChoice {
  const SortingChoice({this.id, this.title});

  final String title;
  final String id;
}

const List<SortingChoice> sortingChoices = const <SortingChoice>[
  const SortingChoice(id: 'alphabetical', title: 'Alfabetiskt'),
  const SortingChoice(id: 'highest', title: 'Högsta temperatur överst'),
  const SortingChoice(id: 'lowest', title: 'Lägsta temperatur överst')
];

class Search extends SearchDelegate {
  final List<LocationListItem> inputList;
  Search(this.inputList);
  final String searchFieldLabel = 'Sök mätstation';

  List<LocationListItem> recentList = [];

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      IconButton(
        icon: Icon(Icons.close),
        onPressed: () {
          query = "";
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  String selectedResult = "";

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Center(
        child: Text(selectedResult),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<LocationListItem> suggestionList = [];
    query.isEmpty
        ? suggestionList = recentList //In the true case
        : suggestionList.addAll(inputList.where(
            // In the false case
            (element) =>
                element.title.toLowerCase().contains(query.toLowerCase()),
          ));

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            suggestionList[index].title,
          ),
          leading: query.isEmpty ? Icon(Icons.access_time) : SizedBox(),
          onTap: () {
            /*
            selectedResult =
                "${suggestionList[index].title} (${suggestionList[index].id})";
            showResults(context);
            */
            inspect(suggestionList[index]);
            Navigator.pushNamed(context, '/',
                arguments: LocationArguments(suggestionList[index].id));
          },
        );
      },
    );
  }
}
