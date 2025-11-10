import 'package:pos_core/pos_core.dart';

/// Payment Method
enum PaymentMethod {
  cash('Cash', 'payment_cash'),
  card('Credit/Debit Card', 'payment_card'),
  digitalWallet('Digital Wallet', 'payment_wallet'),
  giftCard('Gift Card', 'payment_gift_card');

  final String label;
  final String code;

  const PaymentMethod(this.label, this.code);
}

/// Transaction Status
enum TransactionStatus {
  pending('Pending'),
  completed('Completed'),
  refunded('Refunded'),
  voided('Voided');

  final String label;

  const TransactionStatus(this.label);
}

/// Payment Transaction
class Transaction {
  final String id;
  final String orderId;
  final double subtotal;
  final double tax;
  final double tip;
  final double discount;
  final double total;
  final PaymentMethod paymentMethod;
  final TransactionStatus status;
  final DateTime timestamp;
  final String cashierId;
  final String cashierName;
  final String? customerId;
  final String? customerName;
  final double? cashTendered;
  final double? change;
  final String? cardLastFour;
  final String? receiptNumber;

  const Transaction({
    required this.id,
    required this.orderId,
    required this.subtotal,
    required this.tax,
    required this.tip,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    required this.timestamp,
    required this.cashierId,
    required this.cashierName,
    this.customerId,
    this.customerName,
    this.cashTendered,
    this.change,
    this.cardLastFour,
    this.receiptNumber,
  });

  Transaction copyWith({
    String? id,
    String? orderId,
    double? subtotal,
    double? tax,
    double? tip,
    double? discount,
    double? total,
    PaymentMethod? paymentMethod,
    TransactionStatus? status,
    DateTime? timestamp,
    String? cashierId,
    String? cashierName,
    String? customerId,
    String? customerName,
    double? cashTendered,
    double? change,
    String? cardLastFour,
    String? receiptNumber,
  }) {
    return Transaction(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      tip: tip ?? this.tip,
      discount: discount ?? this.discount,
      total: total ?? this.total,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      cashTendered: cashTendered ?? this.cashTendered,
      change: change ?? this.change,
      cardLastFour: cardLastFour ?? this.cardLastFour,
      receiptNumber: receiptNumber ?? this.receiptNumber,
    );
  }
}
