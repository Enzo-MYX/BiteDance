import 'package:bitedance/services/region_notifier.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event.dart';
import '../services/events_loader.dart';
import '../services/location.dart';
import 'detail_screen.dart';
import 'filter_notification_screen.dart';//transition into notification setting page

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _futureEvents;
  Set<int> _favoriteIds = {};
  late RegionNotifier _regionNotifier;

  final Location _locationService = Location();
  double _currentLat = 0.0;
  double _currentLon = 0.0;
  String _locationStatus = 'Initializing...';//not utilized for now

  @override
  void initState() {
    super.initState();
    _futureEvents = EventLoader.loadEvents();
    _initLocation();
    _regionNotifier = RegionNotifier.instance;
    _regionNotifier.addListener(_onRegionChanged);
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

  void _onRegionChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _regionNotifier.removeListener(_onRegionChanged);
    super.dispose();
  }

  bool _isEventInRegion(Event event) {
    final regions = _regionNotifier.regions;
    if (regions.isEmpty) return true;
    for (final region in regions) {
      double dist = Geolocator.distanceBetween(event.lat, event.lon, region.lat, region.lon);
      if (dist <= region.radius) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.tune),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const FilterNotificationScreen(),
            ),
          );
        },
      ),//add floating action button on homescreen, transition to notification screen
      appBar: AppBar(title: const Text('Events')),
      body: FutureBuilder<List<Event>>(
        future: _futureEvents,
        builder: (context, snapshot) {
          // Show loading spinner while waiting
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show error message if something went wrong
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // If no data or empty list
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No events found'));
          }
          // Data is ready – build the list
          final events = snapshot.data!;
          final filteredEvents = events.where((event) {
            return _isEventInRegion(event);
          }).toList();
          if (filteredEvents.isEmpty) {
            return const Center(child: Text('No events match your filters'));
          }
          return ListView.builder(
            itemCount: filteredEvents.length,
            itemBuilder: (context, index) {
              final event = filteredEvents[index];
              final isFav = _favoriteIds.contains(event.id);
              String distanceText = '...';
              if (_currentLat != 0.0 || _currentLon != 0.0) {
                double dist = Geolocator.distanceBetween(
                  _currentLat,
                  _currentLon,
                  event.lat,
                  event.lon,
                );
                distanceText = dist < 1000
                    ? '${dist.toStringAsFixed(0)} m'
                    : '${(dist / 1000).toStringAsFixed(1)} km';
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(event: event),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: event.mediaUrls.isNotEmpty
                                ? Image.asset(
                              'assets/images/${event.mediaUrls.first.split('/').last}',
                              width: 90,
                              height: 90,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 90,
                                height: 90,
                                color: Colors.grey.shade300,
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 40,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                                : Container(
                              width: 90,
                              height: 90,
                              color: Colors.grey.shade300,
                              child: const Icon(
                                Icons.image,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),//fits and crops image at center, uses grey default if no image or error

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.location,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                const Text(
                                  "Buffet Event",
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),

                                const SizedBox(height: 12),

                                Row(
                                  children: [
                                    const Icon(Icons.person, size: 16),
                                    const SizedBox(width: 4),
                                    Text("User: ${event.uploader}"),
                                  ],
                                ),

                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16),
                                    const SizedBox(width: 4),
                                    Text("Distance: $distanceText"),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            icon: Icon(
                              isFav
                                  ? Icons.star
                                  : Icons.star_border,
                              color: isFav
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                            onPressed: () =>
                                _toggleFavorite(event.id),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );

            },
          );
        },
      ),
    );
  }
}