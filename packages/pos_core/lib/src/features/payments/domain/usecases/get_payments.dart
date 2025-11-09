import '../../../../core/errors/result.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

/// Use case for retrieving payments with optional filters.
class GetPayments {
  const GetPayments(this.repository);

  final PaymentsRepository repository;

  Future<Result<List<Payment>>> call({
    PaymentMethod? method,
    PaymentStatus? status,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return repository.getPayments(
      method: method,
      status: status,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
