import 'package:flutter/foundation.dart';

class Event {
    final int id;
    final int chatId;
    final String uploader;
    final DateTime time;
    final String txt;
    final dynamic vid;     // null for now, can be a Map later
    final dynamic anm;     // null for now
    final dynamic photo;   // null for now
    final String location;
    final double lat;
    final double lon;

    Event({
        required this.id,
        required this.chatId,
        required this.uploader,
        required this.time,
        required this.txt,
        required this.vid,
        required this.anm,
        required this.photo,
        required this.location,
        required this.lat,
        required this.lon,
    });

    factory Event.fromJson(Map<String, dynamic> json) {
        final int seconds = json['time'] as int;
        final dateTime = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

        return Event(
            id: json['id'] as int,
            chatId: json['chatId'] as int,
            uploader: json['uploader'] as String,
            time: dateTime,
            txt: json['txt'] as String,
            vid: json['vid'],
            anm: json['anm'],
            photo: json['photo'],
            location: json['location'] as String,
            lat: (json['lat'] as num).toDouble(),
            lon: (json['lon'] as num).toDouble(),
        );
    }

    @override
    String toString() =>
        'Event(id: $id, location: $location, uploader: $uploader, lat: $lat, lon: $lon)';
}