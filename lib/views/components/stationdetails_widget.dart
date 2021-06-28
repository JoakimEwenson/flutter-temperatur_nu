import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:temperatur_nu/controller/favorites.dart';
import 'package:temperatur_nu/controller/userHome.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/model/TooManyFavoritesException.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class StationDetailsWidget extends StatefulWidget {
  const StationDetailsWidget({
    Key key,
    @required this.station,
  }) : super(key: key);

  final Station station;

  @override
  _StationDetailsWidgetState createState() => _StationDetailsWidgetState();
}

class _StationDetailsWidgetState extends State<StationDetailsWidget> {
  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: double.infinity,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    widget.station.title,
                    style: pageTitle,
                  ),
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: widget.station.temp != null
                    ? Text(
                        "${widget.station.temp}°",
                        style: temperatureHuge,
                        textAlign: TextAlign.center,
                      )
                    : Text(
                        "N/A",
                        style: Theme.of(context).textTheme.headline1,
                        textAlign: TextAlign.center,
                      ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: widget.station.isFavorite
                        ? Icon(
                            Icons.favorite,
                            color: imperialRed,
                          )
                        : Icon(Icons.favorite_outline),
                    onPressed: () async {
                      try {
                        if (widget.station.isFavorite) {
                          if (await removeFromFavorites(widget.station.id)) {
                            widget.station.isFavorite =
                                await existsInFavorites(widget.station.id);
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tog bort ${widget.station.title} från favoriter.',
                                  ),
                                ),
                              );
                            setState(() {
                              widget.station.isFavorite = false;
                            });
                          } else {
                            widget.station.isFavorite =
                                await existsInFavorites(widget.station.id);
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Det gick inte att ta bort ${widget.station.title} från favoriter.'),
                                ),
                              );
                            setState(() {
                              widget.station.isFavorite = false;
                            });
                          }
                        } else {
                          if (await addToFavorites(widget.station.id)) {
                            widget.station.isFavorite =
                                await existsInFavorites(widget.station.id);
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'La till ${widget.station.title} i favoriter.'),
                                ),
                              );
                            setState(() {
                              widget.station.isFavorite = true;
                            });
                          } else {
                            widget.station.isFavorite =
                                await existsInFavorites(widget.station.id);
                            ScaffoldMessenger.of(context)
                              ..removeCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Det gick inte att lägga till ${widget.station.title} i favoriter.'),
                                ),
                              );
                            setState(() {
                              widget.station.isFavorite = false;
                            });
                          }
                          setState(() {});
                        }
                      } on TooManyFavoritesException catch (e) {
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(e.errorMsg()),
                            ),
                          );
                      } catch (e) {
                        ScaffoldMessenger.of(context)
                          ..removeCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                      }
                    },
                  ),
                  Column(
                    children: [
                      Text(
                        widget.station.sourceInfo,
                        style: stationOwner,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'Uppdaterad ${DateFormat("yyyy-MM-dd HH:mm").format(widget.station.lastUpdate)}',
                        style: stationOwner,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  IconButton(
                    icon: widget.station.isHome
                        ? Icon(
                            Icons.home,
                            color: _isDarkMode ? darkIconColor : lightIconColor,
                          )
                        : Icon(Icons.home_outlined),
                    onPressed: () async {
                      try {
                        if (widget.station.isHome) {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                                content: Text(
                                    'Du har redan ${widget.station.title} som hemstation')));
                        }
                        if (!widget.station.isHome) {
                          ScaffoldMessenger.of(context)
                            ..removeCurrentSnackBar()
                            ..showSnackBar(SnackBar(
                                content: Text(
                                    'Du har valt ${widget.station.title} som hemstation')));
                          setState(() {
                            saveUserHome(widget.station.id);
                            widget.station.isHome = true;
                          });
                        }
                      } catch (e) {}
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
