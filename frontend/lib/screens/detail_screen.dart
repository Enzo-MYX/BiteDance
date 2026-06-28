import 'package:flutter/material.dart';
import '../models/event.dart';

class DetailScreen extends StatelessWidget {
  final Event event;
  const DetailScreen({super.key, required this.event});

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Display the image in full‑screen
  void _showFullImage(BuildContext context, String assetPath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InteractiveViewer(
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaWidget(BuildContext context, String url) {
    final fileName = url.split('/').last;
    final assetPath = 'assets/images/$fileName';

    final lower = url.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.gif')) {
      return GestureDetector(
        onTap: () => _showFullImage(context, assetPath),
        child: Image.asset(
          assetPath,
          fit: BoxFit.cover,
          height: 220,
          width: double.infinity,
          errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, size: 50),
        ),
      );
    } else if (lower.endsWith('.mp4')) {
      return Container(
        height: 220,
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
              event.mediaUrls.isNotEmpty
                  ? _buildMediaWidget(context, event.mediaUrls.first)
                  : Container(
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
            ],
          ),
        ),
      ),
    );
  }

  // Kept existing placeholder method (unchanged, but unused)
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