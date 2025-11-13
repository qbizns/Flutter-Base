/// Waiter Real-Time Service
/// Handles WebSocket communication for multi-device POS synchronization
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/config/waiter_config.dart';

/// WebSocket connection status
enum WaiterConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket event types (Odoo multi-device pattern)
enum WaiterEventType {
  /// Table status changed (occupied, available, reserved)
  tableStatusChanged,

  /// Order created on another device
  orderCreated,

  /// Order updated on another device
  orderUpdated,

  /// Order status changed (confirmed, preparing, ready, completed)
  orderStatusChanged,

  /// Order cancelled
  orderCancelled,

  /// Session closed by manager
  sessionClosed,

  /// Keepalive ping
  ping,
}

/// WebSocket event
class WaiterWebSocketEvent {
  final WaiterEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WaiterWebSocketEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WaiterWebSocketEvent.fromJson(Map<String, dynamic> json) {
    return WaiterWebSocketEvent(
      type: _parseEventType(json['type'] as String),
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static WaiterEventType _parseEventType(String type) {
    switch (type) {
      case 'table.status_changed':
        return WaiterEventType.tableStatusChanged;
      case 'order.created':
        return WaiterEventType.orderCreated;
      case 'order.updated':
        return WaiterEventType.orderUpdated;
      case 'order.status_changed':
        return WaiterEventType.orderStatusChanged;
      case 'order.cancelled':
        return WaiterEventType.orderCancelled;
      case 'session.closed':
        return WaiterEventType.sessionClosed;
      case 'ping':
        return WaiterEventType.ping;
      default:
        throw Exception('Unknown event type: $type');
    }
  }
}

/// Waiter Real-Time Service
/// Handles multi-device synchronization for waiter app
class WaiterRealtimeService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final String wsUrl;
  final String deviceId;
  final String? organizationId;
  final Duration reconnectDelay;
  final Duration pingInterval;

  final _statusController = StreamController<WaiterConnectionStatus>.broadcast();
  final _eventController = StreamController<WaiterWebSocketEvent>.broadcast();
  final _tableStatusController = StreamController<Map<String, dynamic>>.broadcast();
  final _orderUpdateController = StreamController<Order>.broadcast();

  Stream<WaiterConnectionStatus> get statusStream => _statusController.stream;
  Stream<WaiterWebSocketEvent> get eventStream => _eventController.stream;
  Stream<Map<String, dynamic>> get tableStatusStream => _tableStatusController.stream;
  Stream<Order> get orderUpdateStream => _orderUpdateController.stream;

  WaiterConnectionStatus _currentStatus = WaiterConnectionStatus.disconnected;
  WaiterConnectionStatus get currentStatus => _currentStatus;

  int _reconnectAttempts = 0;
  final int maxReconnectAttempts = 10;

  WaiterRealtimeService({
    required this.wsUrl,
    required this.deviceId,
    this.organizationId,
    this.reconnectDelay = const Duration(seconds: 5),
    this.pingInterval = const Duration(seconds: 30),
  });

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_currentStatus == WaiterConnectionStatus.connected ||
        _currentStatus == WaiterConnectionStatus.connecting) {
      return;
    }

    _updateStatus(WaiterConnectionStatus.connecting);

    try {
      // Build WebSocket URL with query parameters
      final uri = Uri.parse(wsUrl).replace(
        queryParameters: {
          'device_id': deviceId,
          if (organizationId != null) 'org_id': organizationId!,
        },
      );

      _channel = WebSocketChannel.connect(uri);

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      _updateStatus(WaiterConnectionStatus.connected);
      _reconnectAttempts = 0;

      // Start ping timer
      _startPingTimer();

      // Subscribe to POS updates
      _subscribeToPosUpdates();
    } catch (e) {
      _updateStatus(WaiterConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();

    await _channel?.sink.close();
    _channel = null;

    _updateStatus(WaiterConnectionStatus.disconnected);
  }

  /// Send message to server
  void send(Map<String, dynamic> message) {
    if (_currentStatus != WaiterConnectionStatus.connected) {
      throw Exception('WebSocket not connected');
    }

    _channel?.sink.add(jsonEncode(message));
  }

  /// Subscribe to POS updates (Odoo pattern)
  void _subscribeToPosUpdates() {
    send({
      'type': 'subscribe',
      'channel': 'pos_updates',
      'device_id': deviceId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle incoming message
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = WaiterWebSocketEvent.fromJson(data);

      _eventController.add(event);

      // Handle specific event types
      switch (event.type) {
        case WaiterEventType.tableStatusChanged:
          _tableStatusController.add(event.data);
          break;

        case WaiterEventType.orderCreated:
        case WaiterEventType.orderUpdated:
        case WaiterEventType.orderStatusChanged:
          // Convert to Order object if structure matches
          try {
            final order = Order.fromJson(event.data);
            _orderUpdateController.add(order);
          } catch (e) {
            // Invalid order format, skip
          }
          break;

        case WaiterEventType.orderCancelled:
          try {
            final order = Order.fromJson(event.data);
            _orderUpdateController.add(order);
          } catch (e) {
            // Invalid order format, skip
          }
          break;

        case WaiterEventType.sessionClosed:
          // Handle session closed - notify user and redirect
          break;

        case WaiterEventType.ping:
          // Respond to ping
          _sendPong();
          break;
      }
    } catch (e) {
      // Invalid message format, ignore
    }
  }

  /// Handle WebSocket error
  void _handleError(dynamic error) {
    _updateStatus(WaiterConnectionStatus.error);
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnect
  void _handleDisconnect() {
    _updateStatus(WaiterConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _updateStatus(WaiterConnectionStatus.error);
      return;
    }

    _reconnectTimer?.cancel();

    final delay = reconnectDelay * (_reconnectAttempts + 1);
    _updateStatus(WaiterConnectionStatus.reconnecting);

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  /// Start ping timer to keep connection alive
  void _startPingTimer() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(pingInterval, (_) {
      if (_currentStatus == WaiterConnectionStatus.connected) {
        _sendPing();
      }
    });
  }

  /// Send ping message
  void _sendPing() {
    try {
      send({
        'type': 'ping',
        'device_id': deviceId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Connection lost
      _handleDisconnect();
    }
  }

  /// Send pong response
  void _sendPong() {
    try {
      send({
        'type': 'pong',
        'device_id': deviceId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Connection lost
    }
  }

  /// Update table status
  void updateTableStatus(String tableId, String status) {
    try {
      send({
        'type': 'table.update_status',
        'device_id': deviceId,
        'data': {
          'table_id': tableId,
          'status': status,
          'updated_at': DateTime.now().toIso8601String(),
        },
      });
    } catch (e) {
      // Failed to send
    }
  }

  /// Notify order created
  void notifyOrderCreated(Order order) {
    try {
      send({
        'type': 'order.created',
        'device_id': deviceId,
        'data': order.toJson(),
      });
    } catch (e) {
      // Failed to send
    }
  }

  /// Update connection status
  void _updateStatus(WaiterConnectionStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    await _statusController.close();
    await _eventController.close();
    await _tableStatusController.close();
    await _orderUpdateController.close();
  }
}

/// Waiter realtime service provider
final waiterRealtimeServiceProvider = Provider<WaiterRealtimeService>((ref) {
  final config = ref.watch(waiterConfigProvider);

  // TODO: Get actual device ID from platform/settings
  const deviceId = 'WAITER-001';

  // TODO: Get organization ID from auth/session
  const organizationId = 'org-uuid';

  final service = WaiterRealtimeService(
    wsUrl: config.posWebSocketUrl,
    deviceId: deviceId,
    organizationId: organizationId,
    reconnectDelay: config.reconnectDelay,
    pingInterval: config.pingInterval,
  );

  // Dispose when provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
});

/// Connection status provider
final waiterConnectionStatusProvider = StreamProvider<WaiterConnectionStatus>((ref) {
  final service = ref.watch(waiterRealtimeServiceProvider);
  return service.statusStream;
});

/// Table status updates provider
final waiterTableStatusUpdatesProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final service = ref.watch(waiterRealtimeServiceProvider);
  return service.tableStatusStream;
});

/// Order updates provider
final waiterOrderUpdatesProvider = StreamProvider<Order>((ref) {
  final service = ref.watch(waiterRealtimeServiceProvider);
  return service.orderUpdateStream;
});
