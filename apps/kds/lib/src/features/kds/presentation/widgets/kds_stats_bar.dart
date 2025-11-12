/// KDS Stats Bar Widget
/// Order statistics bar showing counts by status
/// Following Odoo KDS patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

import '../../../../data/models/kitchen_order.dart';

/// KDS Statistics Bar
class KdsStatsBar extends StatelessWidget {
  final List<KitchenOrder> orders;
  final KitchenOrderStatus? selectedStatus;
  final ValueChanged<KitchenOrderStatus>? onStatusTap;

  const KdsStatsBar({
    super.key,
    required this.orders,
    this.selectedStatus,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: const BoxDecoration(
        color: VodoColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(color: VodoColors.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          _buildStatChip(
            label: 'NEW',
            count: stats[KitchenOrderStatus.newOrder] ?? 0,
            status: KitchenOrderStatus.newOrder,
            color: VodoColors.primary,
            icon: Icons.fiber_new,
          ),
          const SizedBox(width: VodoDimensions.spacingSm),
          _buildStatChip(
            label: 'PREPARING',
            count: stats[KitchenOrderStatus.preparing] ?? 0,
            status: KitchenOrderStatus.preparing,
            color: VodoColors.warning,
            icon: Icons.restaurant,
          ),
          const SizedBox(width: VodoDimensions.spacingSm),
          _buildStatChip(
            label: 'READY',
            count: stats[KitchenOrderStatus.ready] ?? 0,
            status: KitchenOrderStatus.ready,
            color: VodoColors.success,
            icon: Icons.check_circle_outline,
          ),
          const SizedBox(width: VodoDimensions.spacingSm),

          const Spacer(),

          // Delayed orders warning
          if (_getDelayedCount() > 0) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: VodoColors.danger.withOpacity(0.1),
                borderRadius: VodoDimensions.borderRadiusSm,
                border: Border.all(color: VodoColors.danger),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning,
                    size: 16,
                    color: VodoColors.danger,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_getDelayedCount()} Delayed',
                    style: VodoTextStyles.bodyMedium.copyWith(
                      color: VodoColors.danger,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: VodoDimensions.spacingSm),
          ],

          // Total active orders
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: VodoColors.backgroundSecondary,
              borderRadius: VodoDimensions.borderRadiusSm,
              border: Border.all(color: VodoColors.border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.list_alt,
                  size: 16,
                  color: VodoColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_getActiveCount()} Active',
                  style: VodoTextStyles.bodyMedium.copyWith(
                    color: VodoColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required int count,
    required KitchenOrderStatus status,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = selectedStatus == status;

    return InkWell(
      onTap: onStatusTap != null ? () => onStatusTap!(status) : null,
      borderRadius: VodoDimensions.borderRadiusSm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : color.withOpacity(0.05),
          borderRadius: VodoDimensions.borderRadiusSm,
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: color,
            ),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: VodoTextStyles.caption.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  count.toString(),
                  style: VodoTextStyles.titleLarge.copyWith(
                    color: color,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<KitchenOrderStatus, int> _calculateStats() {
    final stats = <KitchenOrderStatus, int>{
      KitchenOrderStatus.newOrder: 0,
      KitchenOrderStatus.preparing: 0,
      KitchenOrderStatus.ready: 0,
      KitchenOrderStatus.done: 0,
      KitchenOrderStatus.cancelled: 0,
    };

    for (final order in orders) {
      stats[order.status] = (stats[order.status] ?? 0) + 1;
    }

    return stats;
  }

  int _getActiveCount() {
    return orders.where((o) =>
      o.status != KitchenOrderStatus.done &&
      o.status != KitchenOrderStatus.cancelled
    ).length;
  }

  int _getDelayedCount() {
    return orders.where((o) => o.isOrderDelayed).length;
  }
}
