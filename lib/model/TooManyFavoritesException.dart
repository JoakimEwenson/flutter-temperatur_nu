import 'package:temperatur_nu/controller/common.dart';

class TooManyFavoritesException implements Exception {
  String errorMsg() {
    return 'För många favoriter sparade, max antal är $maxFavorites.';
  }
}
