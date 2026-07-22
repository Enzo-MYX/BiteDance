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

  Map<String, dynamic> toJson() => {
    'lat': lat,
    'lon': lon,
    'radius': radius,
    'name': name,
    'isPreset': isPreset,
  };

  factory Region.fromJson(Map<String, dynamic> json) => Region(
    lat: (json['lat'] as num).toDouble(),
    lon: (json['lon'] as num).toDouble(),
    radius: (json['radius'] as num).toDouble(),
    name: json['name'] as String?,
    isPreset: json['isPreset'],
  );

  Region copyWith({
    double? lat,
    double? lon,
    double? radius,
    String? name,
    bool? isPreset,
  }) {
    return Region(
      lat: lat ?? this.lat,
      lon: lon ?? this.lon,
      radius: radius ?? this.radius,
      name: name ?? this.name,
      isPreset: isPreset ?? this.isPreset,
    );
  }
}