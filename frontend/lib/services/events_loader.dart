import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/event.dart';

class EventLoader {
    static Future<List<Event>> loadEvents() async {
        final jsonString = await rootBundle.loadString('assets/events.json');
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => Event.fromJson(json)).toList();
    }
}