import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../services/events_loader.dart';

class NetworkEventLoader {
  static const String baseUrl = 'http://3.27.216.9:8080'; // Android emulator

  static Future<List<Event>> fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events')).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((json) => Event.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load events: ${response.statusCode}');
      }
    } catch (e) {
      return await EventLoader.loadEvents();
    }
  }
}