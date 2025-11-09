import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Card widget for displaying order summary.
///
/// Used in order lists and history views.
class OrderCard extends StatelessWidget {
  const OrderCard({
    required this.order,
    this.onTap,
    this.compact = false,
    super.key,
  });

  final Order order;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Order Number
                  Expanded(
                    child: Text(
                      order.orderNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Status Badge
                  _buildStatusBadge(theme),
                ],
              ),

              const SizedBox(height: 8),

              // Order Type and Table/Customer
              Row(
                children: [
                  Icon(
                    _getOrderTypeIcon(),
                    size: 16,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getOrderTypeText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  if (order.tableName != null || order.customerName != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '•',
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        order.tableName ?? order.customerName ?? '',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),

              if (!compact) ...[
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Items Summary
                Text(
                  '${order.itemsCount} items',
                  style: theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 8),

                // Total and Payment Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    _buildPaymentStatusBadge(theme),
                  ],
                ),

                const SizedBox(height: 8),

                // Time Info
                Text(
                  _getTimeText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.itemsCount} items',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '\$${order.total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    final statusColor = _getStatusColor(theme);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildPaymentStatusBadge(ThemeData theme) {
    if (!order.isPaid) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Unpaid',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onErrorContainer,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Color _getStatusColor(ThemeData theme) {
    switch (order.status) {
      case OrderStatus.draft:
      case OrderStatus.pending:
        return theme.colorScheme.outline;
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return Colors.orange;
      case OrderStatus.ready:
        return Colors.blue;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
      case OrderStatus.hold:
        return theme.colorScheme.error;
    }
  }

  String _getStatusText() {
    return order.status.name[0].toUpperCase() + order.status.name.substring(1);
  }

  IconData _getOrderTypeIcon() {
    switch (order.orderType) {
      case OrderType.dineIn:
        return Icons.restaurant;
      case OrderType.takeaway:
        return Icons.shopping_bag;
      case OrderType.delivery:
        return Icons.delivery_dining;
      case OrderType.driveThru:
        return Icons.directions_car;
      case OrderType.online:
        return Icons.laptop;
    }
  }

  String _getOrderTypeText() {
    switch (order.orderType) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.driveThru:
        return 'Drive-Thru';
      case OrderType.online:
        return 'Online';
    }
  }

  String _getTimeText() {
    final now = DateTime.now();
    final diff = now.difference(order.createdAt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}
