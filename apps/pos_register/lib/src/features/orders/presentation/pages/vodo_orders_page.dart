/// Vodo Orders Page
/// Odoo-style orders management page
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../widgets/vodo_orders_list.dart';

/// Orders page with Vodo styling and Odoo patterns
class VodoOrdersPage extends ConsumerStatefulWidget {
  const VodoOrdersPage({super.key});

  @override
  ConsumerState<VodoOrdersPage> createState() => _VodoOrdersPageState();
}

class _VodoOrdersPageState extends ConsumerState<VodoOrdersPage> {
  VodoOrderStatus? _selectedStatus;
  String _searchQuery = '';
  List<VodoOrder> _orders = [];

  @override
  void initState() {
    super.initState();
    // Load mock orders
    _orders = VodoOrder.getMockOrders();
  }

  Map<VodoOrderStatus, int> get _statusCounts {
    final counts = <VodoOrderStatus, int>{};
    for (final status in VodoOrderStatus.values) {
      counts[status] = _orders.where((o) => o.status == status).length;
    }
    return counts;
  }

  List<VodoOrder> get _filteredOrders {
    var filtered = _orders;

    // Apply status filter
    if (_selectedStatus != null) {
      filtered = filtered.where((o) => o.status == _selectedStatus).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((o) {
        return o.number.toLowerCase().contains(query) ||
            (o.customerName?.toLowerCase().contains(query) ?? false) ||
            (o.tableName?.toLowerCase().contains(query) ?? false) ||
            o.cashierName.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'Orders',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          // Search button
          IconButton(
            onPressed: _showSearchDialog,
            icon: const Icon(Icons.search),
            tooltip: 'Search orders',
          ),
          // Refresh button
          IconButton(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh orders',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter chips (Odoo-style)
          VodoOrderStatusFilter(
            selectedStatus: _selectedStatus,
            onStatusChanged: (status) {
              setState(() => _selectedStatus = status);
            },
            statusCounts: _statusCounts,
          ),

          // Search results info (if searching)
          if (_searchQuery.isNotEmpty)
            Container(
              padding: VodoDimensions.paddingSm,
              color: VodoColors.info.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.search, size: 16, color: VodoColors.info),
                  const SizedBox(width: VodoDimensions.spacingSm),
                  Expanded(
                    child: Text(
                      'Searching for "$_searchQuery" - ${_filteredOrders.length} results',
                      style: VodoTextStyles.bodySmall.copyWith(
                        color: VodoColors.info,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(Icons.close, size: 18),
                    color: VodoColors.info,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // Orders list
          Expanded(
            child: VodoOrdersList(
              orders: _filteredOrders,
              onOrderTap: _handleOrderTap,
              statusFilter: null, // Already filtered
            ),
          ),
        ],
      ),

      // Floating action button (add new order)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleNewOrder,
        backgroundColor: VodoColors.success,
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Orders'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter order number, customer, or table...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _handleRefresh() {
    // TODO: Implement refresh from backend
    setState(() {
      _orders = VodoOrder.getMockOrders();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orders refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleOrderTap(VodoOrder order) {
    // Navigate to order details (to be implemented)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening order ${order.number}...'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleNewOrder() {
    // Navigate back to POS to create new order
    Navigator.of(context).pop();
  }
}
