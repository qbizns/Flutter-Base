/// Waiter App Providers
/// Riverpod providers for dependency injection
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import 'datasources/table_remote_datasource.dart';
import 'models/waiter_models.dart';
import 'repositories/table_repository.dart';
import 'repositories/table_repository_impl.dart';
import 'services/table_service.dart';
import 'services/waiter_websocket_service.dart';

// ============================================================================
// Core Dependencies
// ============================================================================

/// API Client Provider (from pos_core)
/// Used for HTTP requests
final apiClientProvider = Provider<ApiClient>((ref) {
  // Get from pos_core's provider
  return ref.watch(apiProvider);
});

/// App Configuration Provider (from pos_core)
/// Contains base URLs and organization ID
final appConfigProvider = Provider<AppConfig>((ref) {
  return ref.watch(configProvider);
});

// ============================================================================
// Data Sources
// ============================================================================

/// Table Remote Data Source Provider
/// Makes API calls to backend
final tableRemoteDataSourceProvider = Provider<TableRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final config = ref.watch(appConfigProvider);

  return TableRemoteDataSourceImpl(
    apiClient: apiClient,
    organizationId: config.organizationId,
  );
});

// ============================================================================
// Repositories
// ============================================================================

/// Table Repository Provider
/// Domain layer for table operations
final tableRepositoryProvider = Provider<TableRepository>((ref) {
  final remoteDataSource = ref.watch(tableRemoteDataSourceProvider);

  return TableRepositoryImpl(
    remoteDataSource: remoteDataSource,
  );
});

// ============================================================================
// WebSocket
// ============================================================================

/// Waiter WebSocket Service Provider
/// Real-time updates for tables and orders
final waiterWebSocketServiceProvider = Provider<WaiterWebSocketService?>((ref) {
  final config = ref.watch(appConfigProvider);
  final waiter = ref.watch(currentWaiterProvider);

  // Only create WebSocket if waiter is logged in
  if (waiter == null) return null;

  final service = WaiterWebSocketService(
    baseUrl: config.apiBaseUrl,
    waiterId: waiter.id,
  );

  // Auto-connect when created
  service.connect();

  // Cleanup on dispose
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// ============================================================================
// Services
// ============================================================================

/// Table Service Provider
/// High-level service coordinating repository and real-time updates
final tableServiceProvider = Provider<TableService>((ref) {
  final repository = ref.watch(tableRepositoryProvider);
  final websocketService = ref.watch(waiterWebSocketServiceProvider);

  final service = TableService(
    repository: repository,
    websocketService: websocketService,
  );

  // Cleanup on dispose
  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

// ============================================================================
// State Providers
// ============================================================================

/// Current Waiter Provider
/// Stores the currently logged-in waiter
final currentWaiterProvider = StateProvider<Waiter?>((ref) => null);

/// Floors Provider
/// Stores list of restaurant floors
/// Auto-loads when waiter is set
final floorsProvider = FutureProvider<List<RestaurantFloor>>((ref) async {
  final service = ref.watch(tableServiceProvider);
  final waiter = ref.watch(currentWaiterProvider);

  // Only load if waiter is logged in
  if (waiter == null) {
    return [];
  }

  final result = await service.getFloors();
  return result.when(
    success: (floors) => floors,
    failure: (failure) {
      throw Exception(failure.message);
    },
  );
});

/// Selected Floor Provider
/// Tracks which floor is currently selected
final selectedFloorProvider = StateProvider<RestaurantFloor?>((ref) {
  // Auto-select first floor when floors load
  final floorsAsync = ref.watch(floorsProvider);
  return floorsAsync.whenOrNull(
    data: (floors) => floors.isNotEmpty ? floors.first : null,
  );
});

/// Tables Provider (from selected floor)
/// Returns tables for the currently selected floor
final tablesProvider = Provider<List<RestaurantTable>>((ref) {
  final selectedFloor = ref.watch(selectedFloorProvider);
  return selectedFloor?.tables ?? [];
});

/// Active Orders Provider
/// Stores list of active orders for current waiter
/// Auto-loads when waiter is set
final activeOrdersProvider = FutureProvider<List<TableOrder>>((ref) async {
  final service = ref.watch(tableServiceProvider);
  final waiter = ref.watch(currentWaiterProvider);

  // Only load if waiter is logged in
  if (waiter == null) {
    return [];
  }

  final result = await service.getActiveOrders(waiter.id);
  return result.when(
    success: (orders) => orders,
    failure: (failure) {
      throw Exception(failure.message);
    },
  );
});

/// Selected Table Provider
/// Tracks which table is currently selected/being viewed
final selectedTableProvider = StateProvider<RestaurantTable?>((ref) => null);

/// Current Order Provider
/// Tracks the order currently being edited/viewed
final currentOrderProvider = StateProvider<TableOrder?>((ref) => null);

// ============================================================================
// Connection Status
// ============================================================================

/// WebSocket Connection Status Provider
/// Tracks real-time connection status
final connectionStatusProvider = StreamProvider<WaiterConnectionStatus>((ref) {
  final websocketService = ref.watch(waiterWebSocketServiceProvider);

  if (websocketService == null) {
    return Stream.value(WaiterConnectionStatus.disconnected);
  }

  return websocketService.statusStream;
});

/// Is Connected Provider
/// Boolean indicating if currently connected to real-time updates
final isConnectedProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(connectionStatusProvider);
  final status = statusAsync.whenOrNull(data: (s) => s);
  return status == WaiterConnectionStatus.connected;
});
