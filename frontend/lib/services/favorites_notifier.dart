import 'package:flutter/material.dart';
import 'settings_saver.dart';

class FavoritesNotifier extends ChangeNotifier {
  static final FavoritesNotifier instance = FavoritesNotifier();
  Set<int> _favorites = {};
  Set<int> get favorites => _favorites;
  bool isFavorite(int id) => _favorites.contains(id);

  void toggleFavorite(int id) {
    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }
    notifyListeners();
    SettingsSaver.saveAll();
  }

  void setFavorites(Set<int> newFavorites) {
    _favorites = newFavorites;
    notifyListeners();
  }
}