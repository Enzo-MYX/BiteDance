import 'package:flutter/material.dart';
import '../models/event.dart';

const String baseUrl = 'http://3.27.216.9:8080';
class DetailScreen extends StatefulWidget {
  final Event event;
  const DetailScreen({super.key, required this.event});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  // Display the image in full‑screen
  void _showFullImageCarousel(List<String> urls, int initialIndex) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: Stack(
          children: [
            PageView.builder(
              controller: PageController(initialPage: initialIndex),
              itemCount: urls.length,
              itemBuilder: (ctx, index) {
                return InteractiveViewer(
                  child: Image.network(
                    baseUrl + urls[index],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.broken_image,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
            // Close button
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

  Widget _buildMediaCarousel() {
    final urls = widget.event.mediaUrls;

    if (urls.isEmpty) {
      return Container(
        height: 220,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(Icons.image, size: 80, color: Colors.grey),
        ),
      );
    }

    return SizedBox(
      height: 220,
      width: double.infinity,
      child: Stack(
        children: [
          // Swipeable image gallery
          PageView.builder(
            controller: _pageController,
            itemCount: urls.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _showFullImageCarousel(urls, index),
                child: Image.network(
                  baseUrl + urls[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.broken_image,
                    size: 50,
                  ),
                ),
              );
            },
          ),
          if (urls.length > 1)
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(urls.length, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event.location)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Text(
                "${widget.event.location} Buffet",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),
              _buildMediaCarousel(),

              const SizedBox(height: 24),

              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [

                      Text(
                        "Uploader: ${widget.event.uploader}",
                        style: TextStyle(fontSize: 16),
                      ),

                      SizedBox(height: 10),

                      Text(
                        "Time: ${_formatDateTime(widget.event.time)}",
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
                    widget.event.txt,
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