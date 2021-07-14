import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/common.dart';

import 'package:temperatur_nu/controller/fetchNearbyLocations.dart';
import 'package:temperatur_nu/controller/timestamps.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/loading_widget.dart';
import 'package:temperatur_nu/views/components/navbar_widget.dart';
import 'package:temperatur_nu/views/components/nodata_widget.dart';
import 'package:temperatur_nu/views/components/stationlistdivider_widget.dart';
import 'package:temperatur_nu/views/components/stationlisttile_widget.dart';
import 'package:temperatur_nu/views/components/theme.dart';

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
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
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
    num timestamp = sp.containsKey('mainScreenTimeout')
        ? int.tryParse(sp.getString('mainScreenTimeout'))
        : 0;
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarWidget(page: Pages.nearby),
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: RefreshIndicator(
          child: nearbyList(),
          color: Theme.of(context).primaryColor,
          backgroundColor: Theme.of(context).accentColor,
          key: _refreshIndicatorKey,
          onRefresh: () => _refreshList(),
        ),
      ),
    );
  }

  Widget nearbyList() {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return FutureBuilder(
      future: locationList,
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            {
              return LoadingWidget();
            }
          case ConnectionState.active:
            {
              return LoadingWidget();
            }
          case ConnectionState.done:
            {
              if (snapshot.hasData) {
                List<Station> stations = snapshot.data.stations;
                //inspect(stations);
                return SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Text(
                          'Närliggande mätstationer',
                          style: pageTitle,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isDarkMode
                              ? tempCardDarkBackground
                              : tempCardLightBackground,
                          borderRadius: BorderRadius.circular(cardBorderRadius),
                        ),
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
                      SizedBox(
                        height: 32,
                      ),
                    ],
                  ),
                );
              } else if (snapshot.hasError) {
                return NoDataWidget(
                  msg: snapshot.error,
                );
              }

              break;
            }
          case ConnectionState.none:
            {
              break;
            }
        }
        return LoadingWidget();
      },
    );
  }
}
