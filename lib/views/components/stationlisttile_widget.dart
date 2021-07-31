import 'package:flutter/material.dart';
import 'package:temperatur_nu/controller/favorites.dart';
import 'package:temperatur_nu/model/LocationArguments.dart';
import 'package:temperatur_nu/model/StationNameVerbose.dart';
import 'package:temperatur_nu/views/components/theme.dart';

class StationListTile extends StatefulWidget {
  const StationListTile({
    Key key,
    @required this.station,
  }) : super(key: key);

  final Station station;

  @override
  _StationListTileState createState() => _StationListTileState();
}

class _StationListTileState extends State<StationListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      isThreeLine: false,
      visualDensity: VisualDensity.compact,
      leading: IconButton(
        visualDensity: VisualDensity.compact,
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
                  behavior: SnackBarBehavior.floating,
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
        widget.station.title,
        style: locationListTileTitle,
      ),
      subtitle: Text(
        "Avstånd ${widget.station.dist} km\n${widget.station.kommun}",
        style: locationListTileSubtitle,
      ),
      trailing: widget.station.temp != null
          ? Text(
              "${widget.station.temp}°",
              style: locationListTileTemperature,
            )
          : Text(
              '$noTempDataString',
              style: locationListTileTemperature,
            ),
      onTap: () {
        //saveLocationId(station.id);
        Navigator.pushNamed(context, '/SingleStation',
            arguments: LocationArguments(widget.station.id));
      },
    );
  }
}
