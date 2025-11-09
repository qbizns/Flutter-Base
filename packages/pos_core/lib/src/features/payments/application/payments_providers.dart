import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/payments_repository_impl.dart';
import '../data/sources/payments_remote_source.dart';
import '../domain/entities/payment.dart';
import '../domain/entities/refund.dart';
import '../domain/repositories/payments_repository.dart';
import '../domain/usecases/cancel_payment.dart';
import '../domain/usecases/get_payments.dart';
import '../domain/usecases/get_payments_by_order.dart';
import '../domain/usecases/process_payment.dart';
import '../domain/usecases/process_refund.dart';

part 'payments_providers.g.dart';

/// Provides the payments remote data source.
@riverpod
PaymentsRemoteSource paymentsRemoteSource(PaymentsRemoteSourceRef ref) {
  // TODO: Replace with actual API implementation and payment processor integration
  return PaymentsRemoteSourceMock();
}

/// Provides the payments repository.
@riverpod
PaymentsRepository paymentsRepository(PaymentsRepositoryRef ref) {
  final remoteSource = ref.watch(paymentsRemoteSourceProvider);
  return PaymentsRepositoryImpl(remoteSource: remoteSource);
}

/// Provides ProcessPayment use case.
@riverpod
ProcessPayment processPaymentUseCase(ProcessPaymentUseCaseRef ref) {
  final repository = ref.watch(paymentsRepositoryProvider);
  return ProcessPayment(repository);
}

/// Provides ProcessRefund use case.
@riverpod
ProcessRefund processRefundUseCase(ProcessRefundUseCaseRef ref) {
  final repository = ref.watch(paymentsRepositoryProvider);
  return ProcessRefund(repository);
}

/// Provides GetPayments use case.
@riverpod
GetPayments getPaymentsUseCase(GetPaymentsUseCaseRef ref) {
  final repository = ref.watch(paymentsRepositoryProvider);
  return GetPayments(repository);
}

/// Provides GetPaymentsByOrder use case.
@riverpod
GetPaymentsByOrder getPaymentsByOrderUseCase(
  GetPaymentsByOrderUseCaseRef ref,
) {
  final repository = ref.watch(paymentsRepositoryProvider);
  return GetPaymentsByOrder(repository);
}

/// Provides CancelPayment use case.
@riverpod
CancelPayment cancelPaymentUseCase(CancelPaymentUseCaseRef ref) {
  final repository = ref.watch(paymentsRepositoryProvider);
  return CancelPayment(repository);
}

/// Provides a single payment by ID.
@riverpod
Future<Payment> payment(PaymentRef ref, String paymentId) async {
  final repository = ref.watch(paymentsRepositoryProvider);
  final result = await repository.getPaymentById(paymentId);

  return result.when(
    success: (payment) => payment,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides payments for an order.
@riverpod
Future<List<Payment>> paymentsByOrder(
  PaymentsByOrderRef ref,
  String orderId,
) async {
  final useCase = ref.watch(getPaymentsByOrderUseCaseProvider);
  final result = await useCase(orderId);

  return result.when(
    success: (payments) => payments,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides payments filtered by method, status, etc.
@riverpod
Future<List<Payment>> payments(
  PaymentsRef ref, {
  PaymentMethod? method,
  PaymentStatus? status,
  DateTime? fromDate,
  DateTime? toDate,
}) async {
  final useCase = ref.watch(getPaymentsUseCaseProvider);
  final result = await useCase(
    method: method,
    status: status,
    fromDate: fromDate,
    toDate: toDate,
  );

  return result.when(
    success: (payments) => payments,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides a single refund by ID.
@riverpod
Future<Refund> refund(RefundRef ref, String refundId) async {
  final repository = ref.watch(paymentsRepositoryProvider);
  final result = await repository.getRefundById(refundId);

  return result.when(
    success: (refund) => refund,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides refunds for a payment.
@riverpod
Future<List<Refund>> refundsByPayment(
  RefundsByPaymentRef ref,
  String paymentId,
) async {
  final repository = ref.watch(paymentsRepositoryProvider);
  final result = await repository.getRefundsByPaymentId(paymentId);

  return result.when(
    success: (refunds) => refunds,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides refunds for an order.
@riverpod
Future<List<Refund>> refundsByOrder(
  RefundsByOrderRef ref,
  String orderId,
) async {
  final repository = ref.watch(paymentsRepositoryProvider);
  final result = await repository.getRefundsByOrderId(orderId);

  return result.when(
    success: (refunds) => refunds,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides payment statistics.
@riverpod
Future<PaymentStatistics> paymentStatistics(
  PaymentStatisticsRef ref, {
  DateTime? fromDate,
  DateTime? toDate,
}) async {
  final repository = ref.watch(paymentsRepositoryProvider);
  final result = await repository.getPaymentStatistics(
    fromDate: fromDate,
    toDate: toDate,
  );

  return result.when(
    success: (stats) => stats,
    failure: (failure) => throw Exception(failure.message),
  );
}
