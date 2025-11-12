/// Enhanced KDS Display Page with Real-Time Updates
/// Integrated WebSocket, Sound Notifications, and Animations
/// Following Odoo KDS patterns 100%
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/kitchen_order.dart';
import '../../../../data/models/kitchen_station.dart';
import '../../../../data/services/kds_websocket_service.dart';
import '../../../../data/services/sound_notification_service.dart';
import '../widgets/kds_order_card_enhanced.dart';
import '../widgets/station_selector.dart';
import '../widgets/kds_stats_bar.dart';
import '../widgets/order_animations.dart';

/// Enhanced KDS Display Page with real-time features
class KdsDisplayPageEnhanced extends ConsumerStatefulWidget {
  const KdsDisplayPageEnhanced({super.key});

  @override
  ConsumerState<KdsDisplayPageEnhanced> createState() =>
      _KdsDisplayPageEnhancedState();
}

class _KdsDisplayPageEnhancedState
    extends ConsumerState<KdsDisplayPageEnhanced> {
  KitchenStation _selectedStation = DefaultKitchenStations.defaultStation;
  KitchenOrderStatus? _filterStatus;
  bool _showCompletedOrders = false;

  // Orders map for efficient updates
  final Map<String, KitchenOrder> _orders = {};
  final List<String> _newOrderIds = []; // Track newly added orders

  @override
  void initState() {
    super.initState();
    _loadInitialOrders();
    _connectWebSocket();
    _listenToOrderUpdates();
  }

  void _loadInitialOrders() {
    // Load initial mock orders
    final now = DateTime.now();

    final initialOrders = [
      KitchenOrder(
        id: '1',
        orderNumber: 'ORD-001',
        createdAt: now.subtract(const Duration(minutes: 5)),
        status: KitchenOrderStatus.newOrder,
        items: [
          const KitchenOrderItem(
            id: '1',
            productId: 'burger-1',
            productName: 'Classic Burger',
            categoryId: 'burgers',
            categoryName: 'Burgers',
            quantity: 2,
            basePrice: 12.99,
            modifiers: ['No Onions', 'Extra Cheese'],
          ),
          const KitchenOrderItem(
            id: '2',
            productId: 'fries-1',
            productName: 'French Fries',
            categoryId: 'sides',
            categoryName: 'Sides',
            quantity: 2,
            basePrice: 3.99,
          ),
        ],
        tableNumber: '12',
        tableName: 'Table 12',
        stationIds: ['grill', 'fryer'],
        notes: 'Customer has nut allergy',
        hasAllergyInfo: true,
      ),
      KitchenOrder(
        id: '2',
        orderNumber: 'ORD-002',
        createdAt: now.subtract(const Duration(minutes: 18)),
        status: KitchenOrderStatus.preparing,
        items: [
          const KitchenOrderItem(
            id: '3',
            productId: 'steak-1',
            productName: 'Ribeye Steak',
            categoryId: 'steaks',
            categoryName: 'Steaks',
            quantity: 1,
            basePrice: 24.99,
            modifiers: ['Medium Rare'],
            isStarted: true,
          ),
        ],
        tableNumber: '5',
        tableName: 'Table 5',
        stationIds: ['grill'],
        startedAt: now.subtract(const Duration(minutes: 15)),
        priority: OrderPriority.high,
        isUrgent: true,
      ),
    ];

    for (final order in initialOrders) {
      _orders[order.id] = order;
    }
  }

  void _connectWebSocket() {
    // Connect to WebSocket service (mock for development)
    final wsService = ref.read(mockKdsWebSocketServiceProvider);
    // Already auto-connected in provider
  }

  void _listenToOrderUpdates() {
    // Listen to order updates from WebSocket
    ref.listen(kdsOrderUpdatesProvider, (previous, next) {
      next.when(
        data: (order) => _handleOrderUpdate(order),
        loading: () {},
        error: (_, __) {},
      );
    });
  }

  void _handleOrderUpdate(KitchenOrder order) {
    final isNewOrder = !_orders.containsKey(order.id);

    setState(() {
      _orders[order.id] = order;

      if (isNewOrder) {
        _newOrderIds.add(order.id);

        // Play sound notification for new order
        _playNewOrderSound(order);

        // Remove from new list after animation
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _newOrderIds.remove(order.id);
            });
          }
        });
      }
    });
  }

  void _playNewOrderSound(KitchenOrder order) {
    final soundService = ref.read(soundNotificationServiceProvider);
    soundService.playNewOrder(order);
  }

  List<KitchenOrder> get _filteredOrders {
    return _orders.values.where((order) {
      // Filter by station
      if (_selectedStation.id != 'all') {
        if (!order.stationIds.contains(_selectedStation.id)) {
          return false;
        }
      }

      // Filter by status
      if (_filterStatus != null && order.status != _filterStatus) {
        return false;
      }

      // Hide completed orders unless showing them
      if (!_showCompletedOrders &&
          (order.status == KitchenOrderStatus.done ||
              order.status == KitchenOrderStatus.cancelled)) {
        return false;
      }

      return true;
    }).toList()
      ..sort((a, b) {
        // Sort by priority first
        final priorityCompare =
            a.priority.sortOrder.compareTo(b.priority.sortOrder);
        if (priorityCompare != 0) return priorityCompare;

        // Then by created time (oldest first)
        return a.createdAt.compareTo(b.createdAt);
      });
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _filteredOrders;
    final wsStatus = ref.watch(kdsWebSocketStatusProvider);

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      body: Column(
        children: [
          // KDS Header with station selector
          _buildHeader(wsStatus),

          // Stats bar (orders count by status)
          KdsStatsBar(
            orders: _orders.values.toList(),
            selectedStatus: _filterStatus,
            onStatusTap: (status) {
              setState(() {
                _filterStatus = _filterStatus == status ? null : status;
              });
            },
          ),

          // Orders grid
          Expanded(
            child: filteredOrders.isEmpty
                ? _buildEmptyState()
                : _buildOrdersGrid(filteredOrders),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(AsyncValue<WebSocketStatus> wsStatus) {
    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: const BoxDecoration(
        color: VodoColors.primary,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.restaurant_menu,
                  color: VodoColors.textOnPrimary,
                  size: 32,
                ),
                const SizedBox(width: VodoDimensions.spacingSm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kitchen Display',
                        style: VodoTextStyles.headlineSmall.copyWith(
                          color: VodoColors.textOnPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _selectedStation.name,
                        style: VodoTextStyles.bodyMedium.copyWith(
                          color: VodoColors.textOnPrimary.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                // WebSocket status indicator
                _buildConnectionIndicator(wsStatus),

                const SizedBox(width: VodoDimensions.spacingSm),

                // Analytics button
                IconButton(
                  onPressed: () => context.push('/analytics'),
                  icon: const Icon(Icons.analytics),
                  color: VodoColors.textOnPrimary,
                  tooltip: 'Analytics',
                ),

                // Settings button
                IconButton(
                  onPressed: () => context.push('/settings'),
                  icon: const Icon(Icons.settings),
                  color: VodoColors.textOnPrimary,
                  tooltip: 'Settings',
                ),

                // Refresh button
                IconButton(
                  onPressed: () => _refreshOrders(),
                  icon: const Icon(Icons.refresh),
                  color: VodoColors.textOnPrimary,
                  tooltip: 'Refresh',
                ),
              ],
            ),

            const SizedBox(height: VodoDimensions.spacingSm),

            // Station selector
            StationSelector(
              stations: DefaultKitchenStations.getActiveStations(),
              selectedStation: _selectedStation,
              onStationSelected: (station) {
                setState(() {
                  _selectedStation = station;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator(AsyncValue<WebSocketStatus> wsStatus) {
    return wsStatus.when(
      data: (status) {
        final color = switch (status) {
          WebSocketStatus.connected => VodoColors.success,
          WebSocketStatus.connecting => VodoColors.warning,
          WebSocketStatus.reconnecting => VodoColors.warning,
          WebSocketStatus.disconnected => VodoColors.textSecondary,
          WebSocketStatus.error => VodoColors.danger,
        };

        final icon = switch (status) {
          WebSocketStatus.connected => Icons.cloud_done,
          WebSocketStatus.connecting => Icons.cloud_sync,
          WebSocketStatus.reconnecting => Icons.cloud_sync,
          WebSocketStatus.disconnected => Icons.cloud_off,
          WebSocketStatus.error => Icons.cloud_off,
        };

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: VodoColors.textOnPrimary.withOpacity(0.2),
            borderRadius: VodoDimensions.borderRadiusSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                status == WebSocketStatus.connected ? 'Live' : 'Offline',
                style: VodoTextStyles.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const Icon(
        Icons.error,
        size: 16,
        color: VodoColors.danger,
      ),
    );
  }

  Widget _buildOrdersGrid(List<KitchenOrder> orders) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive column count based on screen width
        int crossAxisCount = 2;
        if (constraints.maxWidth > 1600) {
          crossAxisCount = 4;
        } else if (constraints.maxWidth > 1200) {
          crossAxisCount = 3;
        }

        return GridView.builder(
          padding: VodoDimensions.paddingMd,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 0.85,
            crossAxisSpacing: VodoDimensions.spacingMd,
            mainAxisSpacing: VodoDimensions.spacingMd,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final order = orders[index];
            final isNew = _newOrderIds.contains(order.id);

            Widget orderCard = KdsOrderCardEnhanced(
              order: order,
              onStatusChange: (newStatus) => _updateOrderStatus(
                order,
                newStatus,
              ),
              onItemToggle: (item) => _toggleOrderItem(
                order,
                item,
              ),
            );

            // Wrap new orders with entrance animation
            if (isNew) {
              orderCard = OrderEntranceAnimation(child: orderCard);
            }

            // Wrap new orders with glow animation
            if (order.status == KitchenOrderStatus.newOrder) {
              orderCard = NewOrderAlertAnimation(
                glowColor: VodoColors.primary,
                enabled: isNew,
                child: orderCard,
              );
            }

            return orderCard;
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant,
            size: 80,
            color: VodoColors.textTertiary.withOpacity(0.3),
          ),
          const SizedBox(height: VodoDimensions.spacingMd),
          Text(
            'No Orders',
            style: VodoTextStyles.headlineSmall.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          Text(
            _filterStatus != null
                ? 'No orders with ${_filterStatus!.displayName} status'
                : 'All orders completed!',
            style: VodoTextStyles.bodyMedium.copyWith(
              color: VodoColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _updateOrderStatus(KitchenOrder order, KitchenOrderStatus newStatus) {
    setState(() {
      final now = DateTime.now();
      _orders[order.id] = order.copyWith(
        status: newStatus,
        startedAt: newStatus == KitchenOrderStatus.preparing &&
                order.startedAt == null
            ? now
            : order.startedAt,
        readyAt:
            newStatus == KitchenOrderStatus.ready && order.readyAt == null
                ? now
                : order.readyAt,
        completedAt:
            newStatus == KitchenOrderStatus.done && order.completedAt == null
                ? now
                : order.completedAt,
      );
    });

    // Play sound for status changes
    final soundService = ref.read(soundNotificationServiceProvider);
    if (newStatus == KitchenOrderStatus.ready) {
      soundService.playOrderReady();
    }

    // TODO: Send status update to backend via WebSocket
  }

  void _toggleOrderItem(KitchenOrder order, KitchenOrderItem item) {
    setState(() {
      final itemIndex = order.items.indexWhere((i) => i.id == item.id);
      if (itemIndex != -1) {
        final now = DateTime.now();
        final updatedItem = item.copyWith(
          isStarted: !item.isStarted ? true : item.isStarted,
          isCompleted: !item.isCompleted,
          startedAt: !item.isStarted ? now : item.startedAt,
          completedAt: !item.isCompleted ? now : null,
        );

        final updatedItems = List<KitchenOrderItem>.from(order.items);
        updatedItems[itemIndex] = updatedItem;

        _orders[order.id] = order.copyWith(items: updatedItems);
      }
    });

    // Play sound for item completion
    if (!item.isCompleted) {
      final soundService = ref.read(soundNotificationServiceProvider);
      soundService.playItemCompleted();
    }
  }

  void _refreshOrders() {
    setState(() {
      _loadInitialOrders();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Orders refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

}
