import 'package:xml/xml.dart' as xml;

// Custom class for the post results
class Post {
  String title;
  String id;
  String temperature;
  String amm;
  String lastUpdate;
  String sourceInfo;
  String sourceUrl;

  Post({
    this.title, 
    this.id,
    this.temperature, 
    this.amm,
    this.lastUpdate,
    this.sourceInfo,
    this.sourceUrl
  });

  // Parsing XML return from API
  factory Post.fromXml(String body) {
    // Parse API result as XML
    var content = xml.parse(body);
    // Locate and bind data
    var locationTitle = content.findAllElements("item").map((node) => node.findElements("title").single.text);
    var locationId = content.findAllElements("item").map((node) => node.findElements("id").single.text);
    var currentTemp = content.findAllElements("item").map((node) => node.findElements("temp").single.text);
    var lastUpdated = content.findAllElements("item").map((node) => node.findElements("lastUpdate").single.text);
    var sourceInfo = content.findAllElements("item").map((node) => node.findElements("sourceInfo").single.text);
    var sourceUrl = content.findAllElements("item").map((node) => node.findElements("url").single.text);
    // Average, min, max data
    var averageTemp = content.findAllElements("item").map((node) => node.findElements("average").single.text);
    var minTemp = content.findAllElements("item").map((node) => node.findElements("min").single.text);
    var maxTemp = content.findAllElements("item").map((node) => node.findElements("max").single.text);
    // Currently not used but available data
    // var minTime = content.findAllElements("item").map((node) => node.findElements("minTime").single.text);
    // var maxTime = content.findAllElements("item").map((node) => node.findElements("maxTime").single.text);

    return Post(
      title: locationTitle.single.toString(), 
      id: locationId.single.toString(),
      temperature: currentTemp.single.toString() + "°C", 
      amm: "min " + minTemp.single.toString() + "°C ● medel " + averageTemp.single.toString() + "°C ● max " + maxTemp.single.toString() + "°C",
      lastUpdate: "Temperaturen rapporterad: " + lastUpdated.single.toString(),
      sourceInfo: sourceInfo.single.toString(),
      sourceUrl: sourceUrl.single.toString()
    );
  }
}