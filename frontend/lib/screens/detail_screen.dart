import 'package:flutter/material.dart';
import '../models/event.dart';

class DetailScreen extends StatelessWidget {
  final Event event;
  const DetailScreen({super.key, required this.event});

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.location)),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

            Text(
            "${event.location} Buffet",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Uploader: ${event.uploader}",
                      style: TextStyle(fontSize: 16),
                    ),

                    SizedBox(height: 10),

                    Text(
                      "Time: ${_formatDateTime(event.time)}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Telegram Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Card( //card styled, making more user-attractive maybe
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  event.txt,
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Media",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            _buildMediaPlaceholder(
              'Video',
              event.vid,
            ),

            _buildMediaPlaceholder(
              'Animation',
              event.anm,
            ),

            _buildMediaPlaceholder(
              'Photo',
              event.photo,
            ),
            ],
          ),

      ),
    ),

    );
  }

  Widget _buildMediaPlaceholder(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value == null ? 'null (to be added later)' : 'present – will display here'),
          ),
        ],
      ),
    );
  }
}
