import '../../../../core/errors/result.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for retrieving a single order by ID.
class GetOrderById {
  const GetOrderById(this.repository);

  final OrdersRepository repository;

  Future<Result<Order>> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}
