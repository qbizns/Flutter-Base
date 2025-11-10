import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Delivery Zones Management Page
///
/// Features:
/// - Delivery zone definitions
/// - Fee configuration per zone
/// - Distance-based pricing
/// - Zone coverage maps (placeholder)
class DeliveryZonesPage extends ConsumerWidget {
  const DeliveryZonesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock zones
    final zones = _getMockZones();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Zones'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: zones.length,
        itemBuilder: (context, index) {
          final zone = zones[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: zone.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.place,
                  color: zone.color,
                  size: 32,
                ),
              ),
              title: Text(
                zone.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Radius: ${zone.radius} miles'),
                  Text('Delivery Fee: \$${zone.fee.toStringAsFixed(2)}'),
                  Text('Estimated Time: ${zone.estimatedTime} mins'),
                ],
              ),
              trailing: Switch(
                value: zone.isActive,
                onChanged: (value) {
                  // Toggle zone
                },
              ),
            ),
          );
        },
      ),
    );
  }

  List<DeliveryZone> _getMockZones() {
    return [
      DeliveryZone(
        name: 'Downtown',
        radius: 2.0,
        fee: 3.00,
        estimatedTime: 15,
        color: Colors.blue,
        isActive: true,
      ),
      DeliveryZone(
        name: 'Suburbs',
        radius: 5.0,
        fee: 5.00,
        estimatedTime: 25,
        color: Colors.green,
        isActive: true,
      ),
      DeliveryZone(
        name: 'Extended',
        radius: 10.0,
        fee: 8.00,
        estimatedTime: 40,
        color: Colors.orange,
        isActive: false,
      ),
    ];
  }
}

class DeliveryZone {
  final String name;
  final double radius;
  final double fee;
  final int estimatedTime;
  final Color color;
  final bool isActive;

  DeliveryZone({
    required this.name,
    required this.radius,
    required this.fee,
    required this.estimatedTime,
    required this.color,
    required this.isActive,
  });
}
