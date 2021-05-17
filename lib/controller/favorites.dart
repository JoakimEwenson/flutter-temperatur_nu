// Fetch saved favorites from local storage
import 'package:shared_preferences/shared_preferences.dart';
import 'package:temperatur_nu/controller/timestamps.dart';

Future<List> fetchLocalFavorites() async {
  var sp = await SharedPreferences.getInstance();
  var favorites = sp.getString('favorites') ?? "";
  var favList = [];
  if ((favorites != "") || (favorites != null)) {
    favList = favorites.split(',');
  }

  return favList;
}

// Save favorites to local storage
saveLocalFavorites(List favorites) async {
  String favoritesString = favorites.join(',');
  var sp = await SharedPreferences.getInstance();
  sp.setString('favorites', favoritesString);
}

// Add location id to local stored favorites
Future<bool> addToFavorites(String locationId) async {
  var favList = await fetchLocalFavorites();
  favList = await cleanupFavoritesList(favList);

  if (!(await existsInFavorites(locationId))) {
    favList.add(locationId);
    saveLocalFavorites(favList.toSet().toList());
    removeTimeStamp('favoritesListTimeout');
    return true;
  } else {
    //throw Exception('För många favoriter sparade, max antal är enligt konstant maxFavorites.');
    throw Exception('Platsen $locationId finns redan i dina favoriter.');
    //return false;
  }
}

Future<bool> existsInFavorites(String locationId) async {
  var favList = await fetchLocalFavorites();
  favList = await cleanupFavoritesList(favList);

  return favList.contains(locationId);
}

// Remove location id from local saved favorites
Future<bool> removeFromFavorites(String locationId) async {
  var favList = await fetchLocalFavorites();
  favList = await cleanupFavoritesList(favList);

  if (favList.remove(locationId)) {
    saveLocalFavorites(favList);
    removeTimeStamp('favoritesListTimeout');
    return true;
  } else {
    throw Exception(
        'Kunde inte ta bort $locationId från listan över favoriter.');
    //return false;
  }
}

// Clear empty list result
cleanupFavoritesList(List favorites) async {
  favorites.removeWhere((item) => item == "" || item == null);
  return favorites;
}
