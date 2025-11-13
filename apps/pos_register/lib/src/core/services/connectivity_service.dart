/// Connectivity Service
/// Detects online/offline status and provides connectivity monitoring
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

/// Connectivity status
enum ConnectivityStatus {
  /// Online and connected
  online,

  /// Offline - no network
  offline,

  /// Unknown status
  unknown,
}

/// Connectivity service for offline detection (Odoo pattern)
class ConnectivityService {
  final Connectivity _connectivity;
  final ApiClient _apiClient;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final _statusController = StreamController<ConnectivityStatus>.broadcast();

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;
  DateTime? _lastOnlineTime;
  DateTime? _lastOfflineTime;

  ConnectivityService({
    required Connectivity connectivity,
    required ApiClient apiClient,
  })  : _connectivity = connectivity,
        _apiClient = apiClient {
    _initialize();
  }

  /// Current connectivity status
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Is currently online
  bool get isOnline => _currentStatus == ConnectivityStatus.online;

  /// Is currently offline
  bool get isOffline => _currentStatus == ConnectivityStatus.offline;

  /// Last time device was online
  DateTime? get lastOnlineTime => _lastOnlineTime;

  /// Last time device went offline
  DateTime? get lastOfflineTime => _lastOfflineTime;

  /// How long the device has been offline
  Duration? get offlineDuration {
    if (_lastOfflineTime == null || isOnline) return null;
    return DateTime.now().difference(_lastOfflineTime!);
  }

  /// Initialize connectivity monitoring
  void _initialize() {
    // Check initial status
    _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        _checkConnectivity();
      },
    );
  }

  /// Check current connectivity and update status
  Future<void> _checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();

      // If no connection, mark as offline
      if (results.contains(ConnectivityResult.none)) {
        _updateStatus(ConnectivityStatus.offline);
        return;
      }

      // If we have a connection, verify with a ping to the backend
      final isReachable = await _pingBackend();

      if (isReachable) {
        _updateStatus(ConnectivityStatus.online);
      } else {
        // Have network but can't reach backend
        _updateStatus(ConnectivityStatus.offline);
      }
    } catch (e) {
      _updateStatus(ConnectivityStatus.offline);
    }
  }

  /// Ping the backend to verify connectivity
  Future<bool> _pingBackend() async {
    try {
      // Try to reach the health endpoint with short timeout
      final response = await _apiClient
          .get('/health')
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Update connectivity status
  void _updateStatus(ConnectivityStatus newStatus) {
    if (_currentStatus == newStatus) return;

    final oldStatus = _currentStatus;
    _currentStatus = newStatus;

    // Track timing
    if (newStatus == ConnectivityStatus.online) {
      _lastOnlineTime = DateTime.now();
    } else if (newStatus == ConnectivityStatus.offline) {
      _lastOfflineTime = DateTime.now();
    }

    // Notify listeners
    _statusController.add(newStatus);

    // Log status change
    print(
      'Connectivity changed: ${oldStatus.name} -> ${newStatus.name} at ${DateTime.now()}',
    );
  }

  /// Manually check connectivity (force refresh)
  Future<void> checkConnectivity() async {
    await _checkConnectivity();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}

/// Provider for connectivity service
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final connectivity = Connectivity();
  final apiClient = ref.watch(apiClientProvider);

  final service = ConnectivityService(
    connectivity: connectivity,
    apiClient: apiClient,
  );

  ref.onDispose(() {
    service.dispose();
  });

  return service;
});

/// Provider for current connectivity status
final connectivityStatusProvider =
    StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);

  // Emit current status first
  return Stream.value(service.currentStatus).asyncExpand(
    (initial) sync* {
      yield initial;
      yield* service.statusStream;
    },
  );
});

/// Provider to check if device is online
final isOnlineProvider = Provider<bool>((ref) {
  final statusAsync = ref.watch(connectivityStatusProvider);

  return statusAsync.when(
    data: (status) => status == ConnectivityStatus.online,
    loading: () => true, // Assume online while checking
    error: (_, __) => false,
  );
});

/// Provider to check if device is offline
final isOfflineProvider = Provider<bool>((ref) {
  return !ref.watch(isOnlineProvider);
});
