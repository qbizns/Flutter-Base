import '../../../../core/errors/result.dart';
import '../entities/order.dart';

/// Orders repository interface.
///
/// Defines operations for managing orders in the POS system.
abstract class OrdersRepository {
  /// Create a new order
  Future<Result<Order>> createOrder(Order order);

  /// Update an existing order
  Future<Result<Order>> updateOrder(Order order);

  /// Get order by ID
  Future<Result<Order>> getOrderById(String orderId);

  /// Get all orders with optional filters
  Future<Result<List<Order>>> getOrders({
    OrderStatus? status,
    OrderType? type,
    String? tableId,
    DateTime? fromDate,
    DateTime? toDate,
    int? limit,
  });

  /// Get orders for current shift/session
  Future<Result<List<Order>>> getActiveOrders();

  /// Get orders by table
  Future<Result<List<Order>>> getOrdersByTable(String tableId);

  /// Update order status
  Future<Result<Order>> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  );

  /// Cancel order
  Future<Result<Order>> cancelOrder(
    String orderId,
    String reason,
  );

  /// Complete order
  Future<Result<Order>> completeOrder(String orderId);

  /// Add payment to order
  Future<Result<Order>> addPayment(
    String orderId, {
    required double amount,
    required String paymentMethod,
  });

  /// Get order statistics
  Future<Result<OrderStatistics>> getOrderStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  });
}

/// Order statistics model
class OrderStatistics {
  const OrderStatistics({
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.ordersByStatus,
    required this.ordersByType,
  });

  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final Map<OrderStatus, int> ordersByStatus;
  final Map<OrderType, int> ordersByType;
}
