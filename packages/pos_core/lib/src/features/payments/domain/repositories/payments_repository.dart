import '../../../../core/errors/result.dart';
import '../entities/payment.dart';
import '../entities/refund.dart';

/// Repository interface for payments.
abstract class PaymentsRepository {
  /// Process a payment
  Future<Result<Payment>> processPayment(Payment payment);

  /// Get payment by ID
  Future<Result<Payment>> getPaymentById(String id);

  /// Get payments for an order
  Future<Result<List<Payment>>> getPaymentsByOrderId(String orderId);

  /// Get all payments with filters
  Future<Result<List<Payment>>> getPayments({
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Cancel a payment
  Future<Result<Payment>> cancelPayment(String paymentId, String reason);

  /// Process a refund
  Future<Result<Refund>> processRefund(Refund refund);

  /// Get refund by ID
  Future<Result<Refund>> getRefundById(String id);

  /// Get refunds for a payment
  Future<Result<List<Refund>>> getRefundsByPaymentId(String paymentId);

  /// Get refunds for an order
  Future<Result<List<Refund>>> getRefundsByOrderId(String orderId);

  /// Get payment statistics
  Future<Result<PaymentStatistics>> getPaymentStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  });
}

/// Payment statistics
class PaymentStatistics {
  const PaymentStatistics({
    required this.totalPayments,
    required this.successfulPayments,
    required this.failedPayments,
    required this.totalAmount,
    required this.totalRefunded,
    required this.totalTips,
    required this.paymentMethodBreakdown,
  });

  final int totalPayments;
  final int successfulPayments;
  final int failedPayments;
  final double totalAmount;
  final double totalRefunded;
  final double totalTips;
  final Map<PaymentMethod, double> paymentMethodBreakdown;

  double get netAmount => totalAmount - totalRefunded;
  double get successRate =>
      totalPayments > 0 ? successfulPayments / totalPayments : 0.0;
}
