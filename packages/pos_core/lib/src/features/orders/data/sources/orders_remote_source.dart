import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../../products/domain/entities/modifier.dart';

/// Remote data source for orders.
///
/// This would typically make HTTP requests to a backend API.
/// For now, it returns mock data for development.
abstract class OrdersRemoteSource {
  Future<Order> createOrder(Order order);

  Future<Order> updateOrder(Order order);

  Future<Order> getOrderById(String orderId);

  Future<List<Order>> getOrders({
    OrderStatus? status,
    OrderType? type,
    String? tableId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  Future<List<Order>> getActiveOrders();

  Future<Order> updateOrderStatus(String orderId, OrderStatus newStatus);

  Future<Order> cancelOrder(String orderId, String reason);

  Future<OrderStatistics> getOrderStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  });
}

/// Mock implementation of OrdersRemoteSource for development.
///
/// TODO: Replace with actual API implementation.
class OrdersRemoteSourceMock implements OrdersRemoteSource {
  // Mock data storage
  final List<Order> _orders = [
    Order(
      id: 'o1',
      orderNumber: 'ORD-001',
      status: OrderStatus.preparing,
      orderType: OrderType.dineIn,
      items: const [
        OrderItem(
          id: 'oi1',
          productId: 'p1',
          productName: 'Margherita Pizza',
          basePrice: 12.99,
          quantity: 1,
          selectedModifiers: [
            SelectedModifier(
              modifierId: 'm2',
              modifierName: 'Medium',
              price: 3.00,
            ),
            SelectedModifier(
              modifierId: 'm4',
              modifierName: 'Extra Cheese',
              price: 1.50,
            ),
          ],
          taxPercent: 8.5,
        ),
        OrderItem(
          id: 'oi2',
          productId: 'p2',
          productName: 'Caesar Salad',
          basePrice: 8.99,
          quantity: 2,
          taxPercent: 8.5,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      tableId: 't1',
      tableName: 'Table 5',
      subtotal: 35.47,
      taxAmount: 3.02,
      total: 38.49,
      paymentStatus: PaymentStatus.pending,
      assignedTo: 'John Doe',
    ),
    Order(
      id: 'o2',
      orderNumber: 'ORD-002',
      status: OrderStatus.ready,
      orderType: OrderType.takeaway,
      items: const [
        OrderItem(
          id: 'oi3',
          productId: 'p3',
          productName: 'Cheeseburger',
          basePrice: 10.99,
          quantity: 2,
          taxPercent: 8.5,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      updatedAt: DateTime.now().subtract(const Duration(minutes: 2)),
      customerId: 'c1',
      customerName: 'Jane Smith',
      subtotal: 21.98,
      taxAmount: 1.87,
      total: 23.85,
      paymentMethod: 'Credit Card',
      paymentStatus: PaymentStatus.paid,
      paidAmount: 23.85,
      assignedTo: 'Sarah Johnson',
    ),
    Order(
      id: 'o3',
      orderNumber: 'ORD-003',
      status: OrderStatus.completed,
      orderType: OrderType.dineIn,
      items: const [
        OrderItem(
          id: 'oi4',
          productId: 'p1',
          productName: 'Margherita Pizza',
          basePrice: 12.99,
          quantity: 1,
          selectedModifiers: [
            SelectedModifier(
              modifierId: 'm3',
              modifierName: 'Large',
              price: 5.00,
            ),
          ],
          taxPercent: 8.5,
        ),
        OrderItem(
          id: 'oi5',
          productId: 'p2',
          productName: 'Caesar Salad',
          basePrice: 8.99,
          quantity: 1,
          taxPercent: 8.5,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
      tableId: 't2',
      tableName: 'Table 3',
      subtotal: 26.98,
      taxAmount: 2.29,
      tipAmount: 5.00,
      total: 34.27,
      paymentMethod: 'Cash',
      paymentStatus: PaymentStatus.paid,
      paidAmount: 40.00,
      changeAmount: 5.73,
      assignedTo: 'John Doe',
    ),
  ];

  int _nextOrderNumber = 4;

  @override
  Future<Order> createOrder(Order order) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));

    // Generate order number if not provided
    final orderNumber = order.orderNumber.isEmpty
        ? 'ORD-${_nextOrderNumber.toString().padLeft(3, '0')}'
        : order.orderNumber;
    _nextOrderNumber++;

    // Create new order with generated values
    final newOrder = order.copyWith(
      id: 'o${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: orderNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _orders.add(newOrder);
    return newOrder;
  }

  @override
  Future<Order> updateOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final updatedOrder = order.copyWith(updatedAt: DateTime.now());
    _orders[index] = updatedOrder;
    return updatedOrder;
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => throw Exception('Order not found'),
    );
  }

  @override
  Future<List<Order>> getOrders({
    OrderStatus? status,
    OrderType? type,
    String? tableId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _orders;

    if (status != null) {
      filtered = filtered.where((o) => o.status == status).toList();
    }

    if (type != null) {
      filtered = filtered.where((o) => o.orderType == type).toList();
    }

    if (tableId != null) {
      filtered = filtered.where((o) => o.tableId == tableId).toList();
    }

    if (fromDate != null) {
      filtered = filtered.where((o) => o.createdAt.isAfter(fromDate)).toList();
    }

    if (toDate != null) {
      filtered = filtered.where((o) => o.createdAt.isBefore(toDate)).toList();
    }

    // Sort by creation date, newest first
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  @override
  Future<List<Order>> getActiveOrders() async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _orders
        .where((o) => o.isActive)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  @override
  Future<Order> updateOrderStatus(
    String orderId,
    OrderStatus newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final now = DateTime.now();
    var updatedOrder = _orders[index].copyWith(
      status: newStatus,
      updatedAt: now,
    );

    // Update completion time if status is completed
    if (newStatus == OrderStatus.completed) {
      updatedOrder = updatedOrder.copyWith(completedAt: now);
    }

    _orders[index] = updatedOrder;
    return updatedOrder;
  }

  @override
  Future<Order> cancelOrder(String orderId, String reason) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) {
      throw Exception('Order not found');
    }

    final updatedOrder = _orders[index].copyWith(
      status: OrderStatus.cancelled,
      notes: '${_orders[index].notes ?? ''}\nCancellation reason: $reason',
      updatedAt: DateTime.now(),
    );

    _orders[index] = updatedOrder;
    return updatedOrder;
  }

  @override
  Future<OrderStatistics> getOrderStatistics({
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    var filtered = _orders;

    if (fromDate != null) {
      filtered = filtered.where((o) => o.createdAt.isAfter(fromDate)).toList();
    }

    if (toDate != null) {
      filtered = filtered.where((o) => o.createdAt.isBefore(toDate)).toList();
    }

    final totalOrders = filtered.length;
    final completedOrders =
        filtered.where((o) => o.status == OrderStatus.completed).length;
    final cancelledOrders =
        filtered.where((o) => o.status == OrderStatus.cancelled).length;
    final activeOrders = filtered.where((o) => o.isActive).length;

    final totalRevenue = filtered
        .where((o) => o.status == OrderStatus.completed)
        .fold<double>(0, (sum, o) => sum + o.total);

    final averageOrderValue = completedOrders > 0 ? totalRevenue / completedOrders : 0;

    // Calculate average preparation time (mock data)
    final averagePreparationTime = const Duration(minutes: 15);

    return OrderStatistics(
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      activeOrders: activeOrders,
      totalRevenue: totalRevenue,
      averageOrderValue: averageOrderValue,
      averagePreparationTime: averagePreparationTime,
    );
  }
}
