import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_models.dart';

/// Provider for notifications
///
/// TODO: Replace with real API integration
/// GET /api/v1/notifications - List all notifications
/// PATCH /api/v1/notifications/:id - Mark as read
/// PATCH /api/v1/notifications/mark-all-read - Mark all as read
/// DELETE /api/v1/notifications/:id - Delete notification
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<AppNotification>>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<List<AppNotification>> {
  NotificationsNotifier() : super(_generateMockNotifications());

  static List<AppNotification> _generateMockNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: '1',
        type: NotificationType.order,
        title: 'New Order #1234',
        message: 'Table 5 placed a new order for \$45.50',
        timestamp: now.subtract(const Duration(minutes: 2)),
        isRead: false,
        actionRoute: '/sales',
        metadata: {'orderId': '1234', 'tableNumber': '5'},
      ),
      AppNotification(
        id: '2',
        type: NotificationType.lowStock,
        title: 'Low Stock Alert',
        message: 'Classic Burger is running low (5 items left)',
        timestamp: now.subtract(const Duration(minutes: 15)),
        isRead: false,
        actionRoute: '/products',
        metadata: {'productId': 'burger-001', 'stockLevel': 5},
      ),
      AppNotification(
        id: '3',
        type: NotificationType.order,
        title: 'Order #1233 Completed',
        message: 'Table 3 order has been completed',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isRead: false,
        actionRoute: '/sales',
        metadata: {'orderId': '1233', 'tableNumber': '3'},
      ),
      AppNotification(
        id: '4',
        type: NotificationType.staffActivity,
        title: 'Staff Clock-In',
        message: 'Emily Davis has clocked in for their shift',
        timestamp: now.subtract(const Duration(hours: 1)),
        isRead: true,
        actionRoute: '/staff',
        metadata: {'staffId': '4', 'staffName': 'Emily Davis'},
      ),
      AppNotification(
        id: '5',
        type: NotificationType.lowStock,
        title: 'Low Stock Alert',
        message: 'French Fries is running low (3 items left)',
        timestamp: now.subtract(const Duration(hours: 2)),
        isRead: true,
        actionRoute: '/products',
        metadata: {'productId': 'fries-001', 'stockLevel': 3},
      ),
      AppNotification(
        id: '6',
        type: NotificationType.alert,
        title: 'Cash Drawer Alert',
        message: 'Cash drawer balance exceeded \$1000',
        timestamp: now.subtract(const Duration(hours: 3)),
        isRead: true,
        actionRoute: '/sales',
        metadata: {'drawerBalance': 1250.00},
      ),
      AppNotification(
        id: '7',
        type: NotificationType.system,
        title: 'System Update',
        message: 'A new version of SmartPOS is available',
        timestamp: now.subtract(const Duration(days: 1)),
        isRead: true,
        actionRoute: '/settings',
      ),
      AppNotification(
        id: '8',
        type: NotificationType.order,
        title: 'Large Order Alert',
        message: 'Table 8 placed a large order (\$150.00)',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        isRead: true,
        actionRoute: '/sales',
        metadata: {'orderId': '1230', 'tableNumber': '8', 'total': 150.00},
      ),
    ];
  }

  /// Mark a notification as read
  void markAsRead(String id) {
    state = [
      for (final notification in state)
        if (notification.id == id)
          notification.copyWith(isRead: true)
        else
          notification,
    ];
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    state = [
      for (final notification in state) notification.copyWith(isRead: true),
    ];
  }

  /// Delete a notification
  void deleteNotification(String id) {
    state = state.where((notification) => notification.id != id).toList();
  }

  /// Add a new notification (for testing or real-time updates)
  void addNotification(AppNotification notification) {
    state = [notification, ...state];
  }

  /// Clear all notifications
  void clearAll() {
    state = [];
  }
}

/// Provider for unread notification count
final unreadNotificationCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider);
  return notifications.where((n) => !n.isRead).length;
});
