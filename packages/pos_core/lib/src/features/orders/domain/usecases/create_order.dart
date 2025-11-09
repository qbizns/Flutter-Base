import '../../../../core/errors/result.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for creating a new order.
class CreateOrder {
  const CreateOrder(this.repository);

  final OrdersRepository repository;

  Future<Result<Order>> call(Order order) {
    // Validate order before creating
    if (order.items.isEmpty) {
      return Future.value(
        Result.failure(
          const Failure(message: 'Cannot create order with no items'),
        ),
      );
    }

    return repository.createOrder(order);
  }
}
