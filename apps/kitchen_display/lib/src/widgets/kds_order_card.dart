import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pos_core/pos_core.dart';

/// KDS Order Card - Displays order information for kitchen staff
///
/// Features:
/// - Order number and table info
/// - Order items with quantities
/// - Elapsed time with color coding
/// - Order type badge
/// - Bump button for completion
class KdsOrderCard extends StatelessWidget {
  const KdsOrderCard({
    required this.order,
    required this.onBump,
    this.onTap,
    super.key,
  });

  final Order order;
  final VoidCallback onBump;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final elapsed = DateTime.now().difference(order.createdAt);
    final cardColor = _getCardColor(elapsed, theme);
    final textColor = _getTextColor(elapsed, theme);

    return Card(
      elevation: 4,
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order number, table, time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Order #${order.orderNumber}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            _buildOrderTypeBadge(context),
                          ],
                        ),
                        if (order.tableId != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Table: ${order.tableId}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: textColor.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Timer
                  _buildTimer(context, elapsed, textColor),
                ],
              ),

              const Divider(height: 24),

              // Order items
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quantity badge
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              '${item.quantity}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Item details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: textColor,
                                ),
                              ),
                              if (item.selectedModifiers.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                ...item.selectedModifiers.map(
                                  (mod) => Padding(
                                    padding: const EdgeInsets.only(left: 8, top: 2),
                                    child: Text(
                                      '+ ${mod.modifierName}',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: textColor.withOpacity(0.8),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              if (item.notes?.isNotEmpty ?? false) ...[
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Note: ${item.notes}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 16),

              // Bump button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onBump,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('BUMP'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderTypeBadge(BuildContext context) {
    final theme = Theme.of(context);
    String label;
    Color color;

    switch (order.orderType) {
      case OrderType.dineIn:
        label = 'DINE IN';
        color = Colors.blue;
        break;
      case OrderType.takeaway:
        label = 'TAKEAWAY';
        color = Colors.orange;
        break;
      case OrderType.delivery:
        label = 'DELIVERY';
        color = Colors.purple;
        break;
      case OrderType.driveThru:
        label = 'DRIVE-THRU';
        color = Colors.green;
        break;
      case OrderType.curbside:
        label = 'CURBSIDE';
        color = Colors.teal;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTimer(BuildContext context, Duration elapsed, Color textColor) {
    final theme = Theme.of(context);
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final timeStr = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getTimerBackgroundColor(elapsed),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: textColor.withOpacity(0.3), width: 2),
      ),
      child: Text(
        timeStr,
        style: theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontFeatures: [const FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Color _getCardColor(Duration elapsed, ThemeData theme) {
    final minutes = elapsed.inMinutes;
    if (minutes < 10) {
      return theme.colorScheme.surface;
    } else if (minutes < 15) {
      return Colors.amber.shade100;
    } else {
      return Colors.red.shade100;
    }
  }

  Color _getTextColor(Duration elapsed, ThemeData theme) {
    final minutes = elapsed.inMinutes;
    if (minutes < 10) {
      return theme.colorScheme.onSurface;
    } else if (minutes < 15) {
      return Colors.amber.shade900;
    } else {
      return Colors.red.shade900;
    }
  }

  Color _getTimerBackgroundColor(Duration elapsed) {
    final minutes = elapsed.inMinutes;
    if (minutes < 10) {
      return Colors.green.shade100;
    } else if (minutes < 15) {
      return Colors.amber.shade200;
    } else {
      return Colors.red.shade200;
    }
  }
}
