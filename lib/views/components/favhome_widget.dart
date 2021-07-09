import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/favorites.dart';
import 'package:temperatur_nu/controller/userHome.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class FavoriteHomeWidget extends StatefulWidget {
  const FavoriteHomeWidget({Key key, this.station}) : super(key: key);

  final Station station;

  @override
  _FavoriteHomeWidgetState createState() => _FavoriteHomeWidgetState();
}

class _FavoriteHomeWidgetState extends State<FavoriteHomeWidget> {
  @override
  Widget build(BuildContext context) {
    bool _isDarkMode =
        Theme.of(context).brightness == Brightness.dark ? true : false;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TextButton.icon(
            icon: widget.station.isFavorite
                ? Icon(
                    Icons.favorite,
                    color: imperialRed,
                  )
                : Icon(
                    Icons.favorite_outline,
                    color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
                  ),
            label: widget.station.isFavorite
                ? Text(
                    'Favorit',
                    style: TextStyle(
                      color:
                          _isDarkMode ? darkModeTextColor : lightModeTextColor,
                    ),
                  )
                : Text('Favorit',
                    style: TextStyle(
                      color:
                          _isDarkMode ? darkModeTextColor : lightModeTextColor,
                    )),
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
          TextButton.icon(
            onPressed: () async {
              try {
                if (widget.station.isHome) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                            'Du har tagit bort ${widget.station.title} som hemstation'),
                      ),
                    );
                  setState(() {
                    widget.station.isHome = false;
                    removeUserHome();
                  });
                } else if (!widget.station.isHome) {
                  ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                            'Du har valt ${widget.station.title} som hemstation'),
                      ),
                    );
                  setState(() {
                    saveUserHome(widget.station.id);
                    widget.station.isHome = true;
                  });
                }
              } catch (e) {}
            },
            icon: Icon(
              widget.station.isHome ? Icons.home : Icons.home_outlined,
              color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
            ),
            label: Text(
              'Hemstation',
              style: TextStyle(
                color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
