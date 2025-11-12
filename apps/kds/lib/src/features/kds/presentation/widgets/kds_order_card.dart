/// KDS Order Card Widget
/// Order card display following Odoo KDS design 100%
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/kitchen_order.dart';

/// KDS Order Card
/// Displays kitchen order with Odoo-style layout and interactions
class KdsOrderCard extends StatefulWidget {
  final KitchenOrder order;
  final ValueChanged<KitchenOrderStatus> onStatusChange;
  final ValueChanged<KitchenOrderItem> onItemToggle;

  const KdsOrderCard({
    super.key,
    required this.order,
    required this.onStatusChange,
    required this.onItemToggle,
  });

  @override
  State<KdsOrderCard> createState() => _KdsOrderCardState();
}

class _KdsOrderCardState extends State<KdsOrderCard> {
  @override
  Widget build(BuildContext context) {
    final bgColor = _getBackgroundColor();
    final isDelayed = widget.order.isOrderDelayed;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: VodoDimensions.borderRadiusMd,
        border: Border.all(
          color: isDelayed ? VodoColors.danger : _getBorderColor(),
          width: isDelayed ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDelayed
                ? VodoColors.danger.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: isDelayed ? 8 : 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with order number, time, and table
          _buildHeader(),

          // Order items grouped by category
          Expanded(
            child: _buildItemsList(),
          ),

          // Footer with actions
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDelayed = widget.order.isOrderDelayed;
    final elapsed = widget.order.elapsedMinutes;

    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: BoxDecoration(
        color: isDelayed
            ? VodoColors.danger
            : widget.order.status == KitchenOrderStatus.newOrder
                ? VodoColors.primary
                : _getHeaderColor(),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(VodoDimensions.radiusMd - 2),
        ),
      ),
      child: Column(
        children: [
          // Order number and timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Order number
              Expanded(
                child: Text(
                  widget.order.orderNumber,
                  style: VodoTextStyles.titleLarge.copyWith(
                    color: VodoColors.textOnPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
              ),

              // Timer with alert icon
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isDelayed
                      ? Colors.white
                      : Colors.white.withOpacity(0.2),
                  borderRadius: VodoDimensions.borderRadiusSm,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isDelayed)
                      const Icon(
                        Icons.warning,
                        size: 16,
                        color: VodoColors.danger,
                      ),
                    if (isDelayed)
                      const SizedBox(width: 4),
                    Icon(
                      Icons.timer,
                      size: 16,
                      color: isDelayed
                          ? VodoColors.danger
                          : VodoColors.textOnPrimary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${elapsed}m',
                      style: VodoTextStyles.titleMedium.copyWith(
                        color: isDelayed
                            ? VodoColors.danger
                            : VodoColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: VodoDimensions.spacingSm),

          // Table/Customer and priority
          Row(
            children: [
              // Table or customer
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      widget.order.tableNumber != null
                          ? Icons.table_restaurant
                          : Icons.person,
                      size: 16,
                      color: VodoColors.textOnPrimary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.order.tableName ??
                            widget.order.customerName ??
                            'Takeout',
                        style: VodoTextStyles.bodyMedium.copyWith(
                          color: VodoColors.textOnPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // Priority badge
              if (widget.order.priority != OrderPriority.normal) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: VodoDimensions.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.priority_high,
                        size: 14,
                        color: widget.order.priority == OrderPriority.urgent
                            ? VodoColors.danger
                            : VodoColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        widget.order.priority.displayName.toUpperCase(),
                        style: VodoTextStyles.caption.copyWith(
                          color: widget.order.priority == OrderPriority.urgent
                              ? VodoColors.danger
                              : VodoColors.warning,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Allergy warning
              if (widget.order.hasAllergyInfo) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: VodoDimensions.borderRadiusSm,
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: VodoColors.danger,
                  ),
                ),
              ],
            ],
          ),

          // Order notes
          if (widget.order.notes != null) ...[
            const SizedBox(height: VodoDimensions.spacingXs),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: VodoDimensions.borderRadiusSm,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.note,
                    size: 14,
                    color: VodoColors.textOnPrimary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      widget.order.notes!,
                      style: VodoTextStyles.bodySmall.copyWith(
                        color: VodoColors.textOnPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    final itemsByCategory = widget.order.itemsByCategory;

    return Container(
      color: VodoColors.backgroundPrimary,
      child: ListView.builder(
        padding: VodoDimensions.paddingSm,
        itemCount: itemsByCategory.keys.length,
        itemBuilder: (context, index) {
          final category = itemsByCategory.keys.elementAt(index);
          final items = itemsByCategory[category]!;

          return _buildCategoryGroup(category, items);
        },
      ),
    );
  }

  Widget _buildCategoryGroup(String category, List<KitchenOrderItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: VodoDimensions.spacingXs,
          ),
          child: Text(
            category.toUpperCase(),
            style: VodoTextStyles.labelSmall.copyWith(
              color: VodoColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // Items in category
        ...items.map((item) => _buildOrderItem(item)),

        const SizedBox(height: VodoDimensions.spacingSm),
      ],
    );
  }

  Widget _buildOrderItem(KitchenOrderItem item) {
    final canToggle = widget.order.status == KitchenOrderStatus.preparing;

    return InkWell(
      onTap: canToggle ? () => widget.onItemToggle(item) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: VodoDimensions.spacingXs),
        padding: VodoDimensions.paddingSm,
        decoration: BoxDecoration(
          color: item.isCompleted
              ? VodoColors.success.withOpacity(0.1)
              : item.isStarted
                  ? VodoColors.warning.withOpacity(0.1)
                  : VodoColors.backgroundSecondary,
          borderRadius: VodoDimensions.borderRadiusSm,
          border: Border.all(
            color: item.isCompleted
                ? VodoColors.success
                : item.isStarted
                    ? VodoColors.warning.withOpacity(0.3)
                    : VodoColors.border,
          ),
        ),
        child: Row(
          children: [
            // Checkbox (only when preparing)
            if (canToggle) ...[
              Icon(
                item.isCompleted
                    ? Icons.check_circle
                    : item.isStarted
                        ? Icons.radio_button_checked
                        : Icons.radio_button_unchecked,
                size: 20,
                color: item.isCompleted
                    ? VodoColors.success
                    : item.isStarted
                        ? VodoColors.warning
                        : VodoColors.textTertiary,
              ),
              const SizedBox(width: VodoDimensions.spacingSm),
            ],

            // Quantity badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: VodoColors.primary,
                borderRadius: VodoDimensions.borderRadiusSm,
              ),
              child: Text(
                '${item.quantity}x',
                style: VodoTextStyles.labelSmall.copyWith(
                  color: VodoColors.textOnPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: VodoDimensions.spacingSm),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: VodoTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: item.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  if (item.modifiers.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.modifiers.join(', '),
                      style: VodoTextStyles.caption.copyWith(
                        color: VodoColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (item.notes != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.note,
                          size: 12,
                          color: VodoColors.accent,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.notes!,
                            style: VodoTextStyles.caption.copyWith(
                              color: VodoColors.accent,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: VodoDimensions.paddingSm,
      decoration: const BoxDecoration(
        color: VodoColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(VodoDimensions.radiusMd - 2),
        ),
      ),
      child: _buildActionButtons(),
    );
  }

  Widget _buildActionButtons() {
    final nextStatus = widget.order.status.nextStatus;

    if (nextStatus == null) {
      // Order is done or cancelled
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Main action button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () => widget.onStatusChange(nextStatus),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getActionButtonColor(nextStatus),
              foregroundColor: VodoColors.textOnPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: VodoDimensions.borderRadiusSm,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_getActionButtonIcon(nextStatus), size: 20),
                const SizedBox(width: 8),
                Text(
                  _getActionButtonText(nextStatus),
                  style: VodoTextStyles.button.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Cancel button (only for new orders)
        if (widget.order.status == KitchenOrderStatus.newOrder) ...[
          const SizedBox(width: VodoDimensions.spacingSm),
          ElevatedButton(
            onPressed: () => widget.onStatusChange(
              KitchenOrderStatus.cancelled,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: VodoColors.danger,
              foregroundColor: VodoColors.textOnPrimary,
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: VodoDimensions.borderRadiusSm,
              ),
            ),
            child: const Icon(Icons.close, size: 20),
          ),
        ],
      ],
    );
  }

  Color _getBackgroundColor() {
    if (widget.order.isOrderDelayed) {
      return VodoColors.danger.withOpacity(0.05);
    }

    switch (widget.order.status) {
      case KitchenOrderStatus.newOrder:
        return Colors.white;
      case KitchenOrderStatus.preparing:
        return VodoColors.warning.withOpacity(0.1);
      case KitchenOrderStatus.ready:
        return VodoColors.success.withOpacity(0.1);
      case KitchenOrderStatus.done:
        return VodoColors.backgroundSecondary;
      case KitchenOrderStatus.cancelled:
        return VodoColors.danger.withOpacity(0.05);
    }
  }

  Color _getBorderColor() {
    switch (widget.order.status) {
      case KitchenOrderStatus.newOrder:
        return VodoColors.primary;
      case KitchenOrderStatus.preparing:
        return VodoColors.warning;
      case KitchenOrderStatus.ready:
        return VodoColors.success;
      case KitchenOrderStatus.done:
        return VodoColors.border;
      case KitchenOrderStatus.cancelled:
        return VodoColors.danger;
    }
  }

  Color _getHeaderColor() {
    switch (widget.order.status) {
      case KitchenOrderStatus.preparing:
        return VodoColors.warning;
      case KitchenOrderStatus.ready:
        return VodoColors.success;
      case KitchenOrderStatus.done:
        return VodoColors.textSecondary;
      case KitchenOrderStatus.cancelled:
        return VodoColors.danger;
      default:
        return VodoColors.primary;
    }
  }

  Color _getActionButtonColor(KitchenOrderStatus status) {
    switch (status) {
      case KitchenOrderStatus.preparing:
        return VodoColors.warning;
      case KitchenOrderStatus.ready:
        return VodoColors.success;
      case KitchenOrderStatus.done:
        return VodoColors.primary;
      default:
        return VodoColors.primary;
    }
  }

  IconData _getActionButtonIcon(KitchenOrderStatus status) {
    switch (status) {
      case KitchenOrderStatus.preparing:
        return Icons.play_arrow;
      case KitchenOrderStatus.ready:
        return Icons.done;
      case KitchenOrderStatus.done:
        return Icons.check_circle;
      default:
        return Icons.arrow_forward;
    }
  }

  String _getActionButtonText(KitchenOrderStatus status) {
    switch (status) {
      case KitchenOrderStatus.preparing:
        return 'START';
      case KitchenOrderStatus.ready:
        return 'READY';
      case KitchenOrderStatus.done:
        return 'DONE';
      default:
        return 'NEXT';
    }
  }
}
