import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/favorites.dart';
import 'package:temperatur_nu/controller/userHome.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class FavoriteHomeWidget extends StatefulWidget {
  const FavoriteHomeWidget({
    Key key,
    @required this.station,
  }) : super(key: key);

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: widget.station.isFavorite
                ? Icon(
                    Icons.favorite,
                    color: imperialRed,
                    size: 36,
                  )
                : Icon(
                    Icons.favorite_outline,
                    color: _isDarkMode
                        ? darkModeTextColor.withOpacity(0.3)
                        : lightModeTextColor.withOpacity(0.3),
                    size: 36,
                  ),
            onPressed: () async {
              try {
                if (widget.station.isFavorite) {
                  if (await removeFromFavorites(widget.station.id)) {
                    widget.station.isFavorite =
                        await existsInFavorites(widget.station.id);
                    setState(() {
                      widget.station.isFavorite = false;
                    });
                  } else {
                    widget.station.isFavorite =
                        await existsInFavorites(widget.station.id);
                    setState(() {
                      widget.station.isFavorite = false;
                    });
                  }
                } else {
                  if (await addToFavorites(widget.station.id)) {
                    widget.station.isFavorite =
                        await existsInFavorites(widget.station.id);
                    setState(() {
                      widget.station.isFavorite = true;
                    });
                  } else {
                    widget.station.isFavorite =
                        await existsInFavorites(widget.station.id);
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
                      content: Text(
                        '${e.toString()}',
                      ),
                    ),
                  );
              }
            },
          ),
          IconButton(
            icon: widget.station.isHome
                ? Icon(
                    Icons.home,
                    color: _isDarkMode ? tnuYellow : tnuBlue,
                    size: 36,
                  )
                : Icon(
                    Icons.home_outlined,
                    color: _isDarkMode
                        ? darkModeTextColor.withOpacity(0.3)
                        : lightModeTextColor.withOpacity(0.3),
                    size: 36,
                  ),
            onPressed: () async {
              try {
                if (widget.station.isHome) {
                  setState(() {
                    widget.station.isHome = false;
                    removeUserHome();
                  });
                } else if (!widget.station.isHome) {
                  setState(() {
                    saveUserHome(widget.station.id);
                    widget.station.isHome = true;
                  });
                }
              } catch (e) {
                ScaffoldMessenger.of(context)
                  ..removeCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        '${e.toString()}',
                      ),
                    ),
                  );
              }
            },
          ),
        ],
      ),
      /* Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          
          TextButton.icon(
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            icon: widget.station.isFavorite
                ? Icon(
                    Icons.favorite,
                    color: imperialRed,
                    size: 18,
                  )
                : Icon(
                    Icons.favorite_outline,
                    color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
                    size: 18,
                  ),
            label: widget.station.isFavorite
                ? Text(
                    'Favorit',
                    style: TextStyle(
                      color:
                          _isDarkMode ? darkModeTextColor : lightModeTextColor,
                    ),
                  )
                : Text(
                    'Favorit',
                    style: TextStyle(
                      color:
                          _isDarkMode ? darkModeTextColor : lightModeTextColor,
                    ),
                  ),
            onPressed: () async {
              try {
                if (widget.station.isFavorite) {
                  if (await removeFromFavorites(widget.station.id)) {
                    widget.station.isFavorite =
                        await existsInFavorites(widget.station.id);
                    /* ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tog bort ${widget.station.title} från favoriter.',
                          ),
                        ),
                      ); */
                    setState(() {
                      widget.station.isFavorite = false;
                    });
                  } else {
                    widget.station.isFavorite =
                        await existsInFavorites(widget.station.id);
                    /* ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                              'Det gick inte att ta bort ${widget.station.title} från favoriter.'),
                        ),
                      ); */
                    setState(() {
                      widget.station.isFavorite = false;
                    });
                  }
                } else {
                  if (await addToFavorites(widget.station.id)) {
                    widget.station.isFavorite =
                        await existsInFavorites(widget.station.id);
                    /* ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                              'La till ${widget.station.title} i favoriter.'),
                        ),
                      ); */
                    setState(() {
                      widget.station.isFavorite = true;
                    });
                  } else {
                    widget.station.isFavorite =
                        await existsInFavorites(widget.station.id);
                    /* ScaffoldMessenger.of(context)
                      ..removeCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                              'Det gick inte att lägga till ${widget.station.title} i favoriter.'),
                        ),
                      ); */
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
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            icon: widget.station.isHome
                ? Icon(
                    Icons.home,
                    color: _isDarkMode ? tnuYellow : tnuBlue,
                    size: 18,
                  )
                : Icon(
                    Icons.home_outlined,
                    color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
                    size: 18,
                  ),
            label: Text(
              'Hemstation',
              style: TextStyle(
                color: _isDarkMode ? darkModeTextColor : lightModeTextColor,
              ),
            ),
            onPressed: () async {
              try {
                if (widget.station.isHome) {
/*                   ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                            'Du har tagit bort ${widget.station.title} som hemstation'),
                      ),
                    ); */
                  setState(() {
                    widget.station.isHome = false;
                    removeUserHome();
                  });
                } else if (!widget.station.isHome) {
/*                   ScaffoldMessenger.of(context)
                    ..removeCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                            'Du har valt ${widget.station.title} som hemstation'),
                      ),
                    ); */
                  setState(() {
                    saveUserHome(widget.station.id);
                    widget.station.isHome = true;
                  });
                }
              } catch (e) {}
            },
          ),
        ],
      ), */
    );
  }
}
