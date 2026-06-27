import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
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

  // Preparing to load presets from JSON
  List<PresetLocation> _presetLocations = [];
  bool _presetsLoaded = false;

  final TextEditingController _distanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _regionNotifier = RegionNotifier.instance;
    _regionNotifier.addListener(_onRegionsChanged);
    _loadPresets(); // load from JSON file
    _distanceController.text = _regionNotifier.maxDistance.toString();
  }

  @override
  void dispose() {
    _regionNotifier.removeListener(_onRegionsChanged);
    _distanceController.dispose();
    super.dispose();
  }

  void _onRegionsChanged() {
    setState(() {});
  }

  void onFieldChanged() {
    setState(() {
      _distanceController.text = _regionNotifier.maxDistance.toString();
    });
  }

  // Load presets from assets/locations.json
  Future<void> _loadPresets() async {
    try {
      final String jsonString =
      await rootBundle.loadString('assets/locations.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final List<PresetLocation> loaded = jsonMap.entries.map((entry) {
        final name = entry.key;
        final data = entry.value as Map<String, dynamic>;
        return PresetLocation(
          name: name,
          lat: data['lat']?.toDouble() ?? 0.0,
          lon: data['lon']?.toDouble() ?? 0.0,
        );
      }).toList();
      setState(() {
        _presetLocations = loaded;
        _presetsLoaded = true;
      });
    } catch (e) {
      // Fallback to a minimal set if loading fails
      setState(() {
        _presetLocations = const [
          PresetLocation(name: 'This is an error message', lat: 0.0, lon: 0.0),
        ];
        _presetsLoaded = true;
      });
    }
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
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notify buffets near me',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Enable'),
                      Switch(value: _regionNotifier.rtlEnabled,
                          onChanged: (value) {_regionNotifier.setRTLEnabled(value);
                          }),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _distanceController,
                          decoration: const InputDecoration(
                            labelText: 'Radius (meters)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true
                          ),
                          enabled: _regionNotifier.rtlEnabled,
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed != null) {
                              _regionNotifier.setMaxDistance(parsed);
                            }
                          },
                        ),
                      )
                    ],
                  )
                ],
              )
            ),
          ),
          Expanded(
            child: regions.isEmpty
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
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile( // Title: show name if preset, else coordinates
                        title: region.isPreset
                            ? Text(
                          region.name!,
                          style: const TextStyle(fontSize: 14),
                        )
                            : Text(
                          'Lat: ${region.lat.toStringAsFixed(4)}, '
                          'Lon: ${region.lon.toStringAsFixed(4)}',
                          style: const TextStyle(fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ), // Subtitle: show name for non-preset regions
                        subtitle: (!region.isPreset && region.name != null)
                            ? Row(
                              children: [
                                const Icon(Icons.location_on, size: 16),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    '${region.name}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ), // I wanted to add a bit more in subtitles but there isn't enough length
                              ],
                            )
                            : null,
                    trailing: Row( // messed up the indentation while cut-pasting part of the code, I'll fix the rest later
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Editable radius chip
                        GestureDetector(
                          onTap: () => _showEditRadiusDialog(
                              context, _regionNotifier, index, region.radius),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue.shade300),
                            ),
                            child: Text(
                              '${region.radius.toStringAsFixed(0)} m',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            _regionNotifier.removeRegionAt(index);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRegionDialog(context, _regionNotifier),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ----- Add Region Dialog (with manual / preset toggle) -----
  void _showAddRegionDialog(BuildContext context, RegionNotifier notifier) {
    // Controllers
    final nameController = TextEditingController();
    final latController = TextEditingController();
    final lonController = TextEditingController();
    final radiusController = TextEditingController();

    // State for toggle
    InputMode inputMode = InputMode.manual;
    PresetLocation? selectedPreset;

    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Region'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Toggle between Manual and Preset
                      SegmentedButton<InputMode>(
                        segments: const [
                          ButtonSegment(
                            value: InputMode.manual,
                            label: Text('Manual'),
                            icon: Icon(Icons.edit),
                          ),
                          ButtonSegment(
                            value: InputMode.preset,
                            label: Text('Preset'),
                            icon: Icon(Icons.list),
                          ),
                        ],
                        selected: {inputMode},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            inputMode = newSelection.first;
                            // Clear controllers/preset when switching
                            if (inputMode == InputMode.manual) {
                              selectedPreset = null;
                            } else {
                              latController.clear();
                              lonController.clear();
                              nameController.clear();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Input fields based on mode
                      if (inputMode == InputMode.manual) ...[
                        TextFormField(
                          controller: latController,
                          decoration: const InputDecoration(labelText: 'Latitude'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (double.tryParse(value) == null)
                              return 'Invalid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: lonController,
                          decoration: const InputDecoration(labelText: 'Longitude'),
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (double.tryParse(value) == null)
                              return 'Invalid number';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                              labelText: 'Name'
                          ),
                        ),
                      ] else ...[
                        // Preset loader
                        if (!_presetsLoaded)
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        else
                          DropdownButtonFormField<PresetLocation>(
                            decoration: const InputDecoration(
                              labelText: 'Select a location',
                              border: OutlineInputBorder(),
                            ),
                            initialValue: selectedPreset,
                            items: _presetLocations.map((loc) {
                              return DropdownMenuItem(
                                value: loc,
                                child: Text(loc.name),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedPreset = value;
                                if (value != null) {
                                  latController.text = value.lat.toString();
                                  lonController.text = value.lon.toString();
                                }
                              });
                            },
                            validator: (value) {
                              if (value == null) return 'Please select a location';
                              return null;
                            },
                          ),
                        const SizedBox(height: 12),
                        // Show the coordinates of the selected preset (read-only)
                        if (selectedPreset != null)
                          Text(
                            'Lat: ${selectedPreset!.lat}, Lon: ${selectedPreset!.lon}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                      ],

                      const SizedBox(height: 12),

                      // Radius input - common for both modes
                      TextFormField(
                        controller: radiusController,
                        decoration: const InputDecoration(
                          labelText: 'Radius (meters)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Required';
                          if (double.tryParse(value) == null)
                            return 'Invalid number';
                          return null;
                        },
                      ),
                    ],
                  ),
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
                      double lat, lon, radius;
                      String? name;
                      if (inputMode == InputMode.manual) {
                        lat = double.parse(latController.text);
                        lon = double.parse(lonController.text);
                        name = nameController.text.isEmpty
                            ? null
                            : nameController.text;
                      } else {
                        if (selectedPreset == null) {
                          return;
                        }
                        lat = selectedPreset!.lat;
                        lon = selectedPreset!.lon;
                        name = selectedPreset!.name; // store the preset name
                      }
                      radius = double.parse(radiusController.text);
                      notifier.addRegion(Region(
                        lat: lat,
                        lon: lon,
                        radius: radius,
                        name: name,
                        isPreset: inputMode == InputMode.preset,
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
      },
    );
  }

  // Status editing dialogue
  void _showEditRadiusDialog(
      BuildContext context,
      RegionNotifier notifier,
      int index,
      double currentRadius,
      ) {
    final controller = TextEditingController(text: currentRadius.toString());
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Radius'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'New radius (meters)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Required';
                if (double.tryParse(value) == null) return 'Invalid number';
                return null;
              },
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
                  final newRadius = double.parse(controller.text);
                  notifier.updateRadius(index, newRadius);
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('Update'),
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

// Helper classes
enum InputMode { manual, preset }

class PresetLocation {
  final String name;
  final double lat;
  final double lon;

  const PresetLocation({required this.name, required this.lat, required this.lon});
}