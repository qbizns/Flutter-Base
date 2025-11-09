import '../../../../core/errors/result.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for updating an order.
class UpdateOrder {
  const UpdateOrder(this.repository);

  final OrdersRepository repository;

  Future<Result<Order>> call(Order order) {
    // Validate order before updating
    if (order.items.isEmpty) {
      return Future.value(
        Result.failure(
          const Failure(message: 'Cannot update order with no items'),
        ),
      );
    }

    return repository.updateOrder(order);
  }
}
