import 'package:temperatur.nu/model/locationlistitem.dart';

class LocationList {
  List<LocationListItem> locationList;

  LocationList({
    this.locationList,
  });

  // Input in form of XmlDocument
  factory LocationList.fromXml(content) {
    List<LocationListItem> list;
    content.findAllElements('item').forEach((row) {
      var output  = new LocationListItem(
        title: row.findElements('title').single.text.trim().toString(), 
        id: row.findElements('id').single.text.trim().toString(), 
        temperature: row.findElements('temp').single.text.trim().toString()
      );
      list.add(output);
    });

    return null;
  }
}