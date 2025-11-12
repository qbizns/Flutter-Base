import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';

/// Order Details Dialog
///
/// Displays comprehensive information about an order including:
/// - Order header with status and timestamps
/// - Customer/table information
/// - Itemized list with quantities and prices
/// - Payment details
/// - Actions (print receipt, update status)
class OrderDetailsDialog extends StatelessWidget {
  const OrderDetailsDialog({
    required this.order,
    super.key,
  });

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 800),
        child: Column(
          children: [
            // Header
            _buildHeader(context),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OdooSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Order Info Section
                    _buildOrderInfoSection(context),
                    const SizedBox(height: OdooSpacing.xl),

                    // Items Section
                    _buildItemsSection(context),
                    const SizedBox(height: OdooSpacing.xl),

                    // Payment Section
                    _buildPaymentSection(context),
                    const SizedBox(height: OdooSpacing.xl),

                    // Timeline Section
                    _buildTimelineSection(context),
                  ],
                ),
              ),
            ),

            // Footer Actions
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: OdooColors.gray50,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(OdooSpacing.md),
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Icon(
              Icons.receipt_long,
              color: _getStatusColor(order.status),
              size: OdooIconSizes.xl,
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: OdooTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: OdooColors.textPrimary,
                  ),
                ),
                const SizedBox(height: OdooSpacing.xs),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: OdooIconSizes.sm,
                      color: OdooColors.textSecondary,
                    ),
                    const SizedBox(width: OdooSpacing.xs),
                    Text(
                      DateFormat('MMM d, yyyy • h:mm a').format(order.createdAt),
                      style: OdooTypography.bodyMedium.copyWith(
                        color: OdooColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _buildStatusBadge(
            _getStatusText(order.status),
            _getStatusColor(order.status),
          ),
          const SizedBox(width: OdooSpacing.md),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Information',
          style: OdooTypography.cardTitle.copyWith(
            color: OdooColors.textPrimary,
          ),
        ),
        const SizedBox(height: OdooSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(OdooSpacing.lg),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.restaurant,
                  label: 'Order Type',
                  value: _getOrderTypeText(order.orderType),
                ),
                Divider(color: OdooColors.border),
                _buildInfoRow(
                  icon: Icons.table_restaurant,
                  label: 'Table',
                  value: 'Table ${(order.id.hashCode % 20) + 1}',
                ),
                Divider(color: OdooColors.border),
                _buildInfoRow(
                  icon: Icons.person_outline,
                  label: 'Server',
                  value: 'John Doe', // TODO: Add server info to Order model
                ),
                Divider(color: OdooColors.border),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Duration',
                  value: _getOrderDuration(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
      child: Row(
        children: [
          Icon(
            icon,
            size: OdooIconSizes.md,
            color: OdooColors.textSecondary,
          ),
          const SizedBox(width: OdooSpacing.md),
          Text(
            label,
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: OdooTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: OdooColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Items',
          style: OdooTypography.cardTitle.copyWith(
            color: OdooColors.textPrimary,
          ),
        ),
        const SizedBox(height: OdooSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(OdooSpacing.lg),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'ITEM',
                        style: OdooTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'QTY',
                        style: OdooTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'PRICE',
                        style: OdooTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'TOTAL',
                        style: OdooTypography.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: OdooSpacing.md),
                Divider(color: OdooColors.border),

                // Items
                ...order.items.map((item) => _buildOrderItemRow(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItemRow(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OdooSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: OdooTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.notes != null && item.notes!.isNotEmpty) ...[
                  const SizedBox(height: OdooSpacing.xs),
                  Text(
                    item.notes!,
                    style: OdooTypography.bodySmall.copyWith(
                      color: OdooColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${item.quantity}',
              style: OdooTypography.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              '\$${item.unitPrice.toStringAsFixed(2)}',
              style: OdooTypography.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Text(
              '\$${item.totalPrice.toStringAsFixed(2)}',
              style: OdooTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Details',
          style: OdooTypography.cardTitle.copyWith(
            color: OdooColors.textPrimary,
          ),
        ),
        const SizedBox(height: OdooSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(OdooSpacing.lg),
            child: Column(
              children: [
                // Subtotal
                _buildPaymentRow(
                  'Subtotal',
                  order.subtotal,
                  isBold: false,
                ),
                const SizedBox(height: OdooSpacing.sm),

                // Tax
                _buildPaymentRow(
                  'Tax',
                  order.taxAmount,
                  isBold: false,
                ),
                const SizedBox(height: OdooSpacing.sm),

                // Discount (if any)
                if (order.discountAmount > 0) ...[
                  _buildPaymentRow(
                    'Discount',
                    -order.discountAmount,
                    isBold: false,
                    color: OdooColors.success,
                  ),
                  const SizedBox(height: OdooSpacing.sm),
                ],

                Divider(color: OdooColors.border),

                // Total
                _buildPaymentRow(
                  'Total',
                  order.total,
                  isBold: true,
                  fontSize: 20,
                ),
                const SizedBox(height: OdooSpacing.lg),

                // Payment Status
                Container(
                  padding: const EdgeInsets.all(OdooSpacing.md),
                  decoration: BoxDecoration(
                    color: _getPaymentStatusColor(order.paymentStatus)
                        .withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(OdooSpacing.radiusStandard),
                    border: Border.all(
                      color: _getPaymentStatusColor(order.paymentStatus),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getPaymentStatusIcon(order.paymentStatus),
                        color: _getPaymentStatusColor(order.paymentStatus),
                      ),
                      const SizedBox(width: OdooSpacing.md),
                      Text(
                        'Payment ${_getPaymentStatusText(order.paymentStatus)}',
                        style: OdooTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _getPaymentStatusColor(order.paymentStatus),
                        ),
                      ),
                      const Spacer(),
                      if (order.paymentStatus == PaymentStatus.completed)
                        Text(
                          'Card', // TODO: Add payment method to Order model
                          style: OdooTypography.bodySmall.copyWith(
                            color: OdooColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(
    String label,
    double amount, {
    bool isBold = false,
    double? fontSize,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: OdooTypography.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            fontSize: fontSize,
            color: color ?? OdooColors.textPrimary,
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: OdooTypography.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            fontSize: fontSize,
            color: color ?? OdooColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Timeline',
          style: OdooTypography.cardTitle.copyWith(
            color: OdooColors.textPrimary,
          ),
        ),
        const SizedBox(height: OdooSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(OdooSpacing.lg),
            child: Column(
              children: [
                _buildTimelineItem(
                  icon: Icons.add_circle_outline,
                  title: 'Order Created',
                  timestamp: order.createdAt,
                  isCompleted: true,
                ),
                _buildTimelineItem(
                  icon: Icons.restaurant_menu,
                  title: 'Preparing',
                  timestamp: order.createdAt.add(const Duration(minutes: 5)),
                  isCompleted: order.status != OrderStatus.pending,
                ),
                _buildTimelineItem(
                  icon: Icons.check_circle_outline,
                  title: 'Ready',
                  timestamp: order.createdAt.add(const Duration(minutes: 20)),
                  isCompleted: order.status == OrderStatus.ready ||
                      order.status == OrderStatus.completed,
                ),
                _buildTimelineItem(
                  icon: Icons.done_all,
                  title: 'Completed',
                  timestamp: order.createdAt.add(const Duration(minutes: 30)),
                  isCompleted: order.status == OrderStatus.completed,
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required DateTime timestamp,
    required bool isCompleted,
    bool isLast = false,
  }) {
    final color = isCompleted ? OdooColors.success : OdooColors.gray400;

    return Row(
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(OdooSpacing.sm),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: OdooIconSizes.md,
                color: color,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: color.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: OdooSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: OdooTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCompleted
                      ? OdooColors.textPrimary
                      : OdooColors.textSecondary,
                ),
              ),
              Text(
                DateFormat('h:mm a').format(timestamp),
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: OdooColors.gray50,
        border: Border(
          top: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement print receipt
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Print receipt feature coming soon'),
                  backgroundColor: OdooColors.info,
                ),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Receipt'),
          ),
          const SizedBox(width: OdooSpacing.md),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.md,
        vertical: OdooSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: OdooTypography.labelMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // Helper Methods

  String _getOrderDuration() {
    final now = DateTime.now();
    final duration = now.difference(order.createdAt);

    if (duration.inMinutes < 60) {
      return '${duration.inMinutes} minutes';
    } else if (duration.inHours < 24) {
      return '${duration.inHours} hours';
    } else {
      return '${duration.inDays} days';
    }
  }

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
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  IconData _getPaymentStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.pending:
        return Icons.schedule;
      case PaymentStatus.completed:
        return Icons.check_circle;
      case PaymentStatus.failed:
        return Icons.error;
      case PaymentStatus.refunded:
        return Icons.undo;
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
