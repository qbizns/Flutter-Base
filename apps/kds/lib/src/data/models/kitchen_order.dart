/// Kitchen Order Model
/// Order representation for Kitchen Display System
/// Following Odoo KDS patterns 100%
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'kitchen_order.freezed.dart';
part 'kitchen_order.g.dart';

/// Kitchen order status following Odoo KDS workflow
enum KitchenOrderStatus {
  /// New order, not yet started
  @JsonValue('new')
  newOrder,

  /// Order being prepared
  @JsonValue('preparing')
  preparing,

  /// Order ready for pickup/delivery
  @JsonValue('ready')
  ready,

  /// Order completed/served
  @JsonValue('done')
  done,

  /// Order cancelled
  @JsonValue('cancelled')
  cancelled,
}

/// Kitchen order priority
enum OrderPriority {
  @JsonValue('normal')
  normal,

  @JsonValue('high')
  high,

  @JsonValue('urgent')
  urgent,
}

/// Kitchen order item
@freezed
class KitchenOrderItem with _$KitchenOrderItem {
  const factory KitchenOrderItem({
    required String id,
    required String productId,
    required String productName,
    required String categoryId,
    required String categoryName,
    required int quantity,
    required double basePrice,
    @Default([]) List<String> modifiers,
    String? notes,
    @Default(false) bool isStarted,
    @Default(false) bool isCompleted,
    DateTime? startedAt,
    DateTime? completedAt,
  }) = _KitchenOrderItem;

  factory KitchenOrderItem.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderItemFromJson(json);
}

/// Kitchen order
@freezed
class KitchenOrder with _$KitchenOrder {
  const KitchenOrder._();

  const factory KitchenOrder({
    required String id,
    required String orderNumber,
    required DateTime createdAt,
    required KitchenOrderStatus status,
    required List<KitchenOrderItem> items,

    // Order source
    required String sessionId,
    String? tableNumber,
    String? tableName,
    String? customerName,

    // Station assignment
    @Default([]) List<String> stationIds,

    // Priority
    @Default(OrderPriority.normal) OrderPriority priority,

    // Notes
    String? notes,
    String? specialInstructions,

    // Timing
    DateTime? startedAt,
    DateTime? readyAt,
    DateTime? completedAt,

    // Metadata
    @Default(0) int preparationTimeMinutes,
    @Default(false) bool isDelayed,
    @Default(false) bool hasAllergyInfo,
    @Default(false) bool isUrgent,
  }) = _KitchenOrder;

  factory KitchenOrder.fromJson(Map<String, dynamic> json) =>
      _$KitchenOrderFromJson(json);

  /// Get elapsed time in minutes
  int get elapsedMinutes {
    final now = DateTime.now();
    final diff = now.difference(createdAt);
    return diff.inMinutes;
  }

  /// Check if order is delayed (>15 minutes for normal, >10 for urgent)
  bool get isOrderDelayed {
    final threshold = isUrgent ? 10 : 15;
    return status != KitchenOrderStatus.done &&
           status != KitchenOrderStatus.cancelled &&
           elapsedMinutes > threshold;
  }

  /// Get status color following Odoo KDS
  String get statusColor {
    if (isOrderDelayed) return 'red';

    switch (status) {
      case KitchenOrderStatus.newOrder:
        return 'white'; // New orders - white background
      case KitchenOrderStatus.preparing:
        return 'yellow'; // In progress - yellow
      case KitchenOrderStatus.ready:
        return 'green'; // Ready - green
      case KitchenOrderStatus.done:
        return 'gray'; // Completed - gray
      case KitchenOrderStatus.cancelled:
        return 'red'; // Cancelled - red
    }
  }

  /// Get items grouped by category (Odoo pattern)
  Map<String, List<KitchenOrderItem>> get itemsByCategory {
    final Map<String, List<KitchenOrderItem>> grouped = {};

    for (final item in items) {
      final category = item.categoryName;
      if (!grouped.containsKey(category)) {
        grouped[category] = [];
      }
      grouped[category]!.add(item);
    }

    return grouped;
  }

  /// Get completion percentage
  double get completionPercentage {
    if (items.isEmpty) return 0.0;
    final completed = items.where((i) => i.isCompleted).length;
    return completed / items.length;
  }

  /// Check if all items are started
  bool get allItemsStarted {
    return items.every((item) => item.isStarted);
  }

  /// Check if all items are completed
  bool get allItemsCompleted {
    return items.every((item) => item.isCompleted);
  }
}

/// Kitchen order extensions
extension KitchenOrderStatusExtension on KitchenOrderStatus {
  String get displayName {
    switch (this) {
      case KitchenOrderStatus.newOrder:
        return 'New';
      case KitchenOrderStatus.preparing:
        return 'Preparing';
      case KitchenOrderStatus.ready:
        return 'Ready';
      case KitchenOrderStatus.done:
        return 'Done';
      case KitchenOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Get next status in workflow
  KitchenOrderStatus? get nextStatus {
    switch (this) {
      case KitchenOrderStatus.newOrder:
        return KitchenOrderStatus.preparing;
      case KitchenOrderStatus.preparing:
        return KitchenOrderStatus.ready;
      case KitchenOrderStatus.ready:
        return KitchenOrderStatus.done;
      case KitchenOrderStatus.done:
        return null; // Final state
      case KitchenOrderStatus.cancelled:
        return null; // Final state
    }
  }
}

/// Order priority extensions
extension OrderPriorityExtension on OrderPriority {
  String get displayName {
    switch (this) {
      case OrderPriority.normal:
        return 'Normal';
      case OrderPriority.high:
        return 'High';
      case OrderPriority.urgent:
        return 'Urgent';
    }
  }

  int get sortOrder {
    switch (this) {
      case OrderPriority.urgent:
        return 1;
      case OrderPriority.high:
        return 2;
      case OrderPriority.normal:
        return 3;
    }
  }
}
