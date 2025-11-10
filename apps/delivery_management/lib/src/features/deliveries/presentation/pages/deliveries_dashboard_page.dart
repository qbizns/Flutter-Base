import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Deliveries Dashboard - Main delivery management page
///
/// Features:
/// - Active deliveries overview
/// - Delivery status tracking
/// - Driver assignments
/// - Quick actions
/// - Real-time updates
/// - Delivery metrics
class DeliveriesDashboardPage extends ConsumerStatefulWidget {
  const DeliveriesDashboardPage({super.key});

  @override
  ConsumerState<DeliveriesDashboardPage> createState() => _DeliveriesDashboardPageState();
}

class _DeliveriesDashboardPageState extends ConsumerState<DeliveriesDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Auto-refresh every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      ref.invalidate(ordersProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ordersAsync = ref.watch(ordersProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(ordersProvider);
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              context.go('/delivery-map');
            },
            tooltip: 'View Map',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Active',
              icon: Icon(Icons.local_shipping),
            ),
            Tab(
              text: 'Pending',
              icon: Icon(Icons.schedule),
            ),
            Tab(
              text: 'Completed',
              icon: Icon(Icons.check_circle),
            ),
            Tab(
              text: 'All',
              icon: Icon(Icons.list),
            ),
          ],
        ),
      ),
      body: ordersAsync.when(
        data: (orders) {
          // Filter delivery orders
          final deliveryOrders = orders
              .where((o) => o.orderType == OrderType.delivery)
              .toList();

          // Group by status
          final activeDeliveries = deliveryOrders
              .where((o) => o.status == OrderStatus.preparing || o.status == OrderStatus.ready)
              .toList();

          final pendingDeliveries = deliveryOrders
              .where((o) => o.status == OrderStatus.pending)
              .toList();

          final completedDeliveries = deliveryOrders
              .where((o) => o.status == OrderStatus.completed)
              .toList();

          return Column(
            children: [
              // Metrics summary
              _buildMetricsSummary(context, deliveryOrders),

              // Tab views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDeliveryList(context, activeDeliveries, 'active'),
                    _buildDeliveryList(context, pendingDeliveries, 'pending'),
                    _buildDeliveryList(context, completedDeliveries, 'completed'),
                    _buildDeliveryList(context, deliveryOrders, 'all'),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading deliveries')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.go('/drivers');
        },
        icon: const Icon(Icons.people),
        label: const Text('Manage Drivers'),
      ),
    );
  }

  Widget _buildMetricsSummary(BuildContext context, List<Order> deliveries) {
    final theme = Theme.of(context);

    final activeCount = deliveries
        .where((o) => o.status == OrderStatus.preparing || o.status == OrderStatus.ready)
        .length;

    final pendingCount = deliveries
        .where((o) => o.status == OrderStatus.pending)
        .length;

    final completedToday = deliveries
        .where((o) {
          final now = DateTime.now();
          return o.status == OrderStatus.completed &&
              o.createdAt.year == now.year &&
              o.createdAt.month == now.month &&
              o.createdAt.day == now.day;
        })
        .length;

    final totalRevenue = deliveries
        .where((o) => o.status == OrderStatus.completed)
        .fold<double>(0, (sum, o) => sum + o.total);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              context,
              icon: Icons.local_shipping,
              title: 'Active',
              value: '$activeCount',
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              context,
              icon: Icons.schedule,
              title: 'Pending',
              value: '$pendingCount',
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              context,
              icon: Icons.check_circle,
              title: 'Completed Today',
              value: '$completedToday',
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMetricCard(
              context,
              icon: Icons.attach_money,
              title: 'Revenue',
              value: '\$${totalRevenue.toStringAsFixed(0)}',
              color: Colors.purple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryList(BuildContext context, List<Order> deliveries, String type) {
    final theme = Theme.of(context);

    if (deliveries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.delivery_dining,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No ${type == 'all' ? '' : type} deliveries',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(ordersProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: deliveries.length,
        itemBuilder: (context, index) {
          return _buildDeliveryCard(context, deliveries[index]);
        },
      ),
    );
  }

  Widget _buildDeliveryCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(order.status);

    // Mock delivery data
    final deliveryData = _getMockDeliveryData(order.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showDeliveryDetails(context, order, deliveryData);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.delivery_dining,
                      color: statusInfo.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order.orderNumber}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              statusInfo.icon,
                              size: 16,
                              color: statusInfo.color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusInfo.label,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: statusInfo.color,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '\$${order.total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Delivery details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                          context,
                          icon: Icons.person,
                          label: 'Customer',
                          value: deliveryData.customerName,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: Icons.location_on,
                          label: 'Address',
                          value: deliveryData.address,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: Icons.phone,
                          label: 'Phone',
                          value: deliveryData.phone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (deliveryData.driverName != null) ...[
                        CircleAvatar(
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          deliveryData.driverName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Driver',
                          style: theme.textTheme.bodySmall,
                        ),
                      ] else ...[
                        Icon(
                          Icons.person_off,
                          size: 40,
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Unassigned',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Action buttons
              Row(
                children: [
                  if (deliveryData.driverName == null)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          _assignDriver(context, order);
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Assign Driver'),
                      ),
                    ),
                  if (deliveryData.driverName != null) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Track delivery
                        },
                        icon: const Icon(Icons.map),
                        label: const Text('Track'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Call customer
                        },
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDeliveryDetails(BuildContext context, Order order, DeliveryData delivery) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Order #${order.orderNumber}'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delivery Information',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Customer', delivery.customerName),
                _buildDetailRow('Address', delivery.address),
                _buildDetailRow('Phone', delivery.phone),
                if (delivery.driverName != null)
                  _buildDetailRow('Driver', delivery.driverName!),
                _buildDetailRow('Status', _getStatusInfo(order.status).label),
                const Divider(),
                Text(
                  'Order Items',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${item.product.name} x${item.quantity}'),
                          Text('\$${item.totalPrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    )),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
            ),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _assignDriver(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (context) => _AssignDriverDialog(order: order),
    );
  }

  StatusInfo _getStatusInfo(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return StatusInfo(
          color: Colors.orange,
          icon: Icons.schedule,
          label: 'Pending',
        );
      case OrderStatus.preparing:
        return StatusInfo(
          color: Colors.blue,
          icon: Icons.restaurant,
          label: 'Preparing',
        );
      case OrderStatus.ready:
        return StatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          label: 'Ready',
        );
      case OrderStatus.completed:
        return StatusInfo(
          color: Colors.grey,
          icon: Icons.done_all,
          label: 'Delivered',
        );
      case OrderStatus.cancelled:
        return StatusInfo(
          color: Colors.red,
          icon: Icons.cancel,
          label: 'Cancelled',
        );
    }
  }

  // Mock data generator
  DeliveryData _getMockDeliveryData(String orderId) {
    final addresses = [
      '123 Main St, Apt 4B',
      '456 Oak Avenue',
      '789 Pine Road',
      '321 Elm Street',
    ];

    final names = ['John Smith', 'Sarah Johnson', 'Mike Brown', 'Emily Davis'];
    final phones = ['+1 (555) 123-4567', '+1 (555) 234-5678', '+1 (555) 345-6789', '+1 (555) 456-7890'];
    final drivers = ['Alex Driver', 'Sam Wilson', null, 'Chris Taylor'];

    final index = orderId.hashCode % 4;

    return DeliveryData(
      customerName: names[index],
      address: addresses[index],
      phone: phones[index],
      driverName: drivers[index],
    );
  }
}

// Assign Driver Dialog
class _AssignDriverDialog extends StatefulWidget {
  const _AssignDriverDialog({required this.order});

  final Order order;

  @override
  State<_AssignDriverDialog> createState() => _AssignDriverDialogState();
}

class _AssignDriverDialogState extends State<_AssignDriverDialog> {
  String? _selectedDriver;

  final _mockDrivers = [
    'Alex Driver',
    'Sam Wilson',
    'Chris Taylor',
    'Jamie Lee',
  ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Assign Driver'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Select Driver',
              border: OutlineInputBorder(),
            ),
            value: _selectedDriver,
            items: _mockDrivers.map((driver) {
              return DropdownMenuItem(
                value: driver,
                child: Text(driver),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedDriver = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedDriver != null
              ? () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Driver $_selectedDriver assigned to order #${widget.order.orderNumber}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              : null,
          child: const Text('Assign'),
        ),
      ],
    );
  }
}

// Data classes
class StatusInfo {
  final Color color;
  final IconData icon;
  final String label;

  StatusInfo({
    required this.color,
    required this.icon,
    required this.label,
  });
}

class DeliveryData {
  final String customerName;
  final String address;
  final String phone;
  final String? driverName;

  DeliveryData({
    required this.customerName,
    required this.address,
    required this.phone,
    this.driverName,
  });
}
