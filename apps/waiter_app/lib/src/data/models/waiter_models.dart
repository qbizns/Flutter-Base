/// Waiter App Models
/// Models for table service and waiter operations
/// Following Odoo POS table service patterns 100%
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'waiter_models.freezed.dart';
part 'waiter_models.g.dart';

/// Table Entity
/// Represents a restaurant table following Odoo patterns
@freezed
class RestaurantTable with _$RestaurantTable {
  const RestaurantTable._();

  const factory RestaurantTable({
    required String id,
    required String name,
    required String floorId,
    required int seats,
    required TableShape shape,
    required TablePosition position,
    @Default(TableStatus.available) TableStatus status,
    String? currentOrderId,
    String? assignedWaiterId,
    String? assignedWaiterName,
    DateTime? occupiedSince,
    int? guestCount,
    double? currentBill,
  }) = _RestaurantTable;

  factory RestaurantTable.fromJson(Map<String, dynamic> json) =>
      _$RestaurantTableFromJson(json);

  /// Check if table is available
  bool get isAvailable => status == TableStatus.available;

  /// Check if table is occupied
  bool get isOccupied => status == TableStatus.occupied;

  /// Check if table has order
  bool get hasOrder => currentOrderId != null;

  /// Check if assigned to waiter
  bool get isAssigned => assignedWaiterId != null;

  /// Get occupancy duration
  Duration? get occupancyDuration {
    if (occupiedSince == null) return null;
    return DateTime.now().difference(occupiedSince!);
  }

  /// Get display color based on status
  Color get displayColor {
    switch (status) {
      case TableStatus.available:
        return const Color(0xFF4CAF50); // Green
      case TableStatus.occupied:
        return const Color(0xFF2196F3); // Blue
      case TableStatus.reserved:
        return const Color(0xFFFF9800); // Orange
      case TableStatus.needsCleaning:
        return const Color(0xFFF44336); // Red
      case TableStatus.outOfService:
        return const Color(0xFF9E9E9E); // Grey
    }
  }
}

/// Table Status
enum TableStatus {
  available,
  occupied,
  reserved,
  needsCleaning,
  outOfService;

  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.needsCleaning:
        return 'Needs Cleaning';
      case TableStatus.outOfService:
        return 'Out of Service';
    }
  }

  IconData get icon {
    switch (this) {
      case TableStatus.available:
        return Icons.check_circle;
      case TableStatus.occupied:
        return Icons.people;
      case TableStatus.reserved:
        return Icons.event;
      case TableStatus.needsCleaning:
        return Icons.cleaning_services;
      case TableStatus.outOfService:
        return Icons.block;
    }
  }
}

/// Table Shape
enum TableShape {
  square,
  rectangle,
  circle,
  round;

  String get displayName {
    switch (this) {
      case TableShape.square:
        return 'Square';
      case TableShape.rectangle:
        return 'Rectangle';
      case TableShape.circle:
        return 'Circle';
      case TableShape.round:
        return 'Round';
    }
  }
}

/// Table Position on floor plan
@freezed
class TablePosition with _$TablePosition {
  const factory TablePosition({
    required double x,
    required double y,
    @Default(100.0) double width,
    @Default(100.0) double height,
    @Default(0.0) double rotation,
  }) = _TablePosition;

  factory TablePosition.fromJson(Map<String, dynamic> json) =>
      _$TablePositionFromJson(json);
}

/// Floor/Room Entity
/// Represents different areas of the restaurant
@freezed
class RestaurantFloor with _$RestaurantFloor {
  const RestaurantFloor._();

  const factory RestaurantFloor({
    required String id,
    required String name,
    @Default([]) List<RestaurantTable> tables,
    @Default(1000.0) double width,
    @Default(800.0) double height,
    String? backgroundImage,
    @Default(0) int sequence,
  }) = _RestaurantFloor;

  factory RestaurantFloor.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFloorFromJson(json);

  /// Get available tables count
  int get availableCount =>
      tables.where((t) => t.status == TableStatus.available).length;

  /// Get occupied tables count
  int get occupiedCount =>
      tables.where((t) => t.status == TableStatus.occupied).length;

  /// Get reserved tables count
  int get reservedCount =>
      tables.where((t) => t.status == TableStatus.reserved).length;

  /// Get total tables count
  int get totalTables => tables.length;
}

/// Waiter/Server Entity
@freezed
class Waiter with _$Waiter {
  const Waiter._();

  const factory Waiter({
    required String id,
    required String name,
    required String employeeId,
    String? avatarUrl,
    @Default([]) List<String> assignedTableIds,
    @Default(WaiterStatus.available) WaiterStatus status,
    DateTime? shiftStart,
    DateTime? shiftEnd,
  }) = _Waiter;

  factory Waiter.fromJson(Map<String, dynamic> json) => _$WaiterFromJson(json);

  /// Check if waiter is on shift
  bool get isOnShift => status != WaiterStatus.offline;

  /// Get assigned tables count
  int get assignedTablesCount => assignedTableIds.length;
}

/// Waiter Status
enum WaiterStatus {
  available,
  busy,
  break_,
  offline;

  String get displayName {
    switch (this) {
      case WaiterStatus.available:
        return 'Available';
      case WaiterStatus.busy:
        return 'Busy';
      case WaiterStatus.break_:
        return 'On Break';
      case WaiterStatus.offline:
        return 'Offline';
    }
  }
}

/// Table Order
/// Order specific to a table in waiter context
@freezed
class TableOrder with _$TableOrder {
  const TableOrder._();

  const factory TableOrder({
    required String id,
    required String tableId,
    required String tableName,
    required String waiterId,
    required String waiterName,
    required List<TableOrderItem> items,
    required DateTime createdAt,
    @Default(TableOrderStatus.draft) TableOrderStatus status,
    int? guestCount,
    String? notes,
    DateTime? sentToKitchenAt,
    DateTime? completedAt,
  }) = _TableOrder;

  factory TableOrder.fromJson(Map<String, dynamic> json) =>
      _$TableOrderFromJson(json);

  /// Get total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Calculate subtotal
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  /// Calculate tax (10%)
  double get tax => subtotal * 0.1;

  /// Calculate total
  double get total => subtotal + tax;

  /// Check if order is empty
  bool get isEmpty => items.isEmpty;

  /// Check if sent to kitchen
  bool get isSentToKitchen => sentToKitchenAt != null;

  /// Check if order is editable
  bool get isEditable => status == TableOrderStatus.draft;
}

/// Table Order Status
enum TableOrderStatus {
  draft,
  sent,
  preparing,
  ready,
  served,
  cancelled;

  String get displayName {
    switch (this) {
      case TableOrderStatus.draft:
        return 'Draft';
      case TableOrderStatus.sent:
        return 'Sent to Kitchen';
      case TableOrderStatus.preparing:
        return 'Preparing';
      case TableOrderStatus.ready:
        return 'Ready';
      case TableOrderStatus.served:
        return 'Served';
      case TableOrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  Color get color {
    switch (this) {
      case TableOrderStatus.draft:
        return const Color(0xFF9E9E9E);
      case TableOrderStatus.sent:
        return const Color(0xFF2196F3);
      case TableOrderStatus.preparing:
        return const Color(0xFFFF9800);
      case TableOrderStatus.ready:
        return const Color(0xFF4CAF50);
      case TableOrderStatus.served:
        return const Color(0xFF4CAF50);
      case TableOrderStatus.cancelled:
        return const Color(0xFFF44336);
    }
  }
}

/// Table Order Item
@freezed
class TableOrderItem with _$TableOrderItem {
  const TableOrderItem._();

  const factory TableOrderItem({
    required String id,
    required String productId,
    required String productName,
    required int quantity,
    required double unitPrice,
    String? categoryId,
    String? categoryName,
    String? imageUrl,
    @Default([]) List<String> modifiers,
    @Default([]) List<String> notes,
    double? discount,
    @Default(false) bool isSentToKitchen,
    DateTime? sentToKitchenAt,
  }) = _TableOrderItem;

  factory TableOrderItem.fromJson(Map<String, dynamic> json) =>
      _$TableOrderItemFromJson(json);

  /// Calculate line total
  double get lineTotal => unitPrice * quantity - (discount ?? 0);

  /// Check if item has modifiers
  bool get hasModifiers => modifiers.isNotEmpty;

  /// Check if item has notes
  bool get hasNotes => notes.isNotEmpty;
}

/// Table Action
/// Actions that can be performed on tables
enum TableAction {
  openTable,
  takeOrder,
  viewOrder,
  sendToKitchen,
  addItems,
  requestBill,
  splitBill,
  transferTable,
  mergeTable,
  changeGuests,
  addNote,
  closeTable,
  cleanTable;

  String get displayName {
    switch (this) {
      case TableAction.openTable:
        return 'Open Table';
      case TableAction.takeOrder:
        return 'Take Order';
      case TableAction.viewOrder:
        return 'View Order';
      case TableAction.sendToKitchen:
        return 'Send to Kitchen';
      case TableAction.addItems:
        return 'Add Items';
      case TableAction.requestBill:
        return 'Request Bill';
      case TableAction.splitBill:
        return 'Split Bill';
      case TableAction.transferTable:
        return 'Transfer Table';
      case TableAction.mergeTable:
        return 'Merge Tables';
      case TableAction.changeGuests:
        return 'Change Guests';
      case TableAction.addNote:
        return 'Add Note';
      case TableAction.closeTable:
        return 'Close Table';
      case TableAction.cleanTable:
        return 'Clean Table';
    }
  }

  IconData get icon {
    switch (this) {
      case TableAction.openTable:
        return Icons.table_restaurant;
      case TableAction.takeOrder:
        return Icons.edit_note;
      case TableAction.viewOrder:
        return Icons.receipt;
      case TableAction.sendToKitchen:
        return Icons.send;
      case TableAction.addItems:
        return Icons.add_shopping_cart;
      case TableAction.requestBill:
        return Icons.payment;
      case TableAction.splitBill:
        return Icons.call_split;
      case TableAction.transferTable:
        return Icons.swap_horiz;
      case TableAction.mergeTable:
        return Icons.merge;
      case TableAction.changeGuests:
        return Icons.people;
      case TableAction.addNote:
        return Icons.note_add;
      case TableAction.closeTable:
        return Icons.check_circle;
      case TableAction.cleanTable:
        return Icons.cleaning_services;
    }
  }
}

/// Import required Material icons
class Icons {
  static const check_circle = 0xe86c;
  static const people = 0xe7fb;
  static const event = 0xe878;
  static const cleaning_services = 0xf0ff;
  static const block = 0xe14b;
  static const table_restaurant = 0xeac7;
  static const edit_note = 0xe745;
  static const receipt = 0xef14;
  static const send = 0xe163;
  static const add_shopping_cart = 0xe854;
  static const payment = 0xe8a1;
  static const call_split = 0xe0e7;
  static const swap_horiz = 0xe8d4;
  static const merge = 0xeb7c;
  static const note_add = 0xe89c;
}

/// Import Color class
class Color {
  final int value;
  const Color(this.value);
}

/// Icon Data class
class IconData {
  final int codePoint;
  const IconData(this.codePoint);
}
