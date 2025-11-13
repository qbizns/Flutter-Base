/// Kitchen Display System Main Page
/// Real-time order display following Odoo KDS patterns 100%
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/kitchen_order.dart';
import '../../../../data/models/kitchen_station.dart';
import '../../../../data/providers/kds_realtime_orders_provider.dart';
import '../../../../data/services/kds_websocket_service.dart';
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

  @override
  void initState() {
    super.initState();
    // Real-time orders are managed by provider
    // No need for mock data initialization
  }

  @override
  Widget build(BuildContext context) {
    // Watch orders state from provider
    final ordersState = ref.watch(kdsRealtimeOrdersProvider);
    final connectionStatus = ordersState.connectionStatus;
    final allOrders = ordersState.ordersList;

    // Filter orders by station and status
    final filteredOrders = _getFilteredOrders(allOrders);

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      body: Column(
        children: [
          // KDS Header with station selector and connection status
          _buildHeader(connectionStatus),

          // Show error banner if exists
          if (ordersState.error != null) _buildErrorBanner(ordersState.error!),

          // Stats bar (orders count by status)
          KdsStatsBar(
            orders: allOrders,
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

  Widget _buildHeader(WebSocketStatus connectionStatus) {
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
                      Row(
                        children: [
                          Text(
                            'Kitchen Display',
                            style: VodoTextStyles.headlineSmall.copyWith(
                              color: VodoColors.textOnPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: VodoDimensions.spacingSm),
                          _buildConnectionIndicator(connectionStatus),
                        ],
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
                // Reconnect button
                IconButton(
                  onPressed: () => _reconnect(),
                  icon: const Icon(Icons.refresh),
                  color: VodoColors.textOnPrimary,
                  tooltip: 'Reconnect',
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

  Widget _buildConnectionIndicator(WebSocketStatus status) {
    Color color;
    String text;

    switch (status) {
      case WebSocketStatus.connected:
        color = Colors.greenAccent;
        text = 'Connected';
        break;
      case WebSocketStatus.connecting:
      case WebSocketStatus.reconnecting:
        color = Colors.orangeAccent;
        text = 'Connecting...';
        break;
      case WebSocketStatus.disconnected:
      case WebSocketStatus.error:
        color = Colors.redAccent;
        text = 'Disconnected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: VodoTextStyles.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String error) {
    return Container(
      width: double.infinity,
      padding: VodoDimensions.paddingSm,
      color: Colors.red.withOpacity(0.1),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 20),
          const SizedBox(width: VodoDimensions.spacingSm),
          Expanded(
            child: Text(
              error,
              style: VodoTextStyles.bodySmall.copyWith(color: Colors.red),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () {
              ref.read(kdsRealtimeOrdersProvider.notifier).clearError();
            },
            color: Colors.red,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
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

  List<KitchenOrder> _getFilteredOrders(List<KitchenOrder> allOrders) {
    return allOrders.where((order) {
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
    // Update via provider (optimistic update + backend sync)
    ref.read(kdsRealtimeOrdersProvider.notifier).updateOrderStatus(
          order.id,
          newStatus,
        );
  }

  void _toggleOrderItem(KitchenOrder order, KitchenOrderItem item) {
    // Toggle item completion via provider
    ref.read(kdsRealtimeOrdersProvider.notifier).toggleItemCompletion(
          order.id,
          item.id,
        );
  }

  void _reconnect() {
    // Reconnect to WebSocket
    ref.read(kdsRealtimeOrdersProvider.notifier).reconnect();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reconnecting...'),
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
