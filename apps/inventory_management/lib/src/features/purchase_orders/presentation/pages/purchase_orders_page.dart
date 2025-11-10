import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Purchase Orders Management Page
///
/// Features:
/// - List of all purchase orders
/// - Filter by status (draft, ordered, received, cancelled)
/// - Create new purchase orders
/// - Edit draft orders
/// - Mark orders as received
/// - Track order history
/// - Calculate total costs
class PurchaseOrdersPage extends ConsumerStatefulWidget {
  const PurchaseOrdersPage({super.key});

  @override
  ConsumerState<PurchaseOrdersPage> createState() => _PurchaseOrdersPageState();
}

class _PurchaseOrdersPageState extends ConsumerState<PurchaseOrdersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock data - in real app would use provider
    final allOrders = _getMockPurchaseOrders();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh purchase orders
            },
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(
              text: 'All (${allOrders.length})',
              icon: const Icon(Icons.list_alt),
            ),
            Tab(
              text: 'Draft (${allOrders.where((o) => o.status == POStatus.draft).length})',
              icon: const Icon(Icons.drafts),
            ),
            Tab(
              text: 'Ordered (${allOrders.where((o) => o.status == POStatus.ordered).length})',
              icon: const Icon(Icons.shopping_cart),
            ),
            Tab(
              text: 'Received (${allOrders.where((o) => o.status == POStatus.received).length})',
              icon: const Icon(Icons.check_circle),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(context),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOrdersList(context, allOrders),
                _buildOrdersList(
                  context,
                  allOrders.where((o) => o.status == POStatus.draft).toList(),
                ),
                _buildOrdersList(
                  context,
                  allOrders.where((o) => o.status == POStatus.ordered).toList(),
                ),
                _buildOrdersList(
                  context,
                  allOrders.where((o) => o.status == POStatus.received).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCreatePurchaseOrderDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search orders...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, List<PurchaseOrder> orders) {
    final theme = Theme.of(context);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No purchase orders',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a new order to get started',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        return _buildPurchaseOrderCard(context, orders[index]);
      },
    );
  }

  Widget _buildPurchaseOrderCard(BuildContext context, PurchaseOrder order) {
    final theme = Theme.of(context);
    final statusInfo = _getStatusInfo(order.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          _showOrderDetailsDialog(context, order);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PO #${order.orderNumber}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.supplierName,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusInfo.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Order details
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, yyyy').format(order.orderDate),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.inventory_2,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${order.items.length} items',
                    style: theme.textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),

              if (order.expectedDelivery != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Expected: ${DateFormat('MMM d').format(order.expectedDelivery!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],

              // Actions
              const SizedBox(height: 12),
              Row(
                children: [
                  if (order.status == POStatus.draft) ...[
                    TextButton.icon(
                      onPressed: () {
                        _showCreatePurchaseOrderDialog(context, order: order);
                      },
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () {
                        _confirmOrder(context, order);
                      },
                      icon: const Icon(Icons.send, size: 18),
                      label: const Text('Confirm Order'),
                    ),
                  ],
                  if (order.status == POStatus.ordered) ...[
                    FilledButton.icon(
                      onPressed: () {
                        _receiveOrder(context, order);
                      },
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Mark as Received'),
                    ),
                  ],
                  if (order.status == POStatus.received) ...[
                    TextButton.icon(
                      onPressed: () {
                        _showOrderDetailsDialog(context, order);
                      },
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View Details'),
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

  void _showCreatePurchaseOrderDialog(BuildContext context, {PurchaseOrder? order}) {
    showDialog(
      context: context,
      builder: (context) => _CreatePurchaseOrderDialog(order: order),
    );
  }

  void _showOrderDetailsDialog(BuildContext context, PurchaseOrder order) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase Order #${order.orderNumber}'),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Supplier', order.supplierName),
                _buildDetailRow(
                  'Order Date',
                  DateFormat('MMM d, yyyy').format(order.orderDate),
                ),
                if (order.expectedDelivery != null)
                  _buildDetailRow(
                    'Expected Delivery',
                    DateFormat('MMM d, yyyy').format(order.expectedDelivery!),
                  ),
                _buildDetailRow('Status', _getStatusInfo(order.status).label),
                const Divider(),
                Text(
                  'Items',
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
                          Expanded(
                            child: Text(
                              '${item.productName} x${item.quantity}',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            '\$${item.totalPrice.toStringAsFixed(2)}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                      '\$${order.totalAmount.toStringAsFixed(2)}',
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  void _confirmOrder(BuildContext context, PurchaseOrder order) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Order #${order.orderNumber} confirmed and sent to supplier'),
        backgroundColor: Colors.green,
      ),
    );
    // In real app: update order status to 'ordered'
  }

  void _receiveOrder(BuildContext context, PurchaseOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Receive Order'),
        content: Text(
          'Mark order #${order.orderNumber} as received?\n\nThis will update stock levels for all items.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Order #${order.orderNumber} received. Stock updated.'),
                  backgroundColor: Colors.green,
                ),
              );
              // In real app: update order status and stock levels
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  StatusInfo _getStatusInfo(POStatus status) {
    switch (status) {
      case POStatus.draft:
        return StatusInfo(
          color: Colors.grey,
          icon: Icons.drafts,
          label: 'Draft',
        );
      case POStatus.ordered:
        return StatusInfo(
          color: Colors.blue,
          icon: Icons.shopping_cart,
          label: 'Ordered',
        );
      case POStatus.received:
        return StatusInfo(
          color: Colors.green,
          icon: Icons.check_circle,
          label: 'Received',
        );
      case POStatus.cancelled:
        return StatusInfo(
          color: Colors.red,
          icon: Icons.cancel,
          label: 'Cancelled',
        );
    }
  }

  // Mock data
  List<PurchaseOrder> _getMockPurchaseOrders() {
    return [
      PurchaseOrder(
        id: '1',
        orderNumber: '2024-001',
        supplierName: 'Fresh Foods Supplier',
        orderDate: DateTime.now().subtract(const Duration(days: 2)),
        expectedDelivery: DateTime.now().add(const Duration(days: 1)),
        status: POStatus.ordered,
        items: [
          POItem(productName: 'Tomatoes', quantity: 50, unitPrice: 2.50, totalPrice: 125),
          POItem(productName: 'Lettuce', quantity: 30, unitPrice: 1.80, totalPrice: 54),
        ],
        totalAmount: 179,
      ),
      PurchaseOrder(
        id: '2',
        orderNumber: '2024-002',
        supplierName: 'Beverage Distributors',
        orderDate: DateTime.now().subtract(const Duration(days: 5)),
        expectedDelivery: null,
        status: POStatus.received,
        items: [
          POItem(productName: 'Coca Cola', quantity: 100, unitPrice: 1.20, totalPrice: 120),
          POItem(productName: 'Sprite', quantity: 80, unitPrice: 1.20, totalPrice: 96),
        ],
        totalAmount: 216,
      ),
      PurchaseOrder(
        id: '3',
        orderNumber: '2024-003',
        supplierName: 'Fresh Foods Supplier',
        orderDate: DateTime.now(),
        expectedDelivery: DateTime.now().add(const Duration(days: 3)),
        status: POStatus.draft,
        items: [
          POItem(productName: 'Chicken Breast', quantity: 40, unitPrice: 5.50, totalPrice: 220),
        ],
        totalAmount: 220,
      ),
    ];
  }
}

// Create Purchase Order Dialog
class _CreatePurchaseOrderDialog extends StatefulWidget {
  const _CreatePurchaseOrderDialog({this.order});

  final PurchaseOrder? order;

  @override
  State<_CreatePurchaseOrderDialog> createState() => _CreatePurchaseOrderDialogState();
}

class _CreatePurchaseOrderDialogState extends State<_CreatePurchaseOrderDialog> {
  final _formKey = GlobalKey<FormState>();
  String _supplierName = '';
  DateTime _expectedDelivery = DateTime.now().add(const Duration(days: 7));

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _supplierName = widget.order!.supplierName;
      _expectedDelivery = widget.order!.expectedDelivery ?? _expectedDelivery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.order != null;

    return AlertDialog(
      title: Text(isEdit ? 'Edit Purchase Order' : 'Create Purchase Order'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Supplier',
                    border: OutlineInputBorder(),
                  ),
                  value: _supplierName.isEmpty ? null : _supplierName,
                  items: const [
                    DropdownMenuItem(
                      value: 'Fresh Foods Supplier',
                      child: Text('Fresh Foods Supplier'),
                    ),
                    DropdownMenuItem(
                      value: 'Beverage Distributors',
                      child: Text('Beverage Distributors'),
                    ),
                    DropdownMenuItem(
                      value: 'Meat & Poultry Co',
                      child: Text('Meat & Poultry Co'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _supplierName = value ?? '';
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a supplier';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Expected Delivery Date'),
                  subtitle: Text(DateFormat('MMM d, yyyy').format(_expectedDelivery)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _expectedDelivery,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _expectedDelivery = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'Add items on the next screen',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isEdit ? 'Order updated' : 'Order created as draft'),
                  backgroundColor: Colors.green,
                ),
              );
              // In real app: save purchase order
            }
          },
          child: Text(isEdit ? 'Update' : 'Create'),
        ),
      ],
    );
  }
}

// Data classes
enum POStatus { draft, ordered, received, cancelled }

class PurchaseOrder {
  final String id;
  final String orderNumber;
  final String supplierName;
  final DateTime orderDate;
  final DateTime? expectedDelivery;
  final POStatus status;
  final List<POItem> items;
  final double totalAmount;

  PurchaseOrder({
    required this.id,
    required this.orderNumber,
    required this.supplierName,
    required this.orderDate,
    required this.expectedDelivery,
    required this.status,
    required this.items,
    required this.totalAmount,
  });
}

class POItem {
  final String productName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  POItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

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
