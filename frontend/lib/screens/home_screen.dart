import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/events_loader.dart';
import '../services/location.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _futureEvents;
  Set<int> _favoriteIds = {};

  // GPS related variables
  final Location _locationService = Location();
  double _currentLat = 0.0;
  double _currentLon = 0.0;
  String _locationStatus = 'Initializing...';  // for feedback

  @override
  void initState() {
    super.initState();
    _futureEvents = EventLoader.loadEvents();
    _initLocation();
  }

  Future<void> _initLocation() async {
    final hasPermission = await _locationService.requestPermission();
    if (!hasPermission) {
      setState(() {
        _locationStatus = 'Location permission denied';
      });
      return;
    }

    setState(() {
      _locationStatus = 'Waiting for location...';
    });

    _locationService.startLocationUpdates(
      onLocationUpdate: (lat, lon) {
        setState(() {
          _currentLat = lat;
          _currentLon = lon;
          _locationStatus = 'GPS active';
        });
      },
    );
  }

  void _toggleFavorite(int eventId) {
    setState(() {
      if (_favoriteIds.contains(eventId)) {
        _favoriteIds.remove(eventId);
      } else {
        _favoriteIds.add(eventId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  _locationStatus == '📍 GPS active'
                      ? '${_currentLat.toStringAsFixed(4)}, ${_currentLon.toStringAsFixed(4)}'
                      : _locationStatus,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.gps_fixed, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locationStatus,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentLat == 0.0 && _currentLon == 0.0
                            ? 'Waiting for coordinates...'
                            : 'Lat: $_currentLat, Lon: $_currentLon',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: _futureEvents,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events found'));
                }
                final events = snapshot.data!;
                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    final isFav = _favoriteIds.contains(event.id);
                    return ListTile(
                      leading: IconButton(
                        icon: Icon(
                          isFav ? Icons.star : Icons.star_border,
                          color: isFav ? Colors.amber : Colors.grey,
                        ),
                        onPressed: () => _toggleFavorite(event.id),
                      ),
                      title: Text(event.location),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(event: event),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}