/// Vodo Orders List Widget
/// Odoo-style orders list with status badges and filtering
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Order status enum matching Odoo workflow
enum VodoOrderStatus {
  draft,
  confirmed,
  preparing,
  ready,
  done,
  cancelled,
}

extension VodoOrderStatusExtension on VodoOrderStatus {
  String get label {
    switch (this) {
      case VodoOrderStatus.draft:
        return 'Draft';
      case VodoOrderStatus.confirmed:
        return 'Confirmed';
      case VodoOrderStatus.preparing:
        return 'Preparing';
      case VodoOrderStatus.ready:
        return 'Ready';
      case VodoOrderStatus.done:
        return 'Done';
      case VodoOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case VodoOrderStatus.draft:
        return VodoColors.textSecondary;
      case VodoOrderStatus.confirmed:
        return VodoColors.info;
      case VodoOrderStatus.preparing:
        return VodoColors.warning;
      case VodoOrderStatus.ready:
        return VodoColors.accent;
      case VodoOrderStatus.done:
        return VodoColors.success;
      case VodoOrderStatus.cancelled:
        return VodoColors.danger;
    }
  }

  IconData get icon {
    switch (this) {
      case VodoOrderStatus.draft:
        return Icons.edit_note;
      case VodoOrderStatus.confirmed:
        return Icons.check_circle_outline;
      case VodoOrderStatus.preparing:
        return Icons.kitchen;
      case VodoOrderStatus.ready:
        return Icons.notifications_active;
      case VodoOrderStatus.done:
        return Icons.check_circle;
      case VodoOrderStatus.cancelled:
        return Icons.cancel;
    }
  }
}

/// Simplified order model for list display
class VodoOrder {
  final String id;
  final String number;
  final DateTime createdAt;
  final VodoOrderStatus status;
  final double totalAmount;
  final int itemsCount;
  final String? customerName;
  final String? tableName;
  final String? notes;
  final String cashierName;

  const VodoOrder({
    required this.id,
    required this.number,
    required this.createdAt,
    required this.status,
    required this.totalAmount,
    required this.itemsCount,
    this.customerName,
    this.tableName,
    this.notes,
    required this.cashierName,
  });

  // Mock data for development
  static List<VodoOrder> getMockOrders() {
    return [
      VodoOrder(
        id: '1',
        number: 'ORD-001',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        status: VodoOrderStatus.preparing,
        totalAmount: 45.50,
        itemsCount: 3,
        customerName: 'John Doe',
        tableName: 'Table 5',
        cashierName: 'Alice Smith',
      ),
      VodoOrder(
        id: '2',
        number: 'ORD-002',
        createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
        status: VodoOrderStatus.ready,
        totalAmount: 32.00,
        itemsCount: 2,
        tableName: 'Table 3',
        cashierName: 'Alice Smith',
      ),
      VodoOrder(
        id: '3',
        number: 'ORD-003',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        status: VodoOrderStatus.done,
        totalAmount: 78.25,
        itemsCount: 5,
        customerName: 'Jane Wilson',
        notes: 'Extra sauce on burger',
        cashierName: 'Bob Johnson',
      ),
      VodoOrder(
        id: '4',
        number: 'ORD-004',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        status: VodoOrderStatus.done,
        totalAmount: 23.50,
        itemsCount: 2,
        cashierName: 'Alice Smith',
      ),
      VodoOrder(
        id: '5',
        number: 'ORD-005',
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        status: VodoOrderStatus.confirmed,
        totalAmount: 56.00,
        itemsCount: 4,
        customerName: 'Mike Brown',
        tableName: 'Table 8',
        cashierName: 'Alice Smith',
      ),
    ];
  }
}

/// Odoo-style orders list widget
class VodoOrdersList extends StatelessWidget {
  final List<VodoOrder> orders;
  final ValueChanged<VodoOrder> onOrderTap;
  final VodoOrderStatus? statusFilter;

  const VodoOrdersList({
    super.key,
    required this.orders,
    required this.onOrderTap,
    this.statusFilter,
  });

  @override
  Widget build(BuildContext context) {
    final filteredOrders = statusFilter != null
        ? orders.where((order) => order.status == statusFilter).toList()
        : orders;

    if (filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: VodoDimensions.paddingMd,
      itemCount: filteredOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: VodoDimensions.spacingMd),
      itemBuilder: (context, index) {
        return _VodoOrderCard(
          order: filteredOrders[index],
          onTap: () => onOrderTap(filteredOrders[index]),
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
            Icons.receipt_long_outlined,
            size: 80,
            color: VodoColors.textTertiary.withOpacity(0.5),
          ),
          const SizedBox(height: VodoDimensions.spacingMd),
          Text(
            'No orders found',
            style: VodoTextStyles.bodyLarge.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),
          const SizedBox(height: VodoDimensions.spacingSm),
          Text(
            statusFilter != null
                ? 'No ${statusFilter!.label.toLowerCase()} orders'
                : 'Start taking orders to see them here',
            style: VodoTextStyles.bodySmall.copyWith(
              color: VodoColors.textTertiary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Individual order card (Odoo-style)
class _VodoOrderCard extends StatelessWidget {
  final VodoOrder order;
  final VoidCallback onTap;

  const _VodoOrderCard({
    required this.order,
    required this.onTap,
  });

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
        side: BorderSide(
          color: order.status == VodoOrderStatus.ready
              ? VodoColors.accent.withOpacity(0.5)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: VodoDimensions.borderRadiusMd,
        child: Padding(
          padding: VodoDimensions.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order number + Status badge
              Row(
                children: [
                  // Order number
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          Icons.receipt,
                          size: 20,
                          color: order.status.color,
                        ),
                        const SizedBox(width: VodoDimensions.spacingSm),
                        Text(
                          order.number,
                          style: VodoTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: order.status.color,
                      borderRadius: VodoDimensions.borderRadiusSm,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          order.status.icon,
                          size: 14,
                          color: VodoColors.textOnPrimary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.status.label.toUpperCase(),
                          style: VodoTextStyles.badge.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: VodoDimensions.spacingSm),

              // Customer and table info
              Row(
                children: [
                  if (order.customerName != null) ...[
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: VodoColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.customerName!,
                      style: VodoTextStyles.bodySmall.copyWith(
                        color: VodoColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: VodoDimensions.spacingMd),
                  ],
                  if (order.tableName != null) ...[
                    Icon(
                      Icons.table_restaurant,
                      size: 14,
                      color: VodoColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      order.tableName!,
                      style: VodoTextStyles.bodySmall.copyWith(
                        color: VodoColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),

              // Notes (if any)
              if (order.notes != null) ...[
                const SizedBox(height: VodoDimensions.spacingXs),
                Row(
                  children: [
                    Icon(
                      Icons.note,
                      size: 14,
                      color: VodoColors.accent,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.notes!,
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: VodoColors.accent,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: VodoDimensions.spacingMd),

              const Divider(),

              const SizedBox(height: VodoDimensions.spacingSm),

              // Footer: Time, Items, Amount
              Row(
                children: [
                  // Time
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: VodoColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(order.createdAt),
                    style: VodoTextStyles.bodySmall.copyWith(
                      color: VodoColors.textSecondary,
                    ),
                  ),

                  const SizedBox(width: VodoDimensions.spacingMd),

                  // Items count
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 14,
                    color: VodoColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${order.itemsCount} items',
                    style: VodoTextStyles.bodySmall.copyWith(
                      color: VodoColors.textSecondary,
                    ),
                  ),

                  const Spacer(),

                  // Amount
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: VodoTextStyles.priceMedium.copyWith(
                      color: VodoColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(width: VodoDimensions.spacingSm),

                  // Chevron
                  const Icon(
                    Icons.chevron_right,
                    color: VodoColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Status filter chips (Odoo-style)
class VodoOrderStatusFilter extends StatelessWidget {
  final VodoOrderStatus? selectedStatus;
  final ValueChanged<VodoOrderStatus?> onStatusChanged;
  final Map<VodoOrderStatus, int>? statusCounts;

  const VodoOrderStatusFilter({
    super.key,
    this.selectedStatus,
    required this.onStatusChanged,
    this.statusCounts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(
        horizontal: VodoDimensions.spacingMd,
        vertical: VodoDimensions.spacingSm,
      ),
      decoration: const BoxDecoration(
        color: VodoColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(color: VodoColors.border, width: 1),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // All orders
          _buildFilterChip(
            label: 'All',
            count: statusCounts?.values.fold(0, (sum, count) => sum + count),
            isSelected: selectedStatus == null,
            onTap: () => onStatusChanged(null),
            color: VodoColors.primary,
          ),
          const SizedBox(width: VodoDimensions.spacingSm),

          // Status filters
          ...VodoOrderStatus.values.map((status) {
            return Padding(
              padding: const EdgeInsets.only(right: VodoDimensions.spacingSm),
              child: _buildFilterChip(
                label: status.label,
                count: statusCounts?[status],
                isSelected: selectedStatus == status,
                onTap: () => onStatusChanged(status),
                color: status.color,
                icon: status.icon,
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    int? count,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
    IconData? icon,
  }) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: isSelected ? VodoColors.textOnPrimary : color,
            ),
            const SizedBox(width: 4),
          ],
          Text(label),
          if (count != null) ...[
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? VodoColors.textOnPrimary.withOpacity(0.2)
                    : color.withOpacity(0.2),
                borderRadius: VodoDimensions.borderRadiusSm,
              ),
              child: Text(
                '$count',
                style: VodoTextStyles.caption.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? VodoColors.textOnPrimary : color,
                ),
              ),
            ),
          ],
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: VodoColors.backgroundSecondary,
      selectedColor: color,
      labelStyle: VodoTextStyles.labelMedium.copyWith(
        color: isSelected ? VodoColors.textOnPrimary : VodoColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
        side: BorderSide(
          color: isSelected ? color : VodoColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}
