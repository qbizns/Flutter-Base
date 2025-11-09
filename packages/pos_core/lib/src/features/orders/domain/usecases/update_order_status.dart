import '../../../../core/errors/result.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for updating an order's status.
class UpdateOrderStatus {
  const UpdateOrderStatus(this.repository);

  final OrdersRepository repository;

  Future<Result<Order>> call(String orderId, OrderStatus newStatus) {
    return repository.updateOrderStatus(orderId, newStatus);
  }
}
