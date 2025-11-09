import 'package:equatable/equatable.dart';

/// Refund entity representing a payment refund transaction.
class Refund extends Equatable {
  const Refund({
    required this.id,
    required this.paymentId,
    required this.orderId,
    required this.amount,
    required this.reason,
    required this.status,
    required this.createdAt,
    this.transactionId,
    this.processedAt,
    this.processedBy,
    this.notes,
    this.failureReason,
  });

  /// Unique identifier
  final String id;

  /// Original payment ID
  final String paymentId;

  /// Associated order ID
  final String orderId;

  /// Refund amount
  final double amount;

  /// Refund reason
  final RefundReason reason;

  /// Refund status
  final RefundStatus status;

  /// Transaction ID from payment processor
  final String? transactionId;

  /// When refund was created
  final DateTime createdAt;

  /// When refund was processed
  final DateTime? processedAt;

  /// User who processed the refund
  final String? processedBy;

  /// Additional notes
  final String? notes;

  /// Failure reason if refund failed
  final String? failureReason;

  /// Check if refund was successful
  bool get isSuccessful => status == RefundStatus.completed;

  /// Check if refund failed
  bool get isFailed => status == RefundStatus.failed;

  /// Copy with method
  Refund copyWith({
    String? id,
    String? paymentId,
    String? orderId,
    double? amount,
    RefundReason? reason,
    RefundStatus? status,
    String? transactionId,
    DateTime? createdAt,
    DateTime? processedAt,
    String? processedBy,
    String? notes,
    String? failureReason,
  }) {
    return Refund(
      id: id ?? this.id,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      notes: notes ?? this.notes,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        paymentId,
        orderId,
        amount,
        reason,
        status,
        transactionId,
        createdAt,
        processedAt,
        processedBy,
        notes,
        failureReason,
      ];
}

/// Refund reason enumeration
enum RefundReason {
  /// Customer requested refund
  customerRequest,

  /// Order was cancelled
  orderCancelled,

  /// Wrong item
  wrongItem,

  /// Item defect
  itemDefect,

  /// Service issue
  serviceIssue,

  /// Duplicate charge
  duplicateCharge,

  /// Manager override
  managerOverride,

  /// Other reason
  other,
}

/// Refund status enumeration
enum RefundStatus {
  /// Refund is pending
  pending,

  /// Refund is being processed
  processing,

  /// Refund completed
  completed,

  /// Refund failed
  failed,

  /// Refund was cancelled
  cancelled,
}

/// Extension for RefundReason display
extension RefundReasonExtension on RefundReason {
  String get displayName {
    switch (this) {
      case RefundReason.customerRequest:
        return 'Customer Request';
      case RefundReason.orderCancelled:
        return 'Order Cancelled';
      case RefundReason.wrongItem:
        return 'Wrong Item';
      case RefundReason.itemDefect:
        return 'Item Defect';
      case RefundReason.serviceIssue:
        return 'Service Issue';
      case RefundReason.duplicateCharge:
        return 'Duplicate Charge';
      case RefundReason.managerOverride:
        return 'Manager Override';
      case RefundReason.other:
        return 'Other';
    }
  }
}
