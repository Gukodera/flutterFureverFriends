import 'package:flutter/foundation.dart';
import 'firebase_service.dart';

class FavoritesManager extends ChangeNotifier {
  static final FavoritesManager _instance = FavoritesManager._internal();
  factory FavoritesManager() => _instance;
  FavoritesManager._internal();

  final List<Map<String, dynamic>> _favorites = [];
  final firebaseService = FirebaseService();

  List<Map<String, dynamic>> get favorites => _favorites;

  Future<void> toggleFavorite(Map<String, dynamic> pet) async {
    final index = _favorites.indexWhere((p) => p['name'] == pet['name']);
    if (index >= 0) {
      _favorites.removeAt(index);
      // Remove from Firebase
      try {
        await firebaseService.removeFromFavorites(pet['id'] ?? pet['name']);
      } catch (e) {
        debugPrint('Error removing favorite: $e');
      }
    } else {
      _favorites.add(pet);
      // Add to Firebase
      try {
        await firebaseService.addToFavorites(pet['id'] ?? pet['name']);
      } catch (e) {
        debugPrint('Error adding favorite: $e');
      }
    }
    notifyListeners();
  }

  bool isFavorite(Map<String, dynamic> pet) {
    return _favorites.any((p) => p['name'] == pet['name']);
  }

  // Load favorites from Firebase
  Future<void> loadFavorites() async {
    try {
      final favoritePetIds = await firebaseService.getFavoritePetIds();
      // You can load full pet data here if needed
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }
  }
}
