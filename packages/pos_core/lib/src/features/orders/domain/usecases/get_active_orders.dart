import '../../../../core/errors/result.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for retrieving all active orders.
///
/// Active orders are those that are not completed or cancelled.
class GetActiveOrders {
  const GetActiveOrders(this.repository);

  final OrdersRepository repository;

  Future<Result<List<Order>>> call() {
    return repository.getActiveOrders();
  }
}
