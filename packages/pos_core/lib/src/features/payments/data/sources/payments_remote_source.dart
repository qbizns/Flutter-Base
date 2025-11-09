import '../../domain/entities/payment.dart';
import '../../domain/entities/refund.dart';
import '../../domain/repositories/payments_repository.dart';

/// Remote data source for payments.
///
/// This would typically make HTTP requests to a backend API
/// and integrate with payment processors.
/// For now, it returns mock data for development.
abstract class PaymentsRemoteSource {
  Future<Payment> processPayment(Payment payment);

  Future<Payment> getPaymentById(String id);

  Future<List<Payment>> getPaymentsByOrderId(String orderId);

  Future<List<Payment>> getPayments({
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<Payment> cancelPayment(String paymentId, String reason);

  Future<Refund> processRefund(Refund refund);

  Future<Refund> getRefundById(String id);

  Future<List<Refund>> getRefundsByPaymentId(String paymentId);

  Future<List<Refund>> getRefundsByOrderId(String orderId);

  Future<PaymentStatistics> getPaymentStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  });
}

/// Mock implementation of PaymentsRemoteSource for development.
///
/// TODO: Replace with actual API implementation and payment processor integration.
class PaymentsRemoteSourceMock implements PaymentsRemoteSource {
  // Mock data storage
  final List<Payment> _payments = [
    Payment(
      id: 'pay1',
      orderId: 'o2',
      amount: 23.85,
      method: PaymentMethod.creditCard,
      status: PaymentStatus.completed,
      transactionId: 'txn_123456789',
      cardLastFour: '4242',
      cardBrand: 'Visa',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      processedAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    Payment(
      id: 'pay2',
      orderId: 'o3',
      amount: 29.27,
      method: PaymentMethod.cash,
      status: PaymentStatus.completed,
      referenceNumber: 'CASH-001',
      tipAmount: 5.00,
      changeAmount: 5.73,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      processedAt: DateTime.now().subtract(const Duration(hours: 1)),
    ),
  ];

  final List<Refund> _refunds = [];

  @override
  Future<Payment> processPayment(Payment payment) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulate payment processing
    final processedPayment = payment.copyWith(
      id: 'pay${DateTime.now().millisecondsSinceEpoch}',
      status: PaymentStatus.completed,
      transactionId: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      processedAt: DateTime.now(),
    );

    _payments.add(processedPayment);
    return processedPayment;
  }

  @override
  Future<Payment> getPaymentById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _payments.firstWhere(
      (p) => p.id == id,
      orElse: () => throw Exception('Payment not found'),
    );
  }

  @override
  Future<List<Payment>> getPaymentsByOrderId(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _payments.where((p) => p.orderId == orderId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Payment>> getPayments({
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _payments;

    if (method != null) {
      filtered = filtered.where((p) => p.method == method).toList();
    }

    if (status != null) {
      filtered = filtered.where((p) => p.status == status).toList();
    }

    if (fromDate != null) {
      filtered = filtered.where((p) => p.createdAt.isAfter(fromDate)).toList();
    }

    if (toDate != null) {
      filtered = filtered.where((p) => p.createdAt.isBefore(toDate)).toList();
    }

    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  @override
  Future<Payment> cancelPayment(String paymentId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _payments.indexWhere((p) => p.id == paymentId);
    if (index == -1) {
      throw Exception('Payment not found');
    }

    final cancelledPayment = _payments[index].copyWith(
      status: PaymentStatus.cancelled,
      notes: 'Cancelled: $reason',
    );

    _payments[index] = cancelledPayment;
    return cancelledPayment;
  }

  @override
  Future<Refund> processRefund(Refund refund) async {
    await Future.delayed(const Duration(milliseconds: 500));

    // Validate payment exists
    final payment = _payments.firstWhere(
      (p) => p.id == refund.paymentId,
      orElse: () => throw Exception('Payment not found'),
    );

    // Simulate refund processing
    final processedRefund = refund.copyWith(
      id: 'ref${DateTime.now().millisecondsSinceEpoch}',
      status: RefundStatus.completed,
      transactionId: 'refund_${DateTime.now().millisecondsSinceEpoch}',
      processedAt: DateTime.now(),
    );

    _refunds.add(processedRefund);

    // Update payment status
    final paymentIndex = _payments.indexWhere((p) => p.id == payment.id);
    _payments[paymentIndex] = payment.copyWith(
      status: PaymentStatus.refunded,
    );

    return processedRefund;
  }

  @override
  Future<Refund> getRefundById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _refunds.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Refund not found'),
    );
  }

  @override
  Future<List<Refund>> getRefundsByPaymentId(String paymentId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _refunds.where((r) => r.paymentId == paymentId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<List<Refund>> getRefundsByOrderId(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _refunds.where((r) => r.orderId == orderId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<PaymentStatistics> getPaymentStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _payments;

    if (fromDate != null) {
      filtered = filtered.where((p) => p.createdAt.isAfter(fromDate)).toList();
    }

    if (toDate != null) {
      filtered = filtered.where((p) => p.createdAt.isBefore(toDate)).toList();
    }

    final totalPayments = filtered.length;
    final successfulPayments =
        filtered.where((p) => p.status == PaymentStatus.completed).length;
    final failedPayments =
        filtered.where((p) => p.status == PaymentStatus.failed).length;

    final totalAmount = filtered
        .where((p) => p.status == PaymentStatus.completed)
        .fold<double>(0, (sum, p) => sum + p.amount);

    final totalTips = filtered
        .where((p) => p.status == PaymentStatus.completed)
        .fold<double>(0, (sum, p) => sum + p.tipAmount);

    final totalRefunded = _refunds
        .where((r) => r.status == RefundStatus.completed)
        .fold<double>(0, (sum, r) => sum + r.amount);

    // Calculate payment method breakdown
    final paymentMethodBreakdown = <PaymentMethod, double>{};
    for (final method in PaymentMethod.values) {
      final methodPayments = filtered.where(
        (p) => p.method == method && p.status == PaymentStatus.completed,
      );
      if (methodPayments.isNotEmpty) {
        paymentMethodBreakdown[method] =
            methodPayments.fold<double>(0, (sum, p) => sum + p.amount);
      }
    }

    return PaymentStatistics(
      totalPayments: totalPayments,
      successfulPayments: successfulPayments,
      failedPayments: failedPayments,
      totalAmount: totalAmount,
      totalRefunded: totalRefunded,
      totalTips: totalTips,
      paymentMethodBreakdown: paymentMethodBreakdown,
    );
  }
}
