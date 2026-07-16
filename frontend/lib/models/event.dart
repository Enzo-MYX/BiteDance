import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class Event {
    final int id;
    final int hash;
    final String uploader;
    final DateTime time;
    final String txt;
    final String location;
    final double lat;
    final double lon;
    final List<String> mediaUrls;

    Event({
        required this.id,
        required this.hash,
        required this.uploader,
        required this.time,
        required this.txt,
        required this.location,
        required this.lat,
        required this.lon,
        this.mediaUrls = const [],
    });

    factory Event.fromJson(Map<String, dynamic> json) {
        final int seconds = json['time'] as int;
        final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

        return Event(
            id: json['id'] as int,
            hash: json['hash'] as int,
            uploader: json['uploader'] as String,
            time: dateTime,
            txt: json['txt'] as String,
            location: json['location'] as String,
            lat: (json['lat'] as num).toDouble(),
            lon: (json['lon'] as num).toDouble(),
            mediaUrls: (json['mediaUrls'] as List?)?.map((e) => e.toString()).toList() ?? [],
        );
    }

    double distanceFrom(double lat, double lon) {
        return Geolocator.distanceBetween(this.lat, this.lon, lat, lon);
    }

    @override
    String toString() =>
        'Event(Code: $hash, userName: $uploader, location: $location, lat: $lat, lon: $lon, mediaUrls: ${mediaUrls.length})';
}