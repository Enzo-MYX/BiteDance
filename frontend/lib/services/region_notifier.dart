import 'package:flutter/material.dart';
import '../models/region.dart';

class RegionNotifier extends ChangeNotifier {
  static final RegionNotifier instance = RegionNotifier();
  List<Region> _watch_regions = [];
  bool _rtlEnabled = false;
  double _maxDistance = 0.0;

  List<Region> get regions => _watch_regions;
  bool get rtlEnabled => _rtlEnabled;
  double get maxDistance => _maxDistance;

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

  void updateRadius(int index, double newRadius) {
    if (index < 0 || index >= _watch_regions.length) return;
    final old = _watch_regions[index];
    _watch_regions[index] = old.copyWith(radius: newRadius); // Immutable design for the regions
    notifyListeners();
  }

  void clearRegions() {
    _watch_regions.clear();
    notifyListeners();
  }

  void setRegions(List<Region> newRegions) {
    _watch_regions = newRegions;
    notifyListeners();
  }

  void setRTLEnabled(bool value) {
    if (_rtlEnabled != value) {
      _rtlEnabled = value;
      notifyListeners();
    }
  }

  void setMaxDistance(double value) {
    if (_maxDistance != value) {
      _maxDistance = value;
      notifyListeners();
    }
  }
}