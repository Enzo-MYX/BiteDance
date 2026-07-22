import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/region.dart';
import 'region_notifier.dart';
import 'filter_notifier.dart';

class SettingsSaver {
  static Future<void> saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final regionsJson = RegionNotifier.instance.regions.map((r) => r.toJson()).toList();
    await prefs.setString('regions', jsonEncode(regionsJson));
    await prefs.setBool('rtlEnabled', RegionNotifier.instance.rtlEnabled);
    await prefs.setDouble('maxDistance', RegionNotifier.instance.maxDistance);

    final filter = FilterNotifier.instance;
    final filterMap = {
      'onlyFavorites': filter.onlyFavorites,
      'onlyWatched': filter.onlyWatched,
      'expireTime': filter.expireTime,
      'timeSelection': filter.timeSelection,
      'customNumber': filter.customNumber,
      'customUnit': filter.customUnit,
      'orderBy': filter.orderBy,
      'reverse': filter.reverse,
    };
    await prefs.setString('filter', jsonEncode(filterMap));
  }

  static Future<void> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final regionsJson = prefs.getString('regions');
    if (regionsJson != null) {
      final List<dynamic> list = jsonDecode(regionsJson);
      final regions = list.map((e) => Region.fromJson(e as Map<String, dynamic>)).toList();
      RegionNotifier.instance.setRegions(regions);
    }
    final rtl = prefs.getBool('rtlEnabled');
    if (rtl != null) RegionNotifier.instance.setRTLEnabled(rtl);
    final maxDist = prefs.getDouble('maxDistance');
    if (maxDist != null) RegionNotifier.instance.setMaxDistance(maxDist);

    final filterJson = prefs.getString('filter');
    if (filterJson != null) {
      final filterMap = jsonDecode(filterJson) as Map<String, dynamic>;
      final filter = FilterNotifier.instance;
      filter.onlyFavorites = filterMap['onlyFavorites'] ?? false;
      filter.onlyWatched = filterMap['onlyWatched'] ?? false;
      filter.expireTime = (filterMap['expireTime'] as num?)?.toDouble() ?? 5400.0;
      filter.timeSelection = filterMap['timeSelection'] ?? '1.5h';
      filter.customNumber = (filterMap['customNumber'] as num?)?.toDouble() ?? 90.0;
      filter.customUnit = filterMap['customUnit'] ?? 'minutes';
      filter.orderBy = filterMap['orderBy'] ?? 'none';
      filter.reverse = filterMap['reverse'] ?? false;
      filter.notifyListeners(); // trigger UI updates
    }
  }
}