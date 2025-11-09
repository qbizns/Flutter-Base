import '../../../../core/errors/result.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

/// Use case for processing a payment.
class ProcessPayment {
  const ProcessPayment(this.repository);

  final PaymentsRepository repository;

  Future<Result<Payment>> call(Payment payment) {
    // Validate payment before processing
    if (payment.amount <= 0) {
      return Future.value(
        Result.failure(
          const Failure(message: 'Payment amount must be greater than 0'),
        ),
      );
    }

    return repository.processPayment(payment);
  }
}
