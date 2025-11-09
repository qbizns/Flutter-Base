import '../../../../core/errors/result.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

/// Use case for cancelling a payment.
class CancelPayment {
  const CancelPayment(this.repository);

  final PaymentsRepository repository;

  Future<Result<Payment>> call(String paymentId, String reason) {
    return repository.cancelPayment(paymentId, reason);
  }
}
