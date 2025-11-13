import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repositories/orders_repository_impl.dart';
import '../data/sources/orders_remote_source.dart';
import '../domain/entities/cart.dart';
import '../domain/entities/order.dart';
import '../domain/entities/order_item.dart';
import '../domain/repositories/orders_repository.dart';
import '../domain/usecases/cancel_order.dart';
import '../domain/usecases/create_order.dart';
import '../domain/usecases/get_active_orders.dart';
import '../domain/usecases/get_order_by_id.dart';
import '../domain/usecases/get_orders.dart';
import '../domain/usecases/update_order.dart';
import '../domain/usecases/update_order_status.dart';
import '../../../core/network/api_providers.dart';
import '../../../core/config/config_providers.dart';
import '../../../core/context/context_providers.dart';

part 'orders_providers.g.dart';

/// Provides the orders remote data source.
@riverpod
OrdersRemoteSource ordersRemoteSource(OrdersRemoteSourceRef ref) {
  final config = ref.watch(appConfigProvider);
  final context = ref.watch(appContextProvider);

  // Use HTTP implementation if API URL is configured and we have tenant ID
  if (config.apiBaseUrl.isNotEmpty && context.tenantId != null) {
    final apiClient = ref.watch(apiClientProvider);
    return OrdersRemoteSourceHttp(
      apiClient: apiClient,
      organizationId: context.tenantId!,
    );
  }

  // Fall back to mock for development/testing
  return OrdersRemoteSourceMock();
}

/// Provides the orders repository.
@riverpod
OrdersRepository ordersRepository(OrdersRepositoryRef ref) {
  final remoteSource = ref.watch(ordersRemoteSourceProvider);
  return OrdersRepositoryImpl(remoteSource: remoteSource);
}

/// Provides CreateOrder use case.
@riverpod
CreateOrder createOrderUseCase(CreateOrderUseCaseRef ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return CreateOrder(repository);
}

/// Provides UpdateOrder use case.
@riverpod
UpdateOrder updateOrderUseCase(UpdateOrderUseCaseRef ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return UpdateOrder(repository);
}

/// Provides GetOrders use case.
@riverpod
GetOrders getOrdersUseCase(GetOrdersUseCaseRef ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return GetOrders(repository);
}

/// Provides GetActiveOrders use case.
@riverpod
GetActiveOrders getActiveOrdersUseCase(GetActiveOrdersUseCaseRef ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return GetActiveOrders(repository);
}

/// Provides GetOrderById use case.
@riverpod
GetOrderById getOrderByIdUseCase(GetOrderByIdUseCaseRef ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return GetOrderById(repository);
}

/// Provides UpdateOrderStatus use case.
@riverpod
UpdateOrderStatus updateOrderStatusUseCase(UpdateOrderStatusUseCaseRef ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return UpdateOrderStatus(repository);
}

/// Provides CancelOrder use case.
@riverpod
CancelOrder cancelOrderUseCase(CancelOrderUseCaseRef ref) {
  final repository = ref.watch(ordersRepositoryProvider);
  return CancelOrder(repository);
}

/// Provides a single order by ID.
@riverpod
Future<Order> order(OrderRef ref, String orderId) async {
  final useCase = ref.watch(getOrderByIdUseCaseProvider);
  final result = await useCase(orderId);

  return result.when(
    success: (order) => order,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides the list of all active orders.
@riverpod
Future<List<Order>> activeOrders(ActiveOrdersRef ref) async {
  final useCase = ref.watch(getActiveOrdersUseCaseProvider);
  final result = await useCase();

  return result.when(
    success: (orders) => orders,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides orders filtered by status, type, etc.
@riverpod
Future<List<Order>> orders(
  OrdersRef ref, {
  OrderStatus? status,
  OrderType? type,
  String? tableId,
  DateTime? fromDate,
  DateTime? toDate,
}) async {
  final useCase = ref.watch(getOrdersUseCaseProvider);
  final result = await useCase(
    status: status,
    type: type,
    tableId: tableId,
    fromDate: fromDate,
    toDate: toDate,
  );

  return result.when(
    success: (orders) => orders,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Provides order statistics.
@riverpod
Future<OrderStatistics> orderStatistics(
  OrderStatisticsRef ref, {
  DateTime? fromDate,
  DateTime? toDate,
}) async {
  final repository = ref.watch(ordersRepositoryProvider);
  final result = await repository.getOrderStatistics(
    fromDate: fromDate,
    toDate: toDate,
  );

  return result.when(
    success: (stats) => stats,
    failure: (failure) => throw Exception(failure.message),
  );
}

/// Cart state notifier for managing the current order being built.
@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  Cart build() {
    return const Cart();
  }

  /// Add an item to the cart
  void addItem(OrderItem item) {
    state = state.addItem(item);
  }

  /// Remove an item from the cart
  void removeItem(String itemId) {
    state = state.removeItem(itemId);
  }

  /// Update item quantity
  void updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
    } else {
      state = state.updateItemQuantity(itemId, newQuantity);
    }
  }

  /// Update item notes
  void updateItemNotes(String itemId, String notes) {
    state = state.updateItemNotes(itemId, notes);
  }

  /// Apply discount to cart
  void applyDiscount({double? amount, double? percent}) {
    state = state.applyDiscount(amount: amount, percent: percent);
  }

  /// Remove discount from cart
  void removeDiscount() {
    state = state.removeDiscount();
  }

  /// Set tip amount
  void setTip(double amount) {
    state = state.setTip(amount);
  }

  /// Set customer
  void setCustomer(String? customerId, String? customerName) {
    state = state.setCustomer(customerId, customerName);
  }

  /// Set order notes
  void setNotes(String? notes) {
    state = state.copyWith(notes: notes);
  }

  /// Set table
  void setTable(String? tableId, String? tableName) {
    state = state.setTable(tableId, tableName);
  }

  /// Clear the cart
  void clear() {
    state = const Cart();
  }

  /// Create order from current cart
  Future<Order> checkout({
    required OrderType orderType,
    String? tableId,
    String? tableName,
    String? customerId,
    String? customerName,
    String? notes,
  }) async {
    if (state.isEmpty) {
      throw Exception('Cannot checkout with empty cart');
    }

    final order = Order(
      id: '', // Will be generated by backend
      orderNumber: '', // Will be generated by backend
      status: OrderStatus.pending,
      orderType: orderType,
      items: state.items,
      createdAt: DateTime.now(),
      tableId: tableId,
      tableName: tableName,
      customerId: customerId,
      customerName: customerName,
      notes: notes,
      subtotal: state.subtotal,
      discountAmount: state.discountAmount,
      discountPercent: state.discountPercent,
      taxAmount: state.taxAmount,
      tipAmount: state.tipAmount,
      total: state.total,
      paymentStatus: PaymentStatus.pending,
    );

    final createUseCase = ref.read(createOrderUseCaseProvider);
    final result = await createUseCase(order);

    return result.when(
      success: (createdOrder) {
        // Clear cart after successful order creation
        clear();
        return createdOrder;
      },
      failure: (failure) => throw Exception(failure.message),
    );
  }
}
