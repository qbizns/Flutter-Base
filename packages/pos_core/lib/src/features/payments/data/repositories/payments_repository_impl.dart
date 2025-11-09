import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/payment.dart';
import '../../domain/entities/refund.dart';
import '../../domain/repositories/payments_repository.dart';
import '../sources/payments_remote_source.dart';

/// Implementation of PaymentsRepository.
class PaymentsRepositoryImpl implements PaymentsRepository {
  const PaymentsRepositoryImpl({
    required this.remoteSource,
  });

  final PaymentsRemoteSource remoteSource;

  @override
  Future<Result<Payment>> processPayment(Payment payment) async {
    try {
      final processedPayment = await remoteSource.processPayment(payment);
      return Result.success(processedPayment);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to process payment: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Payment>> getPaymentById(String id) async {
    try {
      final payment = await remoteSource.getPaymentById(id);
      return Result.success(payment);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch payment: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Payment>>> getPaymentsByOrderId(String orderId) async {
    try {
      final payments = await remoteSource.getPaymentsByOrderId(orderId);
      return Result.success(payments);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch payments: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Payment>>> getPayments({
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final payments = await remoteSource.getPayments(
        method: method,
        status: status,
        fromDate: fromDate,
        toDate: toDate,
      );
      return Result.success(payments);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch payments: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Payment>> cancelPayment(String paymentId, String reason) async {
    try {
      final payment = await remoteSource.cancelPayment(paymentId, reason);
      return Result.success(payment);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to cancel payment: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Refund>> processRefund(Refund refund) async {
    try {
      final processedRefund = await remoteSource.processRefund(refund);
      return Result.success(processedRefund);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to process refund: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Refund>> getRefundById(String id) async {
    try {
      final refund = await remoteSource.getRefundById(id);
      return Result.success(refund);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch refund: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Refund>>> getRefundsByPaymentId(String paymentId) async {
    try {
      final refunds = await remoteSource.getRefundsByPaymentId(paymentId);
      return Result.success(refunds);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch refunds: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Refund>>> getRefundsByOrderId(String orderId) async {
    try {
      final refunds = await remoteSource.getRefundsByOrderId(orderId);
      return Result.success(refunds);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch refunds: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<PaymentStatistics>> getPaymentStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final statistics = await remoteSource.getPaymentStatistics(
        fromDate: fromDate,
        toDate: toDate,
      );
      return Result.success(statistics);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch payment statistics: ${e.toString()}'),
      );
    }
  }
}
