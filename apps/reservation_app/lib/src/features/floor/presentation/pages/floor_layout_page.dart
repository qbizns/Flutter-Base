import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Floor Layout Page
///
/// Visual floor plan with table management.
/// Features:
/// - Interactive floor layout
/// - Table status (Available, Reserved, Occupied)
/// - Table assignment
/// - Capacity management
class FloorLayoutPage extends ConsumerWidget {
  const FloorLayoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock table data
    final tables = List.generate(20, (index) {
      final tableNum = index + 1;
      return Table(
        number: tableNum,
        capacity: tableNum % 5 == 0 ? 6 : (tableNum % 3 == 0 ? 4 : 2),
        status: tableNum % 4 == 0
            ? TableStatus.occupied
            : (tableNum % 7 == 0 ? TableStatus.reserved : TableStatus.available),
      );
    });

    final stats = {
      TableStatus.available: tables.where((t) => t.status == TableStatus.available).length,
      TableStatus.reserved: tables.where((t) => t.status == TableStatus.reserved).length,
      TableStatus.occupied: tables.where((t) => t.status == TableStatus.occupied).length,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Floor Layout'),
      ),
      body: Column(
        children: [
          // Status legend
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildLegendItem(theme, 'Available', stats[TableStatus.available]!, Colors.green),
                _buildLegendItem(theme, 'Reserved', stats[TableStatus.reserved]!, Colors.orange),
                _buildLegendItem(theme, 'Occupied', stats[TableStatus.occupied]!, Colors.red),
              ],
            ),
          ),

          // Floor plan
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                return _buildTableCard(theme, table);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, int count, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text('$label ($count)'),
      ],
    );
  }

  Widget _buildTableCard(ThemeData theme, Table table) {
    final color = _getStatusColor(table.status);

    return Card(
      color: color.withOpacity(0.1),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.table_restaurant, size: 32, color: color),
              const SizedBox(height: 4),
              Text(
                '${table.number}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                '${table.capacity}p',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.occupied:
        return Colors.red;
    }
  }
}

class Table {
  final int number;
  final int capacity;
  final TableStatus status;

  Table({required this.number, required this.capacity, required this.status});
}

enum TableStatus { available, reserved, occupied }
