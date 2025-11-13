import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../widgets/order_details_dialog.dart';
import '../services/export_service.dart';

/// Sales Page - Comprehensive orders management
///
/// Features:
/// - Orders list with DataTable2
/// - Date range, status, payment method filters
/// - Search by order number, customer, or table
/// - Order details dialog
/// - Refund functionality
/// - Export to CSV/PDF
class SalesPage extends ConsumerStatefulWidget {
  const SalesPage({super.key});

  @override
  ConsumerState<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends ConsumerState<SalesPage> {
  // Search and filters
  final _searchController = TextEditingController();
  String _searchQuery = '';
  OrderStatus? _selectedStatus;
  PaymentStatus? _selectedPaymentStatus;
  OrderType? _selectedOrderType;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isLoading = false;
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider());

    return Container(
      color: OdooColors.backgroundLight,
      child: Column(
        children: [
          // Toolbar
          _buildToolbar(ordersAsync),

          // Search and Filters
          Container(
            padding: const EdgeInsets.all(OdooSpacing.lg),
            child: Column(
              children: [
                _buildSearchBar(),
                const SizedBox(height: OdooSpacing.md),
                _buildFilters(),
              ],
            ),
          ),

          // Orders Table
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filteredOrders = _filterOrders(orders);

                if (filteredOrders.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildOrdersTable(filteredOrders);
              },
              loading: () => Center(
                child: CircularProgressIndicator(
                  color: OdooColors.primary,
                ),
              ),
              error: (error, stackTrace) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(AsyncValue<List<Order>> ordersAsync) {
    final orderCount = ordersAsync.maybeWhen(
      data: (orders) => _filterOrders(orders).length,
      orElse: () => 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.xl,
        vertical: OdooSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: OdooIconSizes.xl,
            color: OdooColors.primary,
          ),
          const SizedBox(width: OdooSpacing.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sales & Orders',
                style: OdooTypography.pageTitle.copyWith(
                  color: OdooColors.textPrimary,
                ),
              ),
              Text(
                '$orderCount orders found',
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Export button
          OutlinedButton.icon(
            onPressed: () => _exportOrders(),
            icon: const Icon(Icons.download),
            label: const Text('Export'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: OdooSpacing.lg,
                vertical: OdooSpacing.md,
              ),
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          // Refresh button
          IconButton(
            onPressed: () => ref.invalidate(ordersProvider),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            style: IconButton.styleFrom(
              backgroundColor: OdooColors.gray100,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search by order number, table, or amount...',
        prefixIcon: Icon(
          Icons.search,
          color: OdooColors.textSecondary,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Date Range Filter
          OutlinedButton.icon(
            onPressed: () => _selectDateRange(context),
            icon: const Icon(Icons.date_range),
            label: Text(
              _startDate != null && _endDate != null
                  ? '${DateFormat('MMM d').format(_startDate!)} - ${DateFormat('MMM d').format(_endDate!)}'
                  : 'Date Range',
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  _startDate != null ? OdooColors.primary.withOpacity(0.1) : null,
            ),
          ),
          const SizedBox(width: OdooSpacing.md),

          // Status Filter
          _buildFilterChip(
            label: _selectedStatus != null
                ? _getStatusText(_selectedStatus!)
                : 'Status',
            icon: Icons.info_outline,
            isSelected: _selectedStatus != null,
            onPressed: () => _showStatusFilter(context),
            onClear: _selectedStatus != null
                ? () => setState(() => _selectedStatus = null)
                : null,
          ),
          const SizedBox(width: OdooSpacing.md),

          // Payment Status Filter
          _buildFilterChip(
            label: _selectedPaymentStatus != null
                ? _getPaymentStatusText(_selectedPaymentStatus!)
                : 'Payment',
            icon: Icons.payment,
            isSelected: _selectedPaymentStatus != null,
            onPressed: () => _showPaymentStatusFilter(context),
            onClear: _selectedPaymentStatus != null
                ? () => setState(() => _selectedPaymentStatus = null)
                : null,
          ),
          const SizedBox(width: OdooSpacing.md),

          // Order Type Filter
          _buildFilterChip(
            label: _selectedOrderType != null
                ? _getOrderTypeText(_selectedOrderType!)
                : 'Order Type',
            icon: Icons.restaurant,
            isSelected: _selectedOrderType != null,
            onPressed: () => _showOrderTypeFilter(context),
            onClear: _selectedOrderType != null
                ? () => setState(() => _selectedOrderType = null)
                : null,
          ),
          const SizedBox(width: OdooSpacing.md),

          // Clear All Filters
          if (_hasActiveFilters())
            TextButton.icon(
              onPressed: _clearAllFilters,
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear All'),
              style: TextButton.styleFrom(
                foregroundColor: OdooColors.danger,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
    VoidCallback? onClear,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: OdooIconSizes.sm),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (onClear != null) ...[
            const SizedBox(width: OdooSpacing.xs),
            InkWell(
              onTap: onClear,
              child: Icon(
                Icons.close,
                size: OdooIconSizes.sm,
              ),
            ),
          ],
        ],
      ),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? OdooColors.primary.withOpacity(0.1) : null,
        foregroundColor: isSelected ? OdooColors.primary : null,
      ),
    );
  }

  Widget _buildOrdersTable(List<Order> orders) {
    return Card(
      margin: const EdgeInsets.all(OdooSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.md),
        child: DataTable2(
          columnSpacing: OdooSpacing.lg,
          horizontalMargin: OdooSpacing.lg,
          minWidth: 1000,
          headingRowColor: WidgetStateProperty.all(OdooColors.gray50),
          headingTextStyle: OdooTypography.tableHeader.copyWith(
            color: OdooColors.textPrimary,
          ),
          dataTextStyle: OdooTypography.tableCell,
          columns: [
            DataColumn2(
              label: Text('ORDER #'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('DATE & TIME'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('TABLE'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('TYPE'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('ITEMS'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('AMOUNT'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('PAYMENT'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('STATUS'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('ACTIONS'),
              size: ColumnSize.M,
              numeric: true,
            ),
          ],
          rows: orders.map((order) => _buildOrderRow(order)).toList(),
        ),
      ),
    );
  }

  DataRow2 _buildOrderRow(Order order) {
    return DataRow2(
      onTap: () => _showOrderDetails(order),
      cells: [
        // Order Number
        DataCell(
          Text(
            '#${order.orderNumber}',
            style: OdooTypography.tableCell.copyWith(
              fontWeight: FontWeight.w700,
              color: OdooColors.primary,
            ),
          ),
        ),

        // Date & Time
        DataCell(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat('MMM d, yyyy').format(order.createdAt),
                style: OdooTypography.tableCell,
              ),
              Text(
                DateFormat('h:mm a').format(order.createdAt),
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Table
        DataCell(
          Row(
            children: [
              Icon(
                Icons.table_restaurant,
                size: OdooIconSizes.sm,
                color: OdooColors.textSecondary,
              ),
              const SizedBox(width: OdooSpacing.xs),
              Text('Table ${(order.id.hashCode % 20) + 1}'),
            ],
          ),
        ),

        // Order Type
        DataCell(
          Row(
            children: [
              Icon(
                _getOrderTypeIcon(order.orderType),
                size: OdooIconSizes.sm,
                color: OdooColors.textSecondary,
              ),
              const SizedBox(width: OdooSpacing.xs),
              Text(_getOrderTypeText(order.orderType)),
            ],
          ),
        ),

        // Items Count
        DataCell(
          Text('${order.items.length} items'),
        ),

        // Amount
        DataCell(
          Text(
            '\$${order.total.toStringAsFixed(2)}',
            style: OdooTypography.tableCell.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // Payment Status
        DataCell(
          _buildStatusBadge(
            _getPaymentStatusText(order.paymentStatus),
            _getPaymentStatusColor(order.paymentStatus),
          ),
        ),

        // Order Status
        DataCell(
          _buildStatusBadge(
            _getStatusText(order.status),
            _getStatusColor(order.status),
          ),
        ),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showOrderDetails(order),
                icon: const Icon(Icons.visibility_outlined),
                tooltip: 'View Details',
                iconSize: OdooIconSizes.md,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(OdooSpacing.sm),
              ),
              const SizedBox(width: OdooSpacing.xs),
              if (order.paymentStatus == PaymentStatus.completed &&
                  order.status == OrderStatus.completed)
                IconButton(
                  onPressed: () => _showRefundDialog(order),
                  icon: const Icon(Icons.undo),
                  tooltip: 'Refund',
                  iconSize: OdooIconSizes.md,
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(OdooSpacing.sm),
                  color: OdooColors.warning,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.sm,
        vertical: OdooSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
      ),
      child: Text(
        text,
        style: OdooTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.lg),
          Text(
            _searchQuery.isNotEmpty || _hasActiveFilters()
                ? 'No orders found'
                : 'No orders yet',
            style: OdooTypography.titleLarge.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            _searchQuery.isNotEmpty || _hasActiveFilters()
                ? 'Try adjusting your search or filters'
                : 'Orders will appear here when customers place them',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          if (_searchQuery.isNotEmpty || _hasActiveFilters()) ...[
            const SizedBox(height: OdooSpacing.lg),
            OutlinedButton.icon(
              onPressed: () {
                _searchController.clear();
                _clearAllFilters();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Search & Filters'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: OdooColors.danger,
          ),
          const SizedBox(height: OdooSpacing.lg),
          Text(
            'Error Loading Orders',
            style: OdooTypography.titleLarge.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            error,
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: OdooSpacing.lg),
          FilledButton.icon(
            onPressed: () => ref.invalidate(ordersProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Filter and Search Logic

  List<Order> _filterOrders(List<Order> orders) {
    return orders.where((order) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        final matchesOrderNumber =
            order.orderNumber.toString().toLowerCase().contains(searchLower);
        final matchesTable =
            'table ${(order.id.hashCode % 20) + 1}'.toLowerCase().contains(searchLower);
        final matchesAmount =
            order.total.toStringAsFixed(2).contains(searchLower);

        if (!matchesOrderNumber && !matchesTable && !matchesAmount) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatus != null && order.status != _selectedStatus) {
        return false;
      }

      // Payment status filter
      if (_selectedPaymentStatus != null &&
          order.paymentStatus != _selectedPaymentStatus) {
        return false;
      }

      // Order type filter
      if (_selectedOrderType != null && order.orderType != _selectedOrderType) {
        return false;
      }

      // Date range filter
      if (_startDate != null && order.createdAt.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null &&
          order.createdAt.isAfter(_endDate!.add(const Duration(days: 1)))) {
        return false;
      }

      return true;
    }).toList();
  }

  bool _hasActiveFilters() {
    return _selectedStatus != null ||
        _selectedPaymentStatus != null ||
        _selectedOrderType != null ||
        _startDate != null ||
        _endDate != null;
  }

  void _clearAllFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
      _selectedPaymentStatus = null;
      _selectedOrderType = null;
      _startDate = null;
      _endDate = null;
    });
  }

  // Dialog Actions

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  Future<void> _showStatusFilter(BuildContext context) async {
    final selected = await showDialog<OrderStatus>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Status'),
        children: OrderStatus.values.map((status) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, status),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
              child: Row(
                children: [
                  _buildStatusBadge(
                    _getStatusText(status),
                    _getStatusColor(status),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedStatus = selected;
      });
    }
  }

  Future<void> _showPaymentStatusFilter(BuildContext context) async {
    final selected = await showDialog<PaymentStatus>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Payment Status'),
        children: PaymentStatus.values.map((status) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, status),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
              child: Row(
                children: [
                  _buildStatusBadge(
                    _getPaymentStatusText(status),
                    _getPaymentStatusColor(status),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedPaymentStatus = selected;
      });
    }
  }

  Future<void> _showOrderTypeFilter(BuildContext context) async {
    final selected = await showDialog<OrderType>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Order Type'),
        children: OrderType.values.map((type) {
          return SimpleDialogOption(
            onPressed: () => Navigator.pop(context, type),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
              child: Row(
                children: [
                  Icon(
                    _getOrderTypeIcon(type),
                    color: OdooColors.primary,
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Text(
                    _getOrderTypeText(type),
                    style: OdooTypography.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );

    if (selected != null) {
      setState(() {
        _selectedOrderType = selected;
      });
    }
  }

  Future<void> _showOrderDetails(Order order) async {
    await showDialog(
      context: context,
      builder: (context) => OrderDetailsDialog(order: order),
    );
  }

  Future<void> _showRefundDialog(Order order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: OdooColors.warning,
            ),
            const SizedBox(width: OdooSpacing.md),
            const Text('Confirm Refund'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to refund this order?',
              style: OdooTypography.bodyLarge,
            ),
            const SizedBox(height: OdooSpacing.lg),
            Container(
              padding: const EdgeInsets.all(OdooSpacing.md),
              decoration: BoxDecoration(
                color: OdooColors.warningLight,
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                border: Border.all(
                  color: OdooColors.warning,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        color: OdooColors.warning,
                        size: OdooIconSizes.lg,
                      ),
                      const SizedBox(width: OdooSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderNumber}',
                            style: OdooTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: OdooColors.warning,
                            ),
                          ),
                          Text(
                            '\$${order.total.toStringAsFixed(2)}',
                            style: OdooTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: OdooColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: OdooSpacing.lg),
            Text(
              'This action will refund the full amount to the customer and cannot be undone.',
              style: OdooTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: OdooColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: OdooColors.warning,
            ),
            child: const Text('Confirm Refund'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _processRefund(order);
    }
  }

  Future<void> _processRefund(Order order) async {
    setState(() => _isLoading = true);

    try {
      // Create refund using payments API
      final processRefundUseCase = ref.read(processRefundUseCaseProvider);

      final refund = Refund(
        id: '', // Will be generated by backend
        paymentId: order.id, // Using order ID as payment ID for now
        orderId: order.id,
        amount: order.total,
        reason: RefundReason.customerRequest,
        status: RefundStatus.pending,
        requestedBy: 'Current User', // TODO: Get from auth context
        requestedAt: DateTime.now(),
      );

      final result = await processRefundUseCase(refund);

      result.when(
        success: (_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Order #${order.orderNumber} has been refunded'),
                backgroundColor: OdooColors.success,
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Refresh orders
            ref.invalidate(ordersProvider);
          }
        },
        failure: (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error processing refund: ${failure.message}'),
                backgroundColor: OdooColors.danger,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error processing refund: ${e.toString()}'),
            backgroundColor: OdooColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _exportOrders() async {
    // TODO: Implement export functionality
    final ordersAsync = ref.read(ordersProvider());
    final orders = ordersAsync.maybeWhen(
      data: (orders) => _filterOrders(orders),
      orElse: () => <Order>[],
    );

    if (orders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No orders to export'),
          backgroundColor: OdooColors.warning,
        ),
      );
      return;
    }

    // Show export options
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Export as CSV'),
              subtitle: Text('${orders.length} orders'),
              onTap: () {
                Navigator.pop(context);
                _exportToCsv(orders);
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text('Export as PDF'),
              subtitle: Text('${orders.length} orders'),
              onTap: () {
                Navigator.pop(context);
                _exportToPdf(orders);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportToCsv(List<Order> orders) async {
    try {
      final filePath = await ExportService.exportOrdersToCsv(orders);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported ${orders.length} orders to CSV'),
            backgroundColor: OdooColors.success,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                // File is saved to documents directory
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('File saved to:\n$filePath'),
                    duration: const Duration(seconds: 5),
                  ),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to CSV: ${e.toString()}'),
            backgroundColor: OdooColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _exportToPdf(List<Order> orders) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      // Use share dialog for better UX on all platforms
      await ExportService.sharePdf(orders);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting to PDF: ${e.toString()}'),
            backgroundColor: OdooColors.danger,
          ),
        );
      }
    }
  }

  // Helper Methods

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return OdooColors.statusPending;
      case OrderStatus.preparing:
        return OdooColors.statusInProgress;
      case OrderStatus.ready:
        return OdooColors.statusConfirmed;
      case OrderStatus.completed:
        return OdooColors.statusCompleted;
      case OrderStatus.cancelled:
        return OdooColors.statusCancelled;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color _getPaymentStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return OdooColors.statusPending;
      case PaymentStatus.completed:
        return OdooColors.success;
      case PaymentStatus.failed:
        return OdooColors.danger;
      case PaymentStatus.refunded:
        return OdooColors.warning;
    }
  }

  String _getPaymentStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  IconData _getOrderTypeIcon(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return Icons.restaurant;
      case OrderType.takeaway:
        return Icons.shopping_bag_outlined;
      case OrderType.delivery:
        return Icons.delivery_dining;
    }
  }

  String _getOrderTypeText(OrderType type) {
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
