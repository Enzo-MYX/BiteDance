import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/events_loader.dart';
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

  @override
  void initState() {
    super.initState();
    _futureEvents = EventLoader.loadEvents();
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
          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final isFav = _favoriteIds.contains(event.id);
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
                          Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.image,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),

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
                            children: const [
                              Icon(Icons.person, size: 16),
                              SizedBox(width: 4),
                              Text("User"),
                            ],
                          ),

                          const SizedBox(height: 4),

                          Row(
                            children: const [
                              Icon(Icons.location_on, size: 16),
                              SizedBox(width: 4),
                              Text("Distance"),
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