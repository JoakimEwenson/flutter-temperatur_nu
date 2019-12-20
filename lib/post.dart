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
    this.sourceUrl = "https://www.temperatur.nu"
  });
}