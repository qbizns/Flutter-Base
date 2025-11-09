import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../sources/orders_remote_source.dart';

/// Implementation of OrdersRepository.
///
/// Coordinates between remote and local data sources to provide
/// orders data to the domain layer.
class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl({
    required this.remoteSource,
  });

  final OrdersRemoteSource remoteSource;

  @override
  Future<Result<Order>> createOrder(Order order) async {
    try {
      final createdOrder = await remoteSource.createOrder(order);
      return Result.success(createdOrder);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to create order: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Order>> updateOrder(Order order) async {
    try {
      final updatedOrder = await remoteSource.updateOrder(order);
      return Result.success(updatedOrder);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to update order: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Order>> getOrderById(String orderId) async {
    try {
      final order = await remoteSource.getOrderById(orderId);
      return Result.success(order);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch order: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Order>>> getOrders({
    OrderStatus? status,
    OrderType? type,
    String? tableId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final orders = await remoteSource.getOrders(
        status: status,
        type: type,
        tableId: tableId,
        fromDate: fromDate,
        toDate: toDate,
      );
      return Result.success(orders);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch orders: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<List<Order>>> getActiveOrders() async {
    try {
      final orders = await remoteSource.getActiveOrders();
      return Result.success(orders);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch active orders: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Order>> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    try {
      final order = await remoteSource.updateOrderStatus(orderId, newStatus);
      return Result.success(order);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to update order status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<Order>> cancelOrder(String orderId, String reason) async {
    try {
      final order = await remoteSource.cancelOrder(orderId, reason);
      return Result.success(order);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to cancel order: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<OrderStatistics>> getOrderStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      final statistics = await remoteSource.getOrderStatistics(
        fromDate: fromDate,
        toDate: toDate,
      );
      return Result.success(statistics);
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to fetch order statistics: ${e.toString()}'),
      );
    }
  }
}
