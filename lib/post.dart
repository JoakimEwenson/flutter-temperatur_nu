// Custom class for the post results
class Post {
  String title;
  String id;
  String temperature;
  String amm;
  String lastUpdate;
  String municipality;
  String county;
  String sourceInfo;
  String sourceUrl;

  Post({
    this.title, 
    this.id,
    this.temperature, 
    this.amm,
    this.lastUpdate,
    this.municipality,
    this.county,
    this.sourceInfo,
    this.sourceUrl
  });
}