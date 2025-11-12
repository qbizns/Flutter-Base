/// Table Card Widget
/// Visual representation of a restaurant table
/// Following Odoo POS table display patterns
library;

import 'package:flutter/material.dart';

import '../../data/models/waiter_models.dart';

/// Table Card Widget
/// Displays table with status color, number, and basic info
class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback? onTap;
  final bool isSelected;

  const TableCard({
    super.key,
    required this.table,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get status color
    final statusColor = _getStatusColor(table.status);
    final isOccupied = table.status == TableStatus.occupied;

    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? statusColor.withOpacity(0.2) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor,
          width: isSelected ? 3 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Table icon based on shape
              Icon(
                _getTableIcon(table.shape),
                size: 32,
                color: statusColor,
              ),
              const SizedBox(height: 8),

              // Table name
              Text(
                table.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getStatusText(table.status),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Additional info for occupied tables
              if (isOccupied) ...[
                const SizedBox(height: 8),
                if (table.guestCount != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person,
                        size: 14,
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${table.guestCount}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                if (table.occupiedSince != null)
                  Text(
                    _formatDuration(
                      DateTime.now().difference(table.occupiedSince!),
                    ),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                if (table.currentBill != null)
                  Text(
                    '\$${table.currentBill!.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
              ],

              // Seat count for available tables
              if (!isOccupied) ...[
                const SizedBox(height: 4),
                Text(
                  '${table.seats} seats',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Get icon based on table shape
  IconData _getTableIcon(TableShape shape) {
    switch (shape) {
      case TableShape.round:
        return Icons.circle_outlined;
      case TableShape.square:
        return Icons.square_outlined;
      case TableShape.rectangular:
        return Icons.rectangle_outlined;
    }
  }

  /// Get color based on table status
  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.blue;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.needsCleaning:
        return Colors.red;
      case TableStatus.outOfService:
        return Colors.grey;
    }
  }

  /// Get status text
  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.needsCleaning:
        return 'Cleaning';
      case TableStatus.outOfService:
        return 'Out of Service';
    }
  }

  /// Format duration
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else {
      return '${duration.inMinutes}m';
    }
  }
}

/// Compact Table Card for list view
class CompactTableCard extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback? onTap;

  const CompactTableCard({
    super.key,
    required this.table,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(table.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            Icons.table_restaurant,
            color: statusColor,
          ),
        ),
        title: Text(
          table.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _getStatusText(table.status),
          style: TextStyle(color: statusColor),
        ),
        trailing: table.status == TableStatus.occupied
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (table.guestCount != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.person, size: 14),
                        const SizedBox(width: 4),
                        Text('${table.guestCount}'),
                      ],
                    ),
                  if (table.currentBill != null)
                    Text(
                      '\$${table.currentBill!.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              )
            : null,
      ),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.blue;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.needsCleaning:
        return Colors.red;
      case TableStatus.outOfService:
        return Colors.grey;
    }
  }

  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.needsCleaning:
        return 'Needs Cleaning';
      case TableStatus.outOfService:
        return 'Out of Service';
    }
  }
}
