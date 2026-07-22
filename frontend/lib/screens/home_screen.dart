import 'dart:math';

import 'package:bitedance/screens/filter_screen.dart';
import 'package:bitedance/services/filter_notifier.dart';
import 'package:bitedance/services/notification_service.dart';
import 'package:bitedance/services/region_notifier.dart';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/network_events_loader.dart';
import '../services/location.dart';
import 'dart:async';
import 'detail_screen.dart';
import 'notification_screen.dart';//transition into notification setting page

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Event>> _futureEvents;
  Set<int> _favoriteIds = {};
  late RegionNotifier _regionNotifier;
  late FilterNotifier _filterNotifier;

  final Location _locationService = Location();
  double _currentLat = 0.0;
  double _currentLon = 0.0;
  bool _isFirstLoad = true;
  Set<int> _previousIds = {};
  String _locationStatus = 'Initializing...';//not utilized for now

  @override
  void initState() {
    super.initState();
    _futureEvents = NetworkEventLoader.fetchEvents();
    _initLocation();
    _regionNotifier = RegionNotifier.instance;
    _regionNotifier.addListener(_onRegionChanged);
    _filterNotifier = FilterNotifier.instance;
    _filterNotifier.addListener(_onFilterChanged);
    // Auto-refresh every 30 seconds
    _startAutoRefresh();
  }

  void _loadEvents() async {
    final newEvents = await NetworkEventLoader.fetchEvents();
    setState(() {
      _futureEvents = NetworkEventLoader.fetchEvents();
    });
    _checkForNewEvents(newEvents);
  }

  void _checkForNewEvents(List<Event> newEvents) {
    final ids = newEvents.map((e) => e.hash).toSet();
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _previousIds = ids;
      return;
    }
    final newIds = ids.difference(_previousIds);
    if (newIds.isNotEmpty) {
      for (final id in newIds) {
        final event = newEvents.firstWhere((e) => e.hash == id);
        if (_isEventInRegion(event)) {_showNotifForEvent(event);}
        _previousIds.add(id);
      }
    }
  }

  void _showNotifForEvent(Event event) {
    NotificationService.showNotification(
        id: event.id,
        title: 'New buffet in ${event.location}!',
        body: event.txt.length > 50
            ? (event.txt.substring(0, 50) + '...')
            : event.txt
    );
  }

  Timer? _refreshTimer;
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadEvents();
      }
    });
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

  void _onFilterChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _regionNotifier.removeListener(_onRegionChanged);
    _filterNotifier.removeListener(_onFilterChanged);
    super.dispose();
  }

  bool _isEventInRegion(Event event) {
    final regions = _regionNotifier.regions;
    for (final region in regions) {
      double dist = event.distanceFrom(region.lat, region.lon);
      if (dist <= region.radius) return true;
    }
    return _isEventNearMe(event);
  }

  bool _isEventNearMe(Event event) {
    if (!_regionNotifier.rtlEnabled) return false;
    if (_currentLat == 0.0 && _currentLon == 0.0) return false;
    double distance = event.distanceFrom(_currentLat, _currentLon);
    return distance <= _regionNotifier.maxDistance;
  }

  List<Event> _applyFiltersAndOrder(List<Event> events) {
    var filtered = List<Event>.from(events);

    if (_filterNotifier.onlyFavorites) {
      filtered = filtered.where((e) => _favoriteIds.contains(e.id)).toList();
    }
    if (_filterNotifier.onlyWatched) {
      filtered = filtered.where((e) => _isEventInRegion(e)).toList();
    }

    final now = DateTime.now();
    filtered = filtered.where((e) {
      final diff = now.difference(e.time).inSeconds + 28800;
      return diff <= _filterNotifier.expireTime && diff >= 0;
    }).toList();

    switch (_filterNotifier.orderBy) {
      case 'distance':
        filtered.sort((a, b) => a.distanceFrom(_currentLat, _currentLon)
            .compareTo(b.distanceFrom(_currentLat, _currentLon)));
        break;
      case 'time':
        filtered.sort((a, b) => b.time.compareTo(a.time));
        break;
      default:
        break;
    }
    if (_filterNotifier.reverse && _filterNotifier.orderBy != 'none') {
      filtered = filtered.reversed.toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'filter',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterOrderScreen())),
            child: const Icon(Icons.filter_list),
          ),
          const SizedBox(width: 16),
          FloatingActionButton(
            heroTag: 'settings',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FilterNotificationScreen())),
            child: const Icon(Icons.tune),
          ),
        ],
      ),//add floating action button on homescreen, transition to notification screen
      appBar: AppBar(
        title: const Text('Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvents,
          ),
        ],
      ),
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
          final filteredEvents = _applyFiltersAndOrder(events); // Filter system now implemented
          if (filteredEvents.isEmpty) {
            if (events.isNotEmpty) {
              return const Center(child: Text('No events match your filters.'));
            } else {
              return const Center(child: Text('No events present.'));
            }
          }
          return RefreshIndicator(
            onRefresh: () async {
              _loadEvents();
              await _futureEvents;
            },
            child: ListView.builder(
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                final event = filteredEvents[index];
                final isFav = _favoriteIds.contains(event.id);
                String distanceText = '...';
                if (_currentLat != 0.0 || _currentLon != 0.0) {
                  double dist = event.distanceFrom(_currentLat, _currentLon);
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
                                  ? Image.network(
                                'http://10.0.2.2:8080${event.mediaUrls.first}',
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
            ),
          );
        },
      ),
    );
  }
}