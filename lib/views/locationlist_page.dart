import 'dart:core';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';
import 'package:temperatur_nu/controller/fetchLocationList.dart';
import 'package:temperatur_nu/controller/sorting.dart';
import 'package:temperatur_nu/controller/timestamps.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/loading_widget.dart';
import 'package:temperatur_nu/views/components/stationlistdivider_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

// Set up Shared Preferences for accessing local storage
SharedPreferences sp;
// Set up ScrollController for saving list position
ScrollController _controller;

// Prepare future data
Future<StationNameVerbose> locations;

class LocationListPage extends StatefulWidget {
  LocationListPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LocationListPageState createState() => _LocationListPageState();
}

class _LocationListPageState extends State<LocationListPage> {
  GlobalKey<RefreshIndicatorState> _refreshLocationsKey =
      new GlobalKey<RefreshIndicatorState>();

  double scrollPosition = 0.0;
  num timestamp;
  num timediff;
  String _sortingChoice = "alphabetical";

  _getScrollPosition() async {
    sp = await SharedPreferences.getInstance();
    if (sp.containsKey('position')) {
      scrollPosition = sp.getDouble('position');
    }
  }

  _setScrollPosition({bool resetPosition = false}) async {
    sp = await SharedPreferences.getInstance();
    if (resetPosition) {
      _controller.animateTo(0.0,
          duration: Duration(seconds: 1), curve: Curves.ease);
      sp.setDouble('position', 0.0);
    } else {
      sp.setDouble('position', _controller.position.pixels);
    }
  }

  _getSortingOrder() async {
    sp = await SharedPreferences.getInstance();
    if (sp.containsKey('sortingOrder')) {
      _sortingChoice = sp.getString('sortingOrder');
    }
  }

  @override
  void initState() {
    super.initState();
    _getScrollPosition();
    _getSortingOrder();

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
        if (timediff > cacheTimeout) {
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
    _getSortingOrder();
    _setScrollPosition(resetPosition: true);
    timestamp = int.tryParse(sp.getString('locationListTimeout'));
    timediff = compareTimeStamp(
        timestamp, DateTime.now().millisecondsSinceEpoch.toInt());
    if (timediff > cacheTimeout) {
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
    return FutureBuilder(
        future: locations,
        builder: (context, snapshot) {
          return Scaffold(
            /*
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: Search(
                        snapshot.hasData ? snapshot.data.stations : [],
                      ),
                    );
                  },
                ),
                IconButton(
                    icon: Icon(Icons.arrow_upward),
                    onPressed: () {
                      _setScrollPosition(resetPosition: true);
                    }),
                PopupMenuButton<SortingChoice>(
                  icon: Icon(Icons.filter_list),
                  onSelected: (SortingChoice choice) {
                    if (snapshot.hasData) {
                      switch (choice.id) {
                        case 'alphabetical':
                          setState(() {
                            _sortingChoice = "alphabetical";
                            _setScrollPosition(resetPosition: true);
                            saveSortingOrder(_sortingChoice);
                          });
                          break;
                        case 'highest':
                          setState(() {
                            _sortingChoice = "highest";
                            _setScrollPosition(resetPosition: true);
                            saveSortingOrder(_sortingChoice);
                          });
                          break;
                        case 'lowest':
                          setState(() {
                            _sortingChoice = "lowest";
                            _setScrollPosition(resetPosition: true);
                            saveSortingOrder(_sortingChoice);
                          });
                          break;
                        case 'north':
                          setState(() {
                            _sortingChoice = "north";
                            _setScrollPosition(resetPosition: true);
                            saveSortingOrder(_sortingChoice);
                          });
                          break;
                        case 'south':
                          setState(() {
                            _sortingChoice = 'south';
                            _setScrollPosition(resetPosition: true);
                            saveSortingOrder(_sortingChoice);
                          });
                      }
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return sortingChoices.map((SortingChoice choice) {
                      return PopupMenuItem<SortingChoice>(
                        child: ListTile(
                          leading: choice.icon,
                          title: Text(choice.title),
                        ),
                        value: choice,
                      );
                    }).toList();
                  },
                )
              ],
            ),*/
            body: NestedScrollView(
              controller: _controller,
              headerSliverBuilder: (context, innerBoxScrolled) => [
                SliverAppBar(
                  floating: true,
                  snap: true,
                  pinned: false,
                  backgroundColor: appCanvasColor,
                  elevation: 0,
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: Search(
                            snapshot.hasData ? snapshot.data.stations : [],
                          ),
                        );
                      },
                    ),
                    IconButton(
                        icon: Icon(Icons.arrow_upward),
                        onPressed: () {
                          _setScrollPosition(resetPosition: true);
                        }),
                    PopupMenuButton<SortingChoice>(
                      icon: Icon(Icons.filter_list),
                      onSelected: (SortingChoice choice) {
                        if (snapshot.hasData) {
                          switch (choice.id) {
                            case 'alphabetical':
                              setState(() {
                                _sortingChoice = "alphabetical";
                                _setScrollPosition(resetPosition: true);
                                saveSortingOrder(_sortingChoice);
                              });
                              break;
                            case 'highest':
                              setState(() {
                                _sortingChoice = "highest";
                                _setScrollPosition(resetPosition: true);
                                saveSortingOrder(_sortingChoice);
                              });
                              break;
                            case 'lowest':
                              setState(() {
                                _sortingChoice = "lowest";
                                _setScrollPosition(resetPosition: true);
                                saveSortingOrder(_sortingChoice);
                              });
                              break;
                            case 'north':
                              setState(() {
                                _sortingChoice = "north";
                                _setScrollPosition(resetPosition: true);
                                saveSortingOrder(_sortingChoice);
                              });
                              break;
                            case 'south':
                              setState(() {
                                _sortingChoice = 'south';
                                _setScrollPosition(resetPosition: true);
                                saveSortingOrder(_sortingChoice);
                              });
                          }
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return sortingChoices.map((SortingChoice choice) {
                          return PopupMenuItem<SortingChoice>(
                            child: ListTile(
                              leading: choice.icon,
                              title: Text(choice.title),
                            ),
                            value: choice,
                          );
                        }).toList();
                      },
                    )
                  ],
                ),
              ],
              body: RefreshIndicator(
                child: locationList(),
                color: Theme.of(context).primaryColor,
                backgroundColor: Theme.of(context).accentColor,
                key: _refreshLocationsKey,
                onRefresh: () => _refreshList(),
              ),
            ),
          );
        });
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
          case ConnectionState.active:
            {
              return LoadingWidget();
            }
          case ConnectionState.done:
            {
              if (snapshot.hasData) {
                List<Station> stations = snapshot.data.stations;
                if (_sortingChoice == "alphabetical") {
                  stations.sort((a, b) => a.title.compareTo(b.title));
                } else if (_sortingChoice == "highest") {
                  stations.sort((a, b) {
                    if (a.temp == null && b.temp == null) {
                      return 0;
                    }
                    if (a.temp == null) {
                      return 1;
                    }
                    if (b.temp == null) {
                      return -1;
                    } else {
                      return b.temp.compareTo(a.temp);
                    }
                  });
                } else if (_sortingChoice == "lowest") {
                  stations.sort((a, b) {
                    if (a.temp == null && b.temp == null) {
                      return 0;
                    }
                    if (a.temp == null) {
                      return 1;
                    }
                    if (b.temp == null) {
                      return -1;
                    } else {
                      return a.temp.compareTo(b.temp);
                    }
                  });
                } else if (_sortingChoice == "north") {
                  stations.sort((a, b) {
                    if (a.lat == null && b.lat == null) {
                      return 0;
                    }
                    if (a.lat == null) {
                      return 1;
                    }
                    if (b.lat == null) {
                      return -1;
                    } else {
                      return b.lat.compareTo(a.lat);
                    }
                  });
                } else if (_sortingChoice == "south") {
                  stations.sort((a, b) {
                    if (a.lat == null && b.lat == null) {
                      return 0;
                    }
                    if (a.lat == null) {
                      return 1;
                    }
                    if (b.lat == null) {
                      return -1;
                    } else {
                      return a.lat.compareTo(b.lat);
                    }
                  });
                }
                return Card(
                  elevation: 0,
                  child: ListView.separated(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    separatorBuilder: (BuildContext context, int index) =>
                        StationListDivider(),
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      Station station = stations[index];
                      return GestureDetector(
                        child: ListTile(
                          dense: true,
                          title: Text(
                            station.title,
                            style: locationListTileTitle,
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
                            Navigator.pushNamed(context, '/SingleStation',
                                arguments: LocationArguments(station.id));
                          },
                        ),
                      );
                    },
                  ),
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
              return LoadingWidget();
            }
        }

        return LoadingWidget();
      },
    );
  }

  // Error/No data view
  noDataView(String msg) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            'Något gick fel!',
            style: pageTitle,
          ),
          Text(
            msg,
            style: bodyText,
          ),
        ],
      ),
    );
  }
}

class SortingChoice {
  const SortingChoice({this.id, this.title, this.icon});

  final String title;
  final String id;
  final Icon icon;
}

const List<SortingChoice> sortingChoices = const <SortingChoice>[
  const SortingChoice(
    id: 'alphabetical',
    title: 'Alfabetiskt',
    icon: Icon(Icons.sort_by_alpha),
  ),
  const SortingChoice(
    id: 'highest',
    title: 'Högsta temperatur överst',
    icon: Icon(Icons.trending_down),
  ),
  const SortingChoice(
    id: 'lowest',
    title: 'Lägsta temperatur överst',
    icon: Icon(Icons.trending_up),
  ),
  const SortingChoice(
    id: 'north',
    title: 'Norr till söder',
    icon: Icon(Icons.south),
  ),
  const SortingChoice(
    id: 'south',
    title: 'Söder till norr',
    icon: Icon(Icons.north),
  )
];

class Search extends SearchDelegate {
  final List<Station> inputList;
  Search(this.inputList);
  final String searchFieldLabel = 'Sök mätstation';

  List<Station> recentList = [];

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
      icon: Icon(Icons.chevron_left),
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
    List<Station> suggestionList = [];
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
            style: bodyText,
          ),
          leading: query.isEmpty ? Icon(Icons.access_time) : SizedBox(),
          onTap: () {
            Navigator.pushNamed(context, '/SingleStation',
                arguments: LocationArguments(suggestionList[index].id));
          },
        );
      },
    );
  }
}
