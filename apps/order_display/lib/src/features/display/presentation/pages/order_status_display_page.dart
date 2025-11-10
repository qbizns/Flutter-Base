import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Customer Order Status Display - Large Screen Display
///
/// Features:
/// - Large, easy-to-read order numbers
/// - "Now Serving" prominent display
/// - "Ready for Pickup" grid
/// - Real-time updates
/// - Color-coded status
/// - Auto-refresh
/// - Animations for new orders
class OrderStatusDisplayPage extends ConsumerStatefulWidget {
  const OrderStatusDisplayPage({super.key});

  @override
  ConsumerState<OrderStatusDisplayPage> createState() => _OrderStatusDisplayPageState();
}

class _OrderStatusDisplayPageState extends ConsumerState<OrderStatusDisplayPage>
    with TickerProviderStateMixin {
  Timer? _refreshTimer;
  final List<String> _recentlyAdded = [];
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Set up pulse animation for "Now Serving"
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Auto-refresh every 3 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      ref.invalidate(ordersProvider);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final ordersAsync = ref.watch(ordersProvider());

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: ordersAsync.when(
        data: (orders) {
          // Filter orders by status
          final nowServing = orders
              .where((o) => o.status == OrderStatus.ready)
              .take(1)
              .toList();

          final readyOrders = orders
              .where((o) => o.status == OrderStatus.ready)
              .skip(1) // Skip the "now serving" order
              .take(15)
              .toList();

          final preparingOrders = orders
              .where((o) => o.status == OrderStatus.preparing)
              .take(5)
              .toList();

          return Column(
            children: [
              // Header
              _buildHeader(context),

              // Main content area
              Expanded(
                child: Row(
                  children: [
                    // Left side - Now Serving (60% width)
                    Expanded(
                      flex: 6,
                      child: _buildNowServingSection(context, nowServing),
                    ),

                    // Divider
                    Container(
                      width: 2,
                      color: theme.colorScheme.outline.withOpacity(0.3),
                    ),

                    // Right side - Ready for Pickup (40% width)
                    Expanded(
                      flex: 4,
                      child: _buildReadyForPickupSection(context, readyOrders),
                    ),
                  ],
                ),
              ),

              // Footer - Preparing orders ticker
              _buildPreparingOrdersTicker(context, preparingOrders),
            ],
          );
        },
        loading: () => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                strokeWidth: 6,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Loading Orders...',
                style: theme.textTheme.displaySmall,
              ),
            ],
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 120,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 24),
              Text(
                'Unable to load orders',
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref.invalidate(ordersProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo and title
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: theme.colorScheme.onPrimary,
          ),
          const SizedBox(width: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SmartPOS Restaurant',
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Order Status Display',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Time and date
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormat('h:mm a').format(now),
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                DateFormat('EEEE, MMMM d').format(now),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNowServingSection(BuildContext context, List<Order> orders) {
    final theme = Theme.of(context);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 120,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No orders ready',
              style: theme.textTheme.displayLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please wait...',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
              ),
            ),
          ],
        ),
      );
    }

    final order = orders.first;

    return Container(
      color: theme.colorScheme.primaryContainer,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // "Now Serving" label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'NOW SERVING',
                style: theme.textTheme.displayLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8,
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Order number with pulse animation
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.5),
                      blurRadius: 48,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  order.orderNumber,
                  style: TextStyle(
                    fontSize: 180,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
                    letterSpacing: 16,
                    height: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 48),

            // Order type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getOrderTypeIcon(order.orderType),
                    size: 36,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getOrderTypeName(order.orderType),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyForPickupSection(BuildContext context, List<Order> orders) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'READY FOR PICKUP',
              textAlign: TextAlign.center,
              style: theme.textTheme.displaySmall?.copyWith(
                color: theme.colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Order grid
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 80,
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'All caught up!',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 2.0,
                    ),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      return _buildReadyOrderCard(context, orders[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyOrderCard(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final isNew = _recentlyAdded.contains(order.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isNew
            ? theme.colorScheme.tertiaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 2,
        ),
        boxShadow: isNew
            ? [
                BoxShadow(
                  color: theme.colorScheme.tertiary.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              order.orderNumber,
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: isNew
                    ? theme.colorScheme.onTertiaryContainer
                    : theme.colorScheme.onSurface,
                letterSpacing: 8,
                height: 1,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getOrderTypeIcon(order.orderType),
                  size: 20,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 8),
                Text(
                  _getOrderTypeName(order.orderType),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreparingOrdersTicker(BuildContext context, List<Order> orders) {
    final theme = Theme.of(context);

    if (orders.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 200,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            color: theme.colorScheme.tertiaryContainer,
            child: Center(
              child: Text(
                'PREPARING',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: theme.colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      order.orderNumber,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return Icons.restaurant;
      case OrderType.takeaway:
        return Icons.shopping_bag;
      case OrderType.delivery:
        return Icons.delivery_dining;
    }
  }

  String _getOrderTypeName(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine-In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
    }
  }
}
