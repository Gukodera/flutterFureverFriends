import 'package:flutter/foundation.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final List<Map<String, dynamic>> _favorites = [];

  List<Map<String, dynamic>> get favorites => _favorites;

  void toggleFavorite(Map<String, dynamic> pet) {
    final index = _favorites.indexWhere((p) => p['name'] == pet['name']);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(pet);
    }
    notifyListeners();
  }

  bool isFavorite(Map<String, dynamic> pet) {
    return _favorites.any((p) => p['name'] == pet['name']);
  }
}
