import '../../../../core/errors/result.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for cancelling an order.
class CancelOrder {
  const CancelOrder(this.repository);

  final OrdersRepository repository;

  Future<Result<Order>> call(String orderId, String reason) {
    // Additional validation could be added here
    // e.g., check if order can be cancelled based on its current status
    return repository.cancelOrder(orderId, reason);
  }
}
