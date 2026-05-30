import 'package:geolocator/geolocator.dart';

class Location {
  double _currentLat = 0.0;
  double _currentLon = 0.0;

  double get currentLat => _currentLat;
  double get currentLon => _currentLon;

  Future<bool> requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return false;
    }
    return true;
  }

  void startLocationUpdates({
    required Function(double lat, double lon) onLocationUpdate,
    LocationSettings? settings,
  }) {
    final locSettings = settings ??
        LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100, // update when moved 100 meters
          timeLimit: const Duration(seconds: 10), // or force update every 10s
        ); // both update frequency manipulators are very subject to change, depending on battery drainage <—> accuracy

    Geolocator.getPositionStream(locationSettings: locSettings).listen(
          (Position position) {
        _currentLat = position.latitude;
        _currentLon = position.longitude;
        onLocationUpdate(_currentLat, _currentLon);
      },
    );
  }
}