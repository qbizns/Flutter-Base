import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/notification_models.dart';
import '../providers/notifications_provider.dart';
import '../theme/odoo_colors.dart';
import '../theme/odoo_typography.dart';

/// Notifications Panel Widget
///
/// A dropdown panel that shows recent notifications with actions
class NotificationsPanel extends ConsumerWidget {
  const NotificationsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final hasNotifications = notifications.isNotEmpty;

    return Container(
      width: 380,
      constraints: const BoxConstraints(maxHeight: 500),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(OdooSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          _buildHeader(context, ref, hasNotifications),

          // Divider
          const Divider(height: 1),

          // Notifications list or empty state
          if (hasNotifications)
            _buildNotificationsList(context, ref, notifications)
          else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool hasNotifications) {
    return Padding(
      padding: const EdgeInsets.all(OdooSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Notifications',
            style: OdooTypography.titleMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          if (hasNotifications)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () {
                    ref.read(notificationsProvider.notifier).markAllAsRead();
                  },
                  child: Text(
                    'Mark all read',
                    style: OdooTypography.bodySmall.copyWith(
                      color: OdooColors.secondary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    WidgetRef ref,
    List<AppNotification> notifications,
  ) {
    return Flexible(
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: notifications.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _NotificationItem(
            notification: notification,
            onTap: () {
              // Mark as read
              if (!notification.isRead) {
                ref
                    .read(notificationsProvider.notifier)
                    .markAsRead(notification.id);
              }

              // Navigate if there's an action route
              if (notification.actionRoute != null) {
                Navigator.of(context).pop(); // Close the panel
                context.go(notification.actionRoute!);
              }
            },
            onDismiss: () {
              ref
                  .read(notificationsProvider.notifier)
                  .deleteNotification(notification.id);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(OdooSpacing.xxl),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: OdooColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: OdooSpacing.md),
          Text(
            'No notifications',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.xs),
          Text(
            'You\'re all caught up!',
            style: OdooTypography.bodySmall.copyWith(
              color: OdooColors.textSecondary.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// Notification Item Widget
class _NotificationItem extends StatelessWidget {
  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: OdooSpacing.lg),
        color: OdooColors.danger,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) => onDismiss(),
      child: Material(
        color: notification.isRead
            ? Colors.white
            : OdooColors.secondary.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(OdooSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getNotificationColor(notification.type)
                        .withOpacity(0.15),
                    borderRadius:
                        BorderRadius.circular(OdooSpacing.radiusStandard),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    color: _getNotificationColor(notification.type),
                    size: OdooIconSizes.md,
                  ),
                ),

                const SizedBox(width: OdooSpacing.md),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: OdooTypography.bodyMedium.copyWith(
                                fontWeight: notification.isRead
                                    ? FontWeight.w400
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: OdooColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.timeAgo,
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary.withOpacity(0.7),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.receipt_long;
      case NotificationType.lowStock:
        return Icons.inventory_2;
      case NotificationType.staffActivity:
        return Icons.people;
      case NotificationType.system:
        return Icons.settings;
      case NotificationType.alert:
        return Icons.warning;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return OdooColors.secondary;
      case NotificationType.lowStock:
        return OdooColors.warning;
      case NotificationType.staffActivity:
        return OdooColors.info;
      case NotificationType.system:
        return OdooColors.gray600;
      case NotificationType.alert:
        return OdooColors.danger;
    }
  }
}
