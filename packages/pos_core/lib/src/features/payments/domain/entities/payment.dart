import 'package:equatable/equatable.dart';

/// Payment entity representing a payment transaction.
class Payment extends Equatable {
  const Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.method,
    required this.status,
    required this.createdAt,
    this.transactionId,
    this.referenceNumber,
    this.cardLastFour,
    this.cardBrand,
    this.tipAmount = 0,
    this.changeAmount = 0,
    this.notes,
    this.metadata = const {},
    this.processedAt,
    this.failureReason,
  });

  /// Unique identifier
  final String id;

  /// Associated order ID
  final String orderId;

  /// Payment amount
  final double amount;

  /// Payment method
  final PaymentMethod method;

  /// Payment status
  final PaymentStatus status;

  /// Transaction ID from payment processor
  final String? transactionId;

  /// Reference number for cash/check payments
  final String? referenceNumber;

  /// Last 4 digits of card (for card payments)
  final String? cardLastFour;

  /// Card brand (Visa, Mastercard, etc.)
  final String? cardBrand;

  /// Tip amount
  final double tipAmount;

  /// Change amount (for cash payments)
  final double changeAmount;

  /// Additional notes
  final String? notes;

  /// Additional metadata
  final Map<String, dynamic> metadata;

  /// When payment was created
  final DateTime createdAt;

  /// When payment was processed
  final DateTime? processedAt;

  /// Failure reason if payment failed
  final String? failureReason;

  /// Total amount including tip
  double get totalAmount => amount + tipAmount;

  /// Check if payment was successful
  bool get isSuccessful => status == PaymentStatus.completed;

  /// Check if payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Check if payment is pending
  bool get isPending => status == PaymentStatus.pending;

  /// Copy with method
  Payment copyWith({
    String? id,
    String? orderId,
    double? amount,
    PaymentMethod? method,
    PaymentStatus? status,
    String? transactionId,
    String? referenceNumber,
    String? cardLastFour,
    String? cardBrand,
    double? tipAmount,
    double? changeAmount,
    String? notes,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? processedAt,
    String? failureReason,
  }) {
    return Payment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      status: status ?? this.status,
      transactionId: transactionId ?? this.transactionId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      cardLastFour: cardLastFour ?? this.cardLastFour,
      cardBrand: cardBrand ?? this.cardBrand,
      tipAmount: tipAmount ?? this.tipAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      failureReason: failureReason ?? this.failureReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        amount,
        method,
        status,
        transactionId,
        referenceNumber,
        cardLastFour,
        cardBrand,
        tipAmount,
        changeAmount,
        notes,
        metadata,
        createdAt,
        processedAt,
        failureReason,
      ];
}

/// Payment method enumeration
enum PaymentMethod {
  /// Cash payment
  cash,

  /// Credit card
  creditCard,

  /// Debit card
  debitCard,

  /// Mobile payment (Apple Pay, Google Pay, etc.)
  mobileWallet,

  /// Gift card
  giftCard,

  /// Check
  check,

  /// Store credit
  storeCredit,

  /// Online payment
  online,

  /// Other method
  other,
}

/// Payment status enumeration
enum PaymentStatus {
  /// Payment is pending processing
  pending,

  /// Payment is being processed
  processing,

  /// Payment completed successfully
  completed,

  /// Payment failed
  failed,

  /// Payment was refunded
  refunded,

  /// Payment was partially refunded
  partiallyRefunded,

  /// Payment was cancelled
  cancelled,
}

/// Extension for PaymentMethod display
extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.mobileWallet:
        return 'Mobile Wallet';
      case PaymentMethod.giftCard:
        return 'Gift Card';
      case PaymentMethod.check:
        return 'Check';
      case PaymentMethod.storeCredit:
        return 'Store Credit';
      case PaymentMethod.online:
        return 'Online';
      case PaymentMethod.other:
        return 'Other';
    }
  }

  bool get requiresCardProcessing {
    return this == PaymentMethod.creditCard ||
        this == PaymentMethod.debitCard ||
        this == PaymentMethod.mobileWallet;
  }
}
