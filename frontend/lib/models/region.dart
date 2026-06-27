class Region {
  final double lat;
  final double lon;
  final double radius; // notated in meters
  final String? name;
  final bool isPreset;

  Region({
    required this.lat,
    required this.lon,
    required this.radius,
    this.name,
    required this.isPreset,
  });

  Region copyWith({double? radius}) {
    return Region(lat: lat, lon: lon, radius: radius ?? this.radius, name: this.name, isPreset: isPreset);
  }
}