import '../../../../core/errors/result.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

/// Use case for retrieving orders with optional filters.
class GetOrders {
  const GetOrders(this.repository);

  final OrdersRepository repository;

  Future<Result<List<Order>>> call({
    OrderStatus? status,
    OrderType? type,
    String? tableId,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return repository.getOrders(
      status: status,
      type: type,
      tableId: tableId,
      fromDate: fromDate,
      toDate: toDate,
    );
  }
}
