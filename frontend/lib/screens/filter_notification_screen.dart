import 'package:flutter/material.dart';
import '../services/region_notifier.dart';
import '../models/region.dart';

class FilterNotificationScreen extends StatefulWidget {
  const FilterNotificationScreen({super.key});

  @override
  State<FilterNotificationScreen> createState() =>
      _FilterNotificationScreenState();
}

class _FilterNotificationScreenState extends State<FilterNotificationScreen> {
  late RegionNotifier _regionNotifier;

  @override
  void initState() {
    super.initState();
    _regionNotifier = RegionNotifier.instance;
    _regionNotifier.addListener(_onRegionsChanged);
  }

  @override
  void dispose() {
    _regionNotifier.removeListener(_onRegionsChanged);
    super.dispose();
  }

  void _onRegionsChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final regions = _regionNotifier.regions;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter & Notification"),
        actions: [
          // Reload button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
          ),
          // Clear all button
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: regions.isEmpty
                ? null
                : () => _showClearConfirmation(context, _regionNotifier),
          ),
        ],
      ),
      body: regions.isEmpty
          ? const Center(
        child: Text(
          'No regions defined.\nTap + to add one.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        itemCount: regions.length,
        itemBuilder: (context, index) {
          final region = regions[index];
          return ListTile(
            title: Text(
              'Lat: ${region.lat.toStringAsFixed(4)}, '
                  'Lon: ${region.lon.toStringAsFixed(4)}',
            ),
            subtitle: Text(
              'Radius: ${region.radius.toStringAsFixed(0)} m',
            ),
            trailing: IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                _regionNotifier.removeRegionAt(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRegionDialog(context, _regionNotifier),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRegionDialog(BuildContext context, RegionNotifier notifier) {
    final formKey = GlobalKey<FormState>();
    final latController = TextEditingController();
    final lonController = TextEditingController();
    final radiusController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add Region'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: latController,
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),
                TextFormField(
                  controller: lonController,
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),
                TextFormField(
                  controller: radiusController,
                  decoration: const InputDecoration(labelText: 'Radius (meters)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Required';
                    if (double.tryParse(value) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final lat = double.parse(latController.text);
                  final lon = double.parse(lonController.text);
                  final radius = double.parse(radiusController.text);
                  notifier.addRegion(Region(
                    lat: lat,
                    lon: lon,
                    radius: radius,
                  ));
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Confirmation dialog before clearing all
  void _showClearConfirmation(BuildContext context, RegionNotifier notifier) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear All Regions'),
          content: const Text('Are you sure you want to remove all regions?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                notifier.clearRegions();
                Navigator.pop(dialogContext);
              },
              child: const Text('Clear All', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}