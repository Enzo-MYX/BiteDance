import 'package:flutter/material.dart';
import '../models/region.dart';

class RegionNotifier extends ChangeNotifier {
  static final RegionNotifier instance = RegionNotifier();
  List<Region> _watch_regions = [];

  List<Region> get regions => _watch_regions;

  void addRegion(Region region) {
    _watch_regions.add(region);
    notifyListeners();
  }

  void removeRegionAt(int index) {
    if (index >= 0 && index < _watch_regions.length) {
      _watch_regions.removeAt(index);
      notifyListeners();
    }
  }

  void clearRegions() {
    _watch_regions.clear();
    notifyListeners();
  }

  void setRegions(List<Region> newRegions) {
    _watch_regions = newRegions;
    notifyListeners();
  }
}