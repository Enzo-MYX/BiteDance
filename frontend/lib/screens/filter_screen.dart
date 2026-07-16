import 'package:flutter/material.dart';
import '../services/filter_notifier.dart';

class FilterOrderScreen extends StatefulWidget {
  const FilterOrderScreen({super.key});

  @override
  State<FilterOrderScreen> createState() => _FilterOrderScreenState();
}

class _FilterOrderScreenState extends State<FilterOrderScreen> {
  late FilterNotifier _notifier;

  String _selectedPreset = '1.5h'; // default

  final TextEditingController _customNumberController = TextEditingController();
  String? _customUnitValue;

  @override
  void initState() {
    super.initState();
    _notifier = FilterNotifier.instance;
    _notifier.addListener(_onNotifierChanged);
    _restoreFromNotifier();
  }

  void _restoreFromNotifier() {
    // code to ensure settings are saved
    if (_notifier.timeSelection == 'custom') {
      _selectedPreset = 'Customize';
    } else {
      _selectedPreset = _notifier.timeSelection;
    }
    _customNumberController.text = _notifier.customNumber.toString();
    _customUnitValue = _notifier.customUnit;
  }

  @override
  void dispose() {
    _notifier.removeListener(_onNotifierChanged);
    _customNumberController.dispose();
    super.dispose();
  }

  void _onNotifierChanged() {
    setState(() {});
  }

  double _computeCustomSeconds() {
    double num = double.tryParse(_customNumberController.text) ?? 0;
    if (_customUnitValue == 'hours') num *= 3600;
    else num *= 60; // minutes
    return num;
  }

  // Update notifier when custom fields change
  void _updateCustomTime() {
    final seconds = _computeCustomSeconds();
    _notifier.setExpireTime(seconds);
    _notifier.setTimeSelect(
      'custom',
      number: double.tryParse(_customNumberController.text) ?? 90,
      unit: _customUnitValue ?? 'minutes',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Page'),
        actions: [
          TextButton(
            onPressed: () {
              _notifier.resetFilters();
              // Reset local dropdown to default
              setState(() {
                _selectedPreset = '1.5h';
                _customNumberController.text = '90';
                _customUnitValue = 'minutes';
              });
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.black,
            ),
            child: const Text('Reset Settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Filters', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Show Only Favorites'),
            value: _notifier.onlyFavorites,
            onChanged: (_) => _notifier.toggleFilterByFavs(),
          ),
          SwitchListTile(
            title: const Text('Only Watched Regions'),
            value: _notifier.onlyWatched,
            onChanged: (_) => _notifier.toggleOnlyWatched(),
          ),

          const SizedBox(height: 16),
          const Text('Max Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          DropdownButtonFormField<String>(
            initialValue: _selectedPreset,
            items: const [
              DropdownMenuItem(value: '1h', child: Text('1 hour')),
              DropdownMenuItem(value: '1.5h', child: Text('1.5 hours')),
              DropdownMenuItem(value: '2h', child: Text('2 hours')),
              DropdownMenuItem(value: '3h', child: Text('3 hours')),
              DropdownMenuItem(value: '24h', child: Text('24 hours')),
              DropdownMenuItem(value: 'Customize', child: Text('Customize')),
            ],
            onChanged: (value) {
              setState(() {
                _selectedPreset = value!;
                if (value != 'Customize') {
                  double seconds = 0;
                  switch (value) {
                    case '1h': seconds = 3600; break;
                    case '1.5h': seconds = 5400; break;
                    case '2h': seconds = 7200; break;
                    case '3h': seconds = 10800; break;
                    case '24h': seconds = 86400; break;
                  }
                  _notifier.setExpireTime(seconds);
                  _notifier.setTimeSelect(value);
                } else {
                  _customNumberController.text = _notifier.customNumber.toString();
                  _customUnitValue = _notifier.customUnit;
                  _updateCustomTime();
                }
              });
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
          ),
          if (_selectedPreset == 'Customize') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _customNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _updateCustomTime(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _customUnitValue,
                    items: const [
                      DropdownMenuItem(value: 'minutes', child: Text('Minutes')),
                      DropdownMenuItem(value: 'hours', child: Text('Hours')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _customUnitValue = value;
                      });
                      _updateCustomTime();
                    },
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],

          const Divider(height: 32),
          const Text('Sort by', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Sort by Distance (Closest first)'),
            value: _notifier.orderBy == 'distance',
            onChanged: (_) {
              _notifier.toggleSortByDistance();
            },
          ),
          SwitchListTile(
            title: const Text('Sort by Time (Newest first)'),
            value: _notifier.orderBy == 'time',
            onChanged: (_) {
              _notifier.toggleSortByTime();
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Current order: ${_notifier.orderBy == 'none' ? 'None (original order)' : _notifier.orderBy}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Reverse order'),
            value: _notifier.reverse,
            onChanged: (_) => _notifier.toggleRev(),
          ),
        ],
      ),
    );
  }
}