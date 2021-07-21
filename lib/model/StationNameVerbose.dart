// To parse this JSON data, do
//
//     final stationNameVerbose = stationNameVerboseFromJson(jsonString);

import 'dart:convert';

StationNameVerbose stationNameVerboseFromJson(String str) =>
    StationNameVerbose.fromJson(json.decode(str));

String stationNameVerboseToJson(StationNameVerbose data) =>
    json.encode(data.toJson());

class StationNameVerbose {
  StationNameVerbose({
    this.title,
    this.client,
    this.stations,
  });

  String title;
  String client;
  List<Station> stations;

  factory StationNameVerbose.fromJson(Map<String, dynamic> json) =>
      StationNameVerbose(
        title: json["title"],
        client: json["client"],
        stations: List<Station>.from(
            json["stations"].map((x) => Station.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "client": client,
        "stations": List<dynamic>.from(stations.map((x) => x.toJson())),
      };
}

class Station {
  Station({
    this.title,
    this.id,
    this.isFavorite,
    this.isHome,
    this.temp,
    this.lat,
    this.lon,
    this.kommun,
    this.lastUpdate,
    this.lan,
    this.sourceInfo,
    this.forutsattning,
    this.uptime,
    this.felmeddelande,
    this.start,
    this.moh,
    this.url,
    this.dist,
    this.amm,
    this.data,
  });

  String title;
  String id;
  bool isFavorite;
  bool isHome;
  double temp;
  String lat;
  String lon;
  String kommun;
  DateTime lastUpdate;
  String lan;
  String sourceInfo;
  String forutsattning;
  int uptime;
  String felmeddelande;
  DateTime start;
  int moh;
  String url;
  double dist;
  Amm amm;
  List<DataPost> data;

  factory Station.fromJson(Map<String, dynamic> json) => Station(
        title: json["title"],
        id: json["id"],
        isFavorite: null,
        temp: json["temp"] != null ? double.tryParse(json["temp"]) : null,
        lat: json["lat"],
        lon: json["lon"],
        kommun: json["kommun"],
        lastUpdate: json["lastUpdate"] != null
            ? DateTime.parse(json["lastUpdate"])
            : null,
        lan: json["lan"],
        sourceInfo: json["sourceInfo"],
        forutsattning: json["forutsattning"],
        uptime: json["uptime"],
        felmeddelande: json["felmeddelande"],
        start: json["start"] != null ? DateTime.parse(json["start"]) : null,
        moh: json["moh"],
        url: json["url"],
        dist: json["dist"] != null ? double.tryParse(json["dist"]) : null,
        amm: json["amm"] != null ? Amm.fromJson(json["amm"]) : null,
        data: json["data"] != null
            ? List<DataPost>.from(json["data"].map((x) => DataPost.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "id": id,
        "temp": temp,
        "lat": lat,
        "lon": lon,
        "kommun": kommun,
        "lastUpdate": lastUpdate.toIso8601String(),
        "lan": lan,
        "sourceInfo": sourceInfo,
        "forutsattning": forutsattning,
        "uptime": uptime,
        "felmeddelande": felmeddelande,
        "start": start.toIso8601String(),
        "moh": moh,
        "url": url,
        "amm": amm.toJson(),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class Amm {
  Amm({
    this.ammRange,
    this.average,
    this.min,
    this.minTime,
    this.max,
    this.maxTime,
  });

  String ammRange;
  double average;
  double min;
  String minTime;
  double max;
  String maxTime;

  factory Amm.fromJson(Map<String, dynamic> json) {
    if (json.containsKey("minTime") && json.containsKey("maxTime")) {
      return Amm(
        ammRange: json["ammRange"],
        average:
            json["average"] != null ? double.tryParse(json["average"]) : null,
        min: json["min"] != null ? double.tryParse(json["min"]) : null,
        minTime: json["minTime"] != null ? json["minTime"] : null,
        max: json["max"] != null ? double.tryParse(json["max"]) : null,
        maxTime: json["maxTime"] != null ? json["maxTime"] : null,
      );
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
        "ammRange": ammRange,
        "average": average,
        "min": min,
        "minTime": minTime,
        "max": max,
        "maxTime": maxTime,
      };
}

class DataPost {
  DataPost({
    this.datetime,
    this.temperatur,
  });

  String datetime;
  String temperatur;

  factory DataPost.fromJson(Map<String, dynamic> json) => DataPost(
        datetime: json["datetime"],
        temperatur: json["temperatur"],
      );

  Map<String, dynamic> toJson() => {
        "datetime": datetime,
        "temperatur": temperatur,
      };
}
