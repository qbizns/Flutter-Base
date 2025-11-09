import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart' as pos;

/// Card widget for displaying a table.
///
/// Shows table number, capacity, status, and current order info.
class TableCard extends StatelessWidget {
  const TableCard({
    required this.table,
    this.onTap,
    this.compact = false,
    super.key,
  });

  final pos.Table table;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _getStatusColor(theme);

    return Card(
      elevation: table.isOccupied ? 2 : 1,
      color: statusColor.withOpacity(0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: statusColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Table Name and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      table.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusIcon(theme, statusColor),
                ],
              ),

              if (!compact) ...[
                const Spacer(),

                // Capacity
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 16,
                      color: theme.colorScheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${table.capacity} seats',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),

                // Zone
                if (table.zoneName != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          table.zoneName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Assigned Staff
                if (table.assignedTo != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          table.assignedTo!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],

              const SizedBox(height: 8),

              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _getStatusText(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme, Color statusColor) {
    IconData icon;
    switch (table.status) {
      case pos.TableStatus.available:
        icon = Icons.check_circle;
        break;
      case pos.TableStatus.occupied:
        icon = Icons.event_seat;
        break;
      case pos.TableStatus.reserved:
        icon = Icons.bookmark;
        break;
      case pos.TableStatus.cleaning:
        icon = Icons.cleaning_services;
        break;
      case pos.TableStatus.blocked:
        icon = Icons.block;
        break;
    }

    return Icon(icon, color: statusColor, size: 24);
  }

  Color _getStatusColor(ThemeData theme) {
    switch (table.status) {
      case pos.TableStatus.available:
        return Colors.green;
      case pos.TableStatus.occupied:
        return Colors.red;
      case pos.TableStatus.reserved:
        return Colors.orange;
      case pos.TableStatus.cleaning:
        return Colors.blue;
      case pos.TableStatus.blocked:
        return theme.colorScheme.outline;
    }
  }

  String _getStatusText() {
    return table.status.name[0].toUpperCase() + table.status.name.substring(1);
  }
}
