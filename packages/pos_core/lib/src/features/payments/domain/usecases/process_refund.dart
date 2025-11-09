import '../../../../core/errors/result.dart';
import '../entities/refund.dart';
import '../repositories/payments_repository.dart';

/// Use case for processing a refund.
class ProcessRefund {
  const ProcessRefund(this.repository);

  final PaymentsRepository repository;

  Future<Result<Refund>> call(Refund refund) {
    // Validate refund before processing
    if (refund.amount <= 0) {
      return Future.value(
        Result.failure(
          const Failure(message: 'Refund amount must be greater than 0'),
        ),
      );
    }

    return repository.processRefund(refund);
  }
}
