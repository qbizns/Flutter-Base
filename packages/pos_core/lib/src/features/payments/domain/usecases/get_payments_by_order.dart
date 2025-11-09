import '../../../../core/errors/result.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

/// Use case for retrieving all payments for an order.
class GetPaymentsByOrder {
  const GetPaymentsByOrder(this.repository);

  final PaymentsRepository repository;

  Future<Result<List<Payment>>> call(String orderId) {
    return repository.getPaymentsByOrderId(orderId);
  }
}
