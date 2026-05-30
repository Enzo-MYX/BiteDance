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
            // Placeholders for future media
            const Text('Media (future):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildMediaPlaceholder('Video', event.vid),
            _buildMediaPlaceholder('Animation', event.anm),
            _buildMediaPlaceholder('Photo', event.photo),
          ],
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