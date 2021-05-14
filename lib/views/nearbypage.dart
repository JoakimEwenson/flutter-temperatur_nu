import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';

import 'package:temperatur_nu/controller/fetchNearbyLocations.dart';
import 'package:temperatur_nu/controller/timestamps.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/stationlistdivider_widget.dart';
import 'package:temperatur_nu/views/components/stationlisttile_widget.dart';
import 'package:temperatur_nu/views/drawer.dart';

// Set up SharedPreferences for accessing local storage
SharedPreferences sp;

// Prepare future data
Future<StationNameVerbose> locationList;

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
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _fetchSharedPreferences();
    Future.delayed(const Duration(milliseconds: 250), () {
      if (!sp.containsKey('nearbyListTimeout')) {
        setTimeStamp('nearbyListTimeout');
      }
      setState(() {
        locationList = fetchNearbyLocations(false);
        setTimeStamp('nearbyListTimeout');
      });
    });
  }

  Future<void> _fetchSharedPreferences() async {
    sp = await SharedPreferences.getInstance();
  }

  Future<void> _refreshList() async {
    num timestamp = int.tryParse(sp.getString('mainScreenTimeout'));
    num timediff = compareTimeStamp(
        timestamp, DateTime.now().millisecondsSinceEpoch.toInt());
    if (timediff > cacheTimeout) {
      setState(() {
        locationList = fetchNearbyLocations(false);
        setTimeStamp('nearbyListTimeout');
      });
    } else {
      setState(() {
        locationList = fetchNearbyLocations(true);
      });
      //var time = (timediff / 60000).toStringAsFixed(1);
      //print('Det har passerat $time minuter sedan senaste uppdateringen.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        //title: Text('Närliggande mätpunkter'),
      ),
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
            case ConnectionState.waiting:
              {
                return loadingView();
              }
            case ConnectionState.active:
              {
                return loadingView();
              }
            case ConnectionState.done:
              {
                if (snapshot.hasData) {
                  List<Station> stations = snapshot.data.stations;
                  return SingleChildScrollView(
                    child: Card(
                      margin: const EdgeInsets.only(
                          left: 4, top: 0, right: 4, bottom: 16),
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
                            child: StationListTile(station: station),
                          );
                        },
                      ),
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
          }
          return loadingView();
        });
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
  noDataView(var msg) {
    return Center(
      child: Column(
        children: <Widget>[
          Text(
            'Något gick fel!',
            style: Theme.of(context).textTheme.headline3,
          ),
          Text(
            "$msg",
            style: Theme.of(context).textTheme.bodyText1,
          ),
        ],
      ),
    );
  }
}
