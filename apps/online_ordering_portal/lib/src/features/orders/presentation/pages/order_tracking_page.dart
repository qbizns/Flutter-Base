import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Order Tracking Page
///
/// Real-time order tracking with status updates.
/// Features:
/// - Live order status
/// - Timeline view of order progress
/// - Estimated delivery time
/// - Driver tracking (for delivery)
/// - Contact restaurant/driver
class OrderTrackingPage extends ConsumerWidget {
  const OrderTrackingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock order data
    final order = Order(
      id: '12345',
      status: OrderStatus.preparing,
      placedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      estimatedDelivery: DateTime.now().add(const Duration(minutes: 30)),
      items: [
        OrderItem(name: 'Classic Burger', quantity: 2, price: 12.99),
        OrderItem(name: 'Margherita Pizza', quantity: 1, price: 14.99),
        OrderItem(name: 'Caesar Salad', quantity: 1, price: 9.99),
      ],
      subtotal: 37.97,
      tax: 3.04,
      deliveryFee: 4.99,
      total: 46.00,
      deliveryAddress: '123 Main St, San Francisco, CA 94102',
      contactPhone: '+1 (555) 123-4567',
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${order.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Status card
          Card(
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    _getStatusIcon(order.status),
                    size: 64,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStatusSubtext(order.status),
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Estimated Delivery',
                              style: TextStyle(fontSize: 12),
                            ),
                            Text(
                              DateFormat('h:mm a').format(order.estimatedDelivery),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Progress timeline
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTimelineStep(
                    theme,
                    'Order Placed',
                    DateFormat('h:mm a').format(order.placedAt),
                    true,
                    true,
                  ),
                  _buildTimelineStep(
                    theme,
                    'Preparing',
                    'In progress',
                    true,
                    order.status.index > OrderStatus.preparing.index,
                  ),
                  _buildTimelineStep(
                    theme,
                    'Out for Delivery',
                    'Pending',
                    order.status.index >= OrderStatus.outForDelivery.index,
                    order.status.index > OrderStatus.outForDelivery.index,
                  ),
                  _buildTimelineStep(
                    theme,
                    'Delivered',
                    'Pending',
                    order.status == OrderStatus.delivered,
                    false,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Order items
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text('${item.quantity}x ${item.name}'),
                            ),
                            Text(
                              NumberFormat.currency(symbol: '\$')
                                  .format(item.price * item.quantity),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  _buildSummaryRow('Subtotal', order.subtotal),
                  _buildSummaryRow('Tax', order.tax),
                  _buildSummaryRow('Delivery', order.deliveryFee),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(order.total),
                        style: TextStyle(
                          fontSize: 20,
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
          const SizedBox(height: 24),

          // Delivery info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Delivery Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.location_on),
                      const SizedBox(width: 12),
                      Expanded(child: Text(order.deliveryAddress)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.phone),
                      const SizedBox(width: 12),
                      Text(order.contactPhone),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactRestaurant(context),
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Contact Restaurant'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _contactSupport(context),
                  icon: const Icon(Icons.help),
                  label: const Text('Support'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    ThemeData theme,
    String title,
    String subtitle,
    bool isActive,
    bool isCompleted, {
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted ? Icons.check : Icons.circle,
                color: isActive
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                size: isCompleted ? 24 : 12,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.surfaceVariant,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            NumberFormat.currency(symbol: '\$').format(amount),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return Icons.receipt_long;
      case OrderStatus.preparing:
        return Icons.restaurant;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining;
      case OrderStatus.delivered:
        return Icons.check_circle;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.preparing:
        return 'Preparing Your Order';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  String _getStatusSubtext(OrderStatus status) {
    switch (status) {
      case OrderStatus.placed:
        return 'Your order has been received';
      case OrderStatus.preparing:
        return 'The kitchen is working on your order';
      case OrderStatus.outForDelivery:
        return 'Your order is on the way';
      case OrderStatus.delivered:
        return 'Enjoy your meal!';
    }
  }

  void _contactRestaurant(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Restaurant'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.phone),
              title: Text('+1 (555) 987-6543'),
              subtitle: Text('Call restaurant'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.chat),
              title: Text('Live Chat'),
              subtitle: Text('Message the restaurant'),
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

  void _contactSupport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Support'),
        content: const Text(
          'Need help with your order? Our support team is available 24/7.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Contact Support'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Need Help?'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• You can track your order status in real-time'),
            SizedBox(height: 8),
            Text('• Contact the restaurant if you have special requests'),
            SizedBox(height: 8),
            Text('• Reach out to support for any issues'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

// Models
class Order {
  final String id;
  final OrderStatus status;
  final DateTime placedAt;
  final DateTime estimatedDelivery;
  final List<OrderItem> items;
  final double subtotal;
  final double tax;
  final double deliveryFee;
  final double total;
  final String deliveryAddress;
  final String contactPhone;

  Order({
    required this.id,
    required this.status,
    required this.placedAt,
    required this.estimatedDelivery,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.deliveryFee,
    required this.total,
    required this.deliveryAddress,
    required this.contactPhone,
  });
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
  });
}

enum OrderStatus {
  placed,
  preparing,
  outForDelivery,
  delivered,
}
