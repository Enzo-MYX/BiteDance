import 'package:flutter/material.dart';
import 'settings_saver.dart';

class FilterNotifier extends ChangeNotifier {
  static final FilterNotifier instance = FilterNotifier();

  // ---- Filter flags ----
  bool onlyFavorites = false;
  bool onlyWatched = false;
  double expireTime = 5400;
  String timeSelection = '1.5h';
  double customNumber = 90;
  String customUnit = 'minutes';
  String orderBy = 'none';
  bool reverse = false;

  void toggleFilterByFavs() {
    onlyFavorites = !onlyFavorites;
    notifyListeners();
    SettingsSaver.saveAll();
  }

  void toggleOnlyWatched() {
    onlyWatched = !onlyWatched;
    notifyListeners();
    SettingsSaver.saveAll();
  }

  void toggleSortByDistance() {
    orderBy = orderBy == 'distance' ? 'none' : 'distance';
    notifyListeners();
    SettingsSaver.saveAll();
  }

  void toggleSortByTime() {
    orderBy = orderBy == 'time' ? 'none' : 'time';
    notifyListeners();
    SettingsSaver.saveAll();
  }

  void setExpireTime(double value) {
    expireTime = value;
    notifyListeners();
    SettingsSaver.saveAll();
  }

  void setTimeSelect(String mode, {double? number, String? unit}) {
    timeSelection = mode;
    if (timeSelection == 'custom') {
      if (number != null) customNumber = number;
      if (unit != null) customUnit = unit;
    }
    notifyListeners();
    SettingsSaver.saveAll();
  }

  void toggleRev() {
    reverse = !reverse;
    notifyListeners();
    SettingsSaver.saveAll();
  }

  void resetFilters() {
    onlyFavorites = false;
    onlyWatched = false;
    expireTime = 5400;
    timeSelection = '1.5h';
    customNumber = 90;
    customUnit = 'minutes';
    orderBy = 'none';
    reverse = false;
    notifyListeners();
    SettingsSaver.saveAll();
  }
}