import 'package:dio/dio.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/refund.dart';
import '../../domain/repositories/payments_repository.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/errors/exceptions.dart';

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

/// HTTP implementation of PaymentsRemoteSource.
/// Makes actual API calls to the backend.
class PaymentsRemoteSourceHttp implements PaymentsRemoteSource {
  PaymentsRemoteSourceHttp({
    required ApiClient apiClient,
    required String organizationId,
  })  : _apiClient = apiClient,
        _orgId = organizationId;

  final ApiClient _apiClient;
  final String _orgId;

  String get _paymentsPath => '/organizations/$_orgId/payments';
  String get _refundsPath => '/organizations/$_orgId/refunds';

  @override
  Future<Payment> processPayment(Payment payment) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _paymentsPath,
        data: _paymentToJson(payment),
      );

      return _paymentFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Payment> getPaymentById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_paymentsPath/$id',
      );

      return _paymentFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Payment>> getPaymentsByOrderId(String orderId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _paymentsPath,
        queryParameters: {'order_id': orderId},
      );

      final data = response.data!['data'] as List;
      return data.map((json) => _paymentFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Payment>> getPayments({
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (method != null) queryParams['method'] = method.name;
      if (status != null) queryParams['status'] = status.name;
      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();

      final response = await _apiClient.get<Map<String, dynamic>>(
        _paymentsPath,
        queryParameters: queryParams,
      );

      final data = response.data!['data'] as List;
      return data.map((json) => _paymentFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Payment> cancelPayment(String paymentId, String reason) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        '$_paymentsPath/$paymentId/cancel',
        data: {'reason': reason},
      );

      return _paymentFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Refund> processRefund(Refund refund) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _refundsPath,
        data: _refundToJson(refund),
      );

      return _refundFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Refund> getRefundById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_refundsPath/$id',
      );

      return _refundFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Refund>> getRefundsByPaymentId(String paymentId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _refundsPath,
        queryParameters: {'payment_id': paymentId},
      );

      final data = response.data!['data'] as List;
      return data.map((json) => _refundFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<Refund>> getRefundsByOrderId(String orderId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _refundsPath,
        queryParameters: {'order_id': orderId},
      );

      final data = response.data!['data'] as List;
      return data.map((json) => _refundFromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<PaymentStatistics> getPaymentStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (fromDate != null) queryParams['from_date'] = fromDate.toIso8601String();
      if (toDate != null) queryParams['to_date'] = toDate.toIso8601String();

      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_paymentsPath/statistics',
        queryParameters: queryParams,
      );

      return _paymentStatisticsFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // JSON serialization helpers
  Map<String, dynamic> _paymentToJson(Payment payment) {
    return {
      if (payment.id.isNotEmpty) 'id': payment.id,
      'order_id': payment.orderId,
      'amount': payment.amount,
      'method': payment.method.name,
      'status': payment.status.name,
      'transaction_id': payment.transactionId,
      'reference_number': payment.referenceNumber,
      'card_last_four': payment.cardLastFour,
      'card_brand': payment.cardBrand,
      'tip_amount': payment.tipAmount,
      'change_amount': payment.changeAmount,
      'notes': payment.notes,
      'metadata': payment.metadata,
    };
  }

  Payment _paymentFromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: PaymentMethod.values.firstWhere(
        (e) => e.name == json['method'],
        orElse: () => PaymentMethod.cash,
      ),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      transactionId: json['transaction_id'] as String?,
      referenceNumber: json['reference_number'] as String?,
      cardLastFour: json['card_last_four'] as String?,
      cardBrand: json['card_brand'] as String?,
      tipAmount: (json['tip_amount'] as num?)?.toDouble() ?? 0,
      changeAmount: (json['change_amount'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      failureReason: json['failure_reason'] as String?,
    );
  }

  Map<String, dynamic> _refundToJson(Refund refund) {
    return {
      if (refund.id.isNotEmpty) 'id': refund.id,
      'payment_id': refund.paymentId,
      'order_id': refund.orderId,
      'amount': refund.amount,
      'reason': refund.reason.name,
      'status': refund.status.name,
      'transaction_id': refund.transactionId,
      'processed_by': refund.processedBy,
      'notes': refund.notes,
    };
  }

  Refund _refundFromJson(Map<String, dynamic> json) {
    return Refund(
      id: json['id'] as String,
      paymentId: json['payment_id'] as String,
      orderId: json['order_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      reason: RefundReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => RefundReason.other,
      ),
      status: RefundStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RefundStatus.pending,
      ),
      transactionId: json['transaction_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      processedAt: json['processed_at'] != null
          ? DateTime.parse(json['processed_at'] as String)
          : null,
      processedBy: json['processed_by'] as String?,
      notes: json['notes'] as String?,
      failureReason: json['failure_reason'] as String?,
    );
  }

  PaymentStatistics _paymentStatisticsFromJson(Map<String, dynamic> json) {
    final paymentMethodBreakdown = <PaymentMethod, double>{};
    final breakdownJson = json['payment_method_breakdown'] as Map<String, dynamic>?;

    if (breakdownJson != null) {
      breakdownJson.forEach((key, value) {
        final method = PaymentMethod.values.firstWhere(
          (e) => e.name == key,
          orElse: () => PaymentMethod.other,
        );
        paymentMethodBreakdown[method] = (value as num).toDouble();
      });
    }

    return PaymentStatistics(
      totalPayments: json['total_payments'] as int,
      successfulPayments: json['successful_payments'] as int,
      failedPayments: json['failed_payments'] as int,
      totalAmount: (json['total_amount'] as num).toDouble(),
      totalRefunded: (json['total_refunded'] as num).toDouble(),
      totalTips: (json['total_tips'] as num).toDouble(),
      paymentMethodBreakdown: paymentMethodBreakdown,
    );
  }
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
