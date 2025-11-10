import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../../widgets/kds_order_card.dart';
import '../../../widgets/station_selector.dart';

/// KDS Main Page - Real-time kitchen order display
///
/// Features:
/// - Auto-refreshing order queue
/// - Station-based filtering
/// - Order status tracking
/// - Bump orders to next status
/// - Visual and audio alerts
/// - Priority ordering
class KdsMainPage extends ConsumerStatefulWidget {
  const KdsMainPage({super.key});

  @override
  ConsumerState<KdsMainPage> createState() => _KdsMainPageState();
}

class _KdsMainPageState extends ConsumerState<KdsMainPage> {
  Timer? _refreshTimer;
  String? _selectedStationId;

  // Kitchen stations - in production, load from config
  final List<KitchenStation> _stations = [
    const KitchenStation(id: 'grill', name: 'Grill Station', color: Color(0xFFFF5722)),
    const KitchenStation(id: 'fry', name: 'Fry Station', color: Color(0xFFFFC107)),
    const KitchenStation(id: 'salad', name: 'Salad Station', color: Color(0xFF4CAF50)),
    const KitchenStation(id: 'dessert', name: 'Dessert Station', color: Color(0xFFE91E63)),
    const KitchenStation(id: 'drinks', name: 'Drinks Station', color: Color(0xFF2196F3)),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    // Refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      ref.invalidate(ordersProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Get orders that need kitchen preparation (pending and preparing)
    final ordersAsync = ref.watch(ordersProvider(
      status: OrderStatus.preparing, // In real app, might want multiple statuses
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kitchen Display'),
        centerTitle: true,
        actions: [
          // Manual refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(ordersProvider),
            tooltip: 'Refresh',
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Station selector
          StationSelector(
            stations: _stations,
            selectedStationId: _selectedStationId,
            onStationSelected: (stationId) {
              setState(() {
                _selectedStationId = stationId;
              });
            },
          ),

          const Divider(height: 1),

          // Orders grid
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                // Filter by station if selected
                final filteredOrders = _selectedStationId == null
                    ? orders
                    : orders; // TODO: Filter by station when station field is added to Order

                if (filteredOrders.isEmpty) {
                  return _buildEmptyState(context);
                }

                // Sort by creation time (oldest first)
                final sortedOrders = List<Order>.from(filteredOrders)
                  ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

                return _buildOrdersGrid(context, sortedOrders);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading orders',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(ordersProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            Icons.check_circle_outline,
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedStationId == null
                ? 'No orders in the kitchen'
                : 'No orders for this station',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersGrid(BuildContext context, List<Order> orders) {
    // Get screen width to determine grid columns
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 1200
        ? 4
        : screenWidth > 800
            ? 3
            : screenWidth > 600
                ? 2
                : 1;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return KdsOrderCard(
          order: order,
          onBump: () => _bumpOrder(context, order),
          onTap: () => _showOrderDetails(context, order),
        );
      },
    );
  }

  Future<void> _bumpOrder(BuildContext context, Order order) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bump Order?'),
        content: Text(
          'Mark order #${order.orderNumber} as ready?\n\nThis will notify the service staff that the order is complete.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bump'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Update order status to ready
    final result = await ref.read(updateOrderStatusUseCaseProvider)(
      order.id,
      OrderStatus.ready,
    );

    await result.when(
      success: (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order #${order.orderNumber} marked as ready'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Refresh orders list
          ref.invalidate(ordersProvider);
        }
      },
      failure: (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.message}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _showOrderDetails(BuildContext context, Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _OrderDetailsSheet(
            order: order,
            scrollController: scrollController,
          );
        },
      ),
    );
  }

  void _showSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KDS Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Audio Alerts'),
              subtitle: const Text('Play sound for new orders'),
              value: true,
              onChanged: (value) {
                // TODO: Implement settings
              },
            ),
            SwitchListTile(
              title: const Text('Auto Refresh'),
              subtitle: const Text('Refresh orders every 5 seconds'),
              value: true,
              onChanged: (value) {
                // TODO: Implement settings
              },
            ),
            ListTile(
              title: const Text('Warning Time'),
              subtitle: const Text('10 minutes'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Implement settings
              },
            ),
          ],
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
}

/// Order Details Sheet - Shows full order information
class _OrderDetailsSheet extends StatelessWidget {
  const _OrderDetailsSheet({
    required this.order,
    required this.scrollController,
  });

  final Order order;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: ListView(
        controller: scrollController,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Order header
          Text(
            'Order #${order.orderNumber}',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Created: ${_formatDateTime(order.createdAt)}',
            style: theme.textTheme.bodyLarge,
          ),
          if (order.tableId != null) ...[
            const SizedBox(height: 4),
            Text(
              'Table: ${order.tableId}',
              style: theme.textTheme.bodyLarge,
            ),
          ],

          const Divider(height: 32),

          // Order items
          Text(
            'Items',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.productName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item.selectedModifiers.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...item.selectedModifiers.map(
                            (mod) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('+ ${mod.modifierName}'),
                            ),
                          ),
                        ],
                        if (item.notes?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Note: ${item.notes}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }
}
