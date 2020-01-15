// Custom class for the post results
class Post {
  String title;
  String id;
  String temperature;
  String distance;
  String amm;
  String lastUpdate;
  String municipality;
  String county;
  String sourceInfo;
  String sourceUrl;

  // Set up default values
  Post({
    this.title = " ", 
    this.id = " ",
    this.temperature = "N/A", 
    this.distance = " ",
    this.amm = " ",
    this.lastUpdate = " ",
    this.municipality = " ",
    this.county = " ",
    this.sourceInfo = " ",
    this.sourceUrl = "https://www.temperatur.nu",
  });

  // Input in form of XmlDocument
  factory Post.fromXml(content) {
      var locationTitle = content.findAllElements("item").map((node) => node.findElements("title").single.text);
      var locationId = content.findAllElements("item").map((node) => node.findElements("id").single.text);
      var currentTemp = content.findAllElements("item").map((node) => node.findElements("temp").single.text);
      var lastUpdated = content.findAllElements("item").map((node) => node.findElements("lastUpdate").single.text);
      var municipality = content.findAllElements("item").map((node) => node.findElements("kommun").single.text);
      var county = content.findAllElements("item").map((node) => node.findElements("lan").single.text);
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
      title: locationTitle.single.trim().toString(),
      id: locationId.single.trim().toString(),
      temperature: currentTemp.single.toString(),
      amm: "min " + minTemp.single.toString() + "°C ◦ medel " + averageTemp.single.toString() + "°C ◦ max " + maxTemp.single.toString() + "°C",
      lastUpdate: lastUpdated.single.toString(),
      municipality: municipality.single.toString(),
      county: county.single.toString(),
      sourceInfo: sourceInfo.single.toString(),
      sourceUrl: sourceUrl.single.toString(),
    );
  }
}