class StationName {
  StationName({
    this.title,
    this.id,
    this.temp,
    this.lat,
    this.lon,
    this.lastUpdate,
    this.kommun,
    this.lan,
    this.sourceInfo,
    this.forutsattning,
    this.uptime,
    this.start,
    this.moh,
    this.url = "https://www.temperatur.nu",
    this.ammRange,
    this.average,
    this.min,
    this.minTime,
    this.max,
    this.maxTime,
  });

  String title;
  String id;
  double temp;
  String lat;
  String lon;
  String lastUpdate;
  String kommun;
  String lan;
  String sourceInfo;
  String forutsattning;
  String uptime;
  String start;
  String moh;
  String url;
  String ammRange;
  double average;
  double min;
  String minTime;
  double max;
  String maxTime;

  factory StationName.fromRawJson(var json) {
    return StationName(
      title: json["title"],
      id: json["id"],
      temp: json["temp"] != null ? double.tryParse(json["temp"]) : null,
      lat: json["lat"],
      lon: json["lon"],
      lastUpdate: json["lastUpdate"],
      kommun: json["kommun"],
      lan: json["lan"],
      sourceInfo: json["sourceInfo"],
      forutsattning: json["forutsattning"],
      uptime: json["uptime"],
      start: json["start"],
      moh: json["moh"],
      url: json["url"],
      ammRange: json["ammRange"],
      average:
          json["average"] != null ? double.tryParse(json["average"]) : null,
      min: json["min"] != null ? double.tryParse(json["min"]) : null,
      minTime: json["minTime"],
      max: json["max"] != null ? double.tryParse(json["max"]) : null,
      maxTime: json["maxTime"],
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "id": id,
        "temp": temp,
        "lat": lat,
        "lon": lon,
        "lastUpdate": lastUpdate,
        "kommun": kommun,
        "lan": lan,
        "sourceInfo": sourceInfo,
        "forutsattning": forutsattning,
        "uptime": uptime,
        "start": start,
        "moh": moh,
        "url": url,
        "ammRange": ammRange,
        "average": average,
        "min": min,
        "minTime": minTime,
        "max": max,
        "maxTime": maxTime,
      };
}

List<StationName> stationNameList(var json) {
  List<StationName> output = [];
  for (var row in json["stations"].values) {
    output.add(StationName.fromRawJson(row));
  }

  return output;
}
