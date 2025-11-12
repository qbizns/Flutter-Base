/// Kitchen Display System Main Page
/// Real-time order display following Odoo KDS patterns 100%
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/kitchen_order.dart';
import '../../../../data/models/kitchen_station.dart';
import '../widgets/kds_order_card.dart';
import '../widgets/station_selector.dart';
import '../widgets/kds_stats_bar.dart';

/// KDS Display Page
class KdsDisplayPage extends ConsumerStatefulWidget {
  const KdsDisplayPage({super.key});

  @override
  ConsumerState<KdsDisplayPage> createState() => _KdsDisplayPageState();
}

class _KdsDisplayPageState extends ConsumerState<KdsDisplayPage> {
  KitchenStation _selectedStation = DefaultKitchenStations.defaultStation;
  KitchenOrderStatus? _filterStatus;
  bool _showCompletedOrders = false;

  // Mock data for development - will be replaced with real-time data
  List<KitchenOrder> _mockOrders = [];

  @override
  void initState() {
    super.initState();
    _loadMockOrders();
  }

  void _loadMockOrders() {
    // Mock orders for testing
    final now = DateTime.now();

    _mockOrders = [
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
          const KitchenOrderItem(
            id: '4',
            productId: 'salad-1',
            productName: 'Caesar Salad',
            categoryId: 'salads',
            categoryName: 'Salads',
            quantity: 1,
            basePrice: 8.99,
            isStarted: true,
            isCompleted: true,
          ),
        ],
        tableNumber: '5',
        tableName: 'Table 5',
        stationIds: ['grill', 'cold'],
        startedAt: now.subtract(const Duration(minutes: 15)),
        priority: OrderPriority.high,
        isUrgent: true,
      ),
      KitchenOrder(
        id: '3',
        orderNumber: 'ORD-003',
        createdAt: now.subtract(const Duration(minutes: 3)),
        status: KitchenOrderStatus.newOrder,
        items: [
          const KitchenOrderItem(
            id: '5',
            productId: 'pasta-1',
            productName: 'Spaghetti Carbonara',
            categoryId: 'pasta',
            categoryName: 'Pasta',
            quantity: 1,
            basePrice: 14.99,
          ),
          const KitchenOrderItem(
            id: '6',
            productId: 'drink-1',
            productName: 'Iced Tea',
            categoryId: 'drinks',
            categoryName: 'Drinks',
            quantity: 2,
            basePrice: 2.99,
          ),
        ],
        customerName: 'John Doe',
        stationIds: ['hot', 'bar'],
      ),
      KitchenOrder(
        id: '4',
        orderNumber: 'ORD-004',
        createdAt: now.subtract(const Duration(minutes: 8)),
        status: KitchenOrderStatus.preparing,
        items: [
          const KitchenOrderItem(
            id: '7',
            productId: 'chicken-1',
            productName: 'Grilled Chicken',
            categoryId: 'chicken',
            categoryName: 'Chicken',
            quantity: 3,
            basePrice: 16.99,
            isStarted: true,
          ),
        ],
        tableNumber: '8',
        tableName: 'Table 8',
        stationIds: ['grill'],
        startedAt: now.subtract(const Duration(minutes: 6)),
      ),
      KitchenOrder(
        id: '5',
        orderNumber: 'ORD-005',
        createdAt: now.subtract(const Duration(minutes: 1)),
        status: KitchenOrderStatus.ready,
        items: [
          const KitchenOrderItem(
            id: '8',
            productId: 'dessert-1',
            productName: 'Chocolate Cake',
            categoryId: 'desserts',
            categoryName: 'Desserts',
            quantity: 2,
            basePrice: 6.99,
            isStarted: true,
            isCompleted: true,
          ),
        ],
        tableNumber: '3',
        tableName: 'Table 3',
        stationIds: ['dessert'],
        startedAt: now.subtract(const Duration(minutes: 5)),
        readyAt: now.subtract(const Duration(minutes: 1)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _getFilteredOrders();

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      body: Column(
        children: [
          // KDS Header with station selector
          _buildHeader(),

          // Stats bar (orders count by status)
          KdsStatsBar(
            orders: _mockOrders,
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

  Widget _buildHeader() {
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
                // Settings button
                IconButton(
                  onPressed: () => _showSettings(),
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
            return KdsOrderCard(
              order: orders[index],
              onStatusChange: (newStatus) => _updateOrderStatus(
                orders[index],
                newStatus,
              ),
              onItemToggle: (item) => _toggleOrderItem(
                orders[index],
                item,
              ),
            );
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

  List<KitchenOrder> _getFilteredOrders() {
    return _mockOrders.where((order) {
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
    }).toList();
  }

  void _updateOrderStatus(KitchenOrder order, KitchenOrderStatus newStatus) {
    setState(() {
      final index = _mockOrders.indexWhere((o) => o.id == order.id);
      if (index != -1) {
        final now = DateTime.now();
        _mockOrders[index] = order.copyWith(
          status: newStatus,
          startedAt: newStatus == KitchenOrderStatus.preparing && order.startedAt == null
              ? now
              : order.startedAt,
          readyAt: newStatus == KitchenOrderStatus.ready && order.readyAt == null
              ? now
              : order.readyAt,
          completedAt: newStatus == KitchenOrderStatus.done && order.completedAt == null
              ? now
              : order.completedAt,
        );
      }
    });

    // TODO: Send status update to backend
  }

  void _toggleOrderItem(KitchenOrder order, KitchenOrderItem item) {
    setState(() {
      final orderIndex = _mockOrders.indexWhere((o) => o.id == order.id);
      if (orderIndex != -1) {
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

          _mockOrders[orderIndex] = order.copyWith(items: updatedItems);
        }
      }
    });
  }

  void _refreshOrders() {
    setState(() {
      _loadMockOrders();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Orders refreshed'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('KDS Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text('Show Completed Orders'),
              value: _showCompletedOrders,
              onChanged: (value) {
                setState(() {
                  _showCompletedOrders = value;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.volume_up),
              title: const Text('Sound Notifications'),
              trailing: const Switch(value: true, onChanged: null),
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Alert Threshold'),
              trailing: const Text('15 min'),
              onTap: () {
                // TODO: Show alert threshold dialog
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
