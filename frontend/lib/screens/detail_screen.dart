import 'package:flutter/material.dart';
import '../models/event.dart';

class DetailScreen extends StatelessWidget {
  final Event event;
  const DetailScreen({super.key, required this.event});

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Helper to decide which widget to show for each media URL
  Widget _buildMediaWidget(String url) {
    final fileName = url.split('/').last;
    final assetPath = 'assets/images/$fileName';

    final lower = url.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.gif')) {
      return Image.asset(
        assetPath,
        fit: BoxFit.cover,
        height: 600,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
      );
    } else if (lower.endsWith('.mp4')) {
      // Videos unsupported as of now, this is just a fake icon
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[300],
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_circle_filled, size: 50, color: Colors.blue),
              SizedBox(height: 8),
              Text('Video (unsupported in this demo)'),
            ],
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[200],
        child: Text('Unsupported: $url'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.location)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Uploader: ${event.uploader}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Time: ${_formatDateTime(event.time)}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text('Message:', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(event.txt, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            // Now implemented media section: (For testing purposes; not finalized UI)
            const Text('Media:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (event.mediaUrls.isEmpty)
              const Text('No media attached.', style: TextStyle(fontSize: 16, color: Colors.grey))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: event.mediaUrls.length,
                  itemBuilder: (ctx, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildMediaWidget(event.mediaUrls[index]),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}