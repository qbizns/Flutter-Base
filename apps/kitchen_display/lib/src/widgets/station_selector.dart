import 'package:flutter/material.dart';

/// Kitchen Station Model
class KitchenStation {
  const KitchenStation({
    required this.id,
    required this.name,
    required this.color,
  });

  final String id;
  final String name;
  final Color color;

  factory KitchenStation.fromJson(Map<String, dynamic> json) {
    return KitchenStation(
      id: json['id'] as String,
      name: json['name'] as String,
      color: Color(
        int.parse(json['color'].toString().replaceFirst('#', '0xFF')),
      ),
    );
  }
}

/// Station Selector Widget - Filters orders by kitchen station
///
/// Features:
/// - Horizontal scrollable station chips
/// - "All Stations" option
/// - Active station highlighting
/// - Station color coding
class StationSelector extends StatelessWidget {
  const StationSelector({
    required this.stations,
    required this.selectedStationId,
    required this.onStationSelected,
    super.key,
  });

  final List<KitchenStation> stations;
  final String? selectedStationId;
  final ValueChanged<String?> onStationSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // All Stations chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All Stations'),
              selected: selectedStationId == null,
              onSelected: (selected) {
                if (selected) {
                  onStationSelected(null);
                }
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primaryContainer,
              checkmarkColor: theme.colorScheme.onPrimaryContainer,
              labelStyle: TextStyle(
                fontWeight: selectedStationId == null ? FontWeight.bold : FontWeight.normal,
                color: selectedStationId == null
                    ? theme.colorScheme.onPrimaryContainer
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Station chips
          ...stations.map((station) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(station.name),
                  selected: selectedStationId == station.id,
                  onSelected: (selected) {
                    if (selected) {
                      onStationSelected(station.id);
                    }
                  },
                  backgroundColor: station.color.withOpacity(0.2),
                  selectedColor: station.color,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    fontWeight: selectedStationId == station.id ? FontWeight.bold : FontWeight.normal,
                    color: selectedStationId == station.id ? Colors.white : station.color,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
