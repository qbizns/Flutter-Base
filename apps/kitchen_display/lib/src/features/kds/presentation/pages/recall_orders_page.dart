import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../providers/bumped_orders_provider.dart';

/// Recall Orders Page - View and recall recently bumped orders
///
/// Allows kitchen staff to:
/// - View recently bumped orders (last 2 hours)
/// - Recall orders that were accidentally bumped
/// - See when each order was bumped
class RecallOrdersPage extends ConsumerWidget {
  const RecallOrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final bumpedOrders = ref.watch(bumpedOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recall Orders'),
        actions: [
          if (bumpedOrders.isNotEmpty)
            TextButton.icon(
              onPressed: () => _confirmClearAll(context, ref),
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All'),
            ),
        ],
      ),
      body: bumpedOrders.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bumpedOrders.length,
              itemBuilder: (context, index) {
                final bumpedOrder = bumpedOrders[index];
                return _buildBumpedOrderCard(
                  context,
                  ref,
                  bumpedOrder,
                  theme,
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Recently Bumped Orders',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Orders bumped in the last 2 hours will appear here',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBumpedOrderCard(
    BuildContext context,
    WidgetRef ref,
    BumpedOrder bumpedOrder,
    ThemeData theme,
  ) {
    final order = bumpedOrder.order;
    final timeSinceBump = DateTime.now().difference(bumpedOrder.bumpedAt);
    final minutesAgo = timeSinceBump.inMinutes;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
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
                            ),
                          ),
                          const SizedBox(width: 8),
                          _buildOrderTypeBadge(context, order.orderType),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Bumped $minutesAgo ${minutesAgo == 1 ? 'minute' : 'minutes'} ago',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      if (order.tableId != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Table: ${order.tableId}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Order items summary
            Text(
              'Items:',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ...order.items.take(3).map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${item.quantity}x ${item.productName}',
                    style: theme.textTheme.bodyMedium,
                  ),
                )),
            if (order.items.length > 3) ...[
              Text(
                '+ ${order.items.length - 3} more items',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _recallOrder(context, ref, order),
                    icon: const Icon(Icons.undo),
                    label: const Text('RECALL ORDER'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showOrderDetails(context, order),
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'View Details',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTypeBadge(BuildContext context, OrderType type) {
    final theme = Theme.of(context);
    String label;
    Color color;

    switch (type) {
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

  Future<void> _recallOrder(
    BuildContext context,
    WidgetRef ref,
    Order order,
  ) async {
    // Confirm recall
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recall Order?'),
        content: Text(
          'Recall order #${order.orderNumber}?\n\nThis will change the order status back to "Preparing" and it will reappear in the kitchen queue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Recall'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Update order status back to preparing
    final result = await ref.read(updateOrderStatusUseCaseProvider)(
      order.id,
      OrderStatus.preparing,
    );

    await result.when(
      success: (_) {
        if (context.mounted) {
          // Remove from bumped orders list
          ref.read(bumpedOrdersProvider.notifier).removeBumpedOrder(order.id);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order #${order.orderNumber} recalled to kitchen queue'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );

          // If no more orders, go back
          if (ref.read(bumpedOrdersProvider).isEmpty) {
            Navigator.pop(context);
          }
        }
      },
      failure: (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error recalling order: ${error.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (order.tableId != null) Text('Table: ${order.tableId}'),
              const SizedBox(height: 16),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${item.quantity}x ${item.productName}'),
                        if (item.selectedModifiers.isNotEmpty)
                          ...item.selectedModifiers.map(
                            (mod) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 2),
                              child: Text(
                                '+ ${mod.modifierName}',
                                style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        if (item.notes?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 2),
                            child: Text(
                              'Note: ${item.notes}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ),
                      ],
                    ),
                  )),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All?'),
        content: const Text(
          'Remove all bumped orders from history?\n\nThis cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(bumpedOrdersProvider.notifier).clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All bumped orders cleared'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
