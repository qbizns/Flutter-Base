import 'package:equatable/equatable.dart';
import 'order_item.dart';

/// Order entity representing a complete customer order.
///
/// Contains all information about an order including items, customer,
/// payment, status, and timestamps.
class Order extends Equatable {
  const Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.orderType,
    required this.items,
    required this.createdAt,
    this.tableId,
    this.tableName,
    this.customerId,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.notes,
    this.subtotal = 0,
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.taxAmount = 0,
    this.taxPercent = 0,
    this.tipAmount = 0,
    this.total = 0,
    this.paidAmount = 0,
    this.changeAmount = 0,
    this.paymentMethod,
    this.paymentStatus = PaymentStatus.pending,
    this.tenantId,
    this.branchId,
    this.deviceId,
    this.userId,
    this.userName,
    this.updatedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancellationReason,
  });

  /// Unique identifier
  final String id;

  /// Human-readable order number
  final String orderNumber;

  /// Current order status
  final OrderStatus status;

  /// Type of order
  final OrderType orderType;

  /// Order items
  final List<OrderItem> items;

  /// Table ID (for dine-in orders)
  final String? tableId;

  /// Table name
  final String? tableName;

  /// Customer ID (if registered)
  final String? customerId;

  /// Customer name
  final String? customerName;

  /// Customer phone
  final String? customerPhone;

  /// Customer email
  final String? customerEmail;

  /// Order notes
  final String? notes;

  /// Subtotal (sum of all items before discount/tax)
  final double subtotal;

  /// Discount amount
  final double discountAmount;

  /// Discount percentage
  final double discountPercent;

  /// Tax amount
  final double taxAmount;

  /// Tax percentage
  final double taxPercent;

  /// Tip amount
  final double tipAmount;

  /// Total amount
  final double total;

  /// Amount paid
  final double paidAmount;

  /// Change to return
  final double changeAmount;

  /// Payment method
  final String? paymentMethod;

  /// Payment status
  final PaymentStatus paymentStatus;

  /// Tenant ID (multi-tenancy)
  final String? tenantId;

  /// Branch ID
  final String? branchId;

  /// Device ID
  final String? deviceId;

  /// User ID who created the order
  final String? userId;

  /// User name who created the order
  final String? userName;

  /// When order was created
  final DateTime createdAt;

  /// When order was last updated
  final DateTime? updatedAt;

  /// When order was completed
  final DateTime? completedAt;

  /// When order was cancelled
  final DateTime? cancelledAt;

  /// Reason for cancellation
  final String? cancellationReason;

  /// Calculate items count
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if order is paid
  bool get isPaid =>
      paymentStatus == PaymentStatus.paid ||
      paymentStatus == PaymentStatus.refunded;

  /// Check if order is active (not cancelled or completed)
  bool get isActive =>
      status != OrderStatus.cancelled && status != OrderStatus.completed;

  /// Check if order can be modified
  bool get canModify =>
      status == OrderStatus.draft ||
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed;

  /// Check if order can be cancelled
  bool get canCancel => isActive && status != OrderStatus.draft;

  /// Calculate remaining amount to pay
  double get remainingAmount => total - paidAmount;

  /// Copy with method for immutability
  Order copyWith({
    String? id,
    String? orderNumber,
    OrderStatus? status,
    OrderType? orderType,
    List<OrderItem>? items,
    String? tableId,
    String? tableName,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String? notes,
    double? subtotal,
    double? discountAmount,
    double? discountPercent,
    double? taxAmount,
    double? taxPercent,
    double? tipAmount,
    double? total,
    double? paidAmount,
    double? changeAmount,
    String? paymentMethod,
    PaymentStatus? paymentStatus,
    String? tenantId,
    String? branchId,
    String? deviceId,
    String? userId,
    String? userName,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancellationReason,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      orderType: orderType ?? this.orderType,
      items: items ?? this.items,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerEmail: customerEmail ?? this.customerEmail,
      notes: notes ?? this.notes,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      taxAmount: taxAmount ?? this.taxAmount,
      taxPercent: taxPercent ?? this.taxPercent,
      tipAmount: tipAmount ?? this.tipAmount,
      total: total ?? this.total,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      tenantId: tenantId ?? this.tenantId,
      branchId: branchId ?? this.branchId,
      deviceId: deviceId ?? this.deviceId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        status,
        orderType,
        items,
        tableId,
        tableName,
        customerId,
        customerName,
        customerPhone,
        customerEmail,
        notes,
        subtotal,
        discountAmount,
        discountPercent,
        taxAmount,
        taxPercent,
        tipAmount,
        total,
        paidAmount,
        changeAmount,
        paymentMethod,
        paymentStatus,
        tenantId,
        branchId,
        deviceId,
        userId,
        userName,
        createdAt,
        updatedAt,
        completedAt,
        cancelledAt,
        cancellationReason,
      ];
}

/// Order status enum
enum OrderStatus {
  /// Order is being created (in cart)
  draft,

  /// Order submitted but not confirmed
  pending,

  /// Order confirmed
  confirmed,

  /// Order is being prepared
  preparing,

  /// Order is ready
  ready,

  /// Order is being delivered
  delivering,

  /// Order completed
  completed,

  /// Order cancelled
  cancelled,

  /// Order on hold
  hold,
}

/// Order type enum
enum OrderType {
  /// Dine-in order
  dineIn,

  /// Takeaway order
  takeaway,

  /// Delivery order
  delivery,

  /// Drive-thru order
  driveThru,

  /// Online order
  online,
}

/// Payment status enum
enum PaymentStatus {
  /// Payment pending
  pending,

  /// Partially paid
  partial,

  /// Fully paid
  paid,

  /// Payment failed
  failed,

  /// Payment refunded
  refunded,
}
