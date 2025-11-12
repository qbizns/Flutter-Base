/// Waiter WebSocket Service
/// Real-time updates for tables and orders
/// Following patterns from KDS and Customer Display WebSocket services
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/waiter_models.dart';

/// WebSocket event types
enum WaiterEventType {
  tableUpdated,
  tableStatusChanged,
  orderCreated,
  orderUpdated,
  orderStatusChanged,
  orderItemAdded,
  orderItemRemoved,
  orderSentToKitchen,
  tableAssigned,
  tableTransferred,
  guestCountChanged,
  ping,
  pong,
  error;

  static WaiterEventType? fromString(String value) {
    try {
      return WaiterEventType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => WaiterEventType.error,
      );
    } catch (e) {
      return null;
    }
  }
}

/// WebSocket event
class WaiterEvent {
  final WaiterEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  WaiterEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory WaiterEvent.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type'] as String;
    final type = WaiterEventType.fromString(typeStr) ?? WaiterEventType.error;

    return WaiterEvent(
      type: type,
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Connection status
enum WaiterConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error;
}

/// Waiter WebSocket Service
/// Manages real-time connection to backend for table/order updates
class WaiterWebSocketService {
  final String baseUrl;
  final String waiterId;

  WebSocketChannel? _channel;
  StreamController<WaiterEvent>? _eventController;
  StreamController<WaiterConnectionStatus>? _statusController;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;

  WaiterConnectionStatus _status = WaiterConnectionStatus.disconnected;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  static const Duration _reconnectDelay = Duration(seconds: 5);
  static const Duration _heartbeatInterval = Duration(seconds: 30);

  WaiterWebSocketService({
    required this.baseUrl,
    required this.waiterId,
  }) {
    _eventController = StreamController<WaiterEvent>.broadcast();
    _statusController = StreamController<WaiterConnectionStatus>.broadcast();
  }

  /// Stream of WebSocket events
  Stream<WaiterEvent> get eventStream => _eventController!.stream;

  /// Stream of connection status changes
  Stream<WaiterConnectionStatus> get statusStream => _statusController!.stream;

  /// Current connection status
  WaiterConnectionStatus get status => _status;

  /// Check if connected
  bool get isConnected => _status == WaiterConnectionStatus.connected;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_status == WaiterConnectionStatus.connected ||
        _status == WaiterConnectionStatus.connecting) {
      debugPrint('[WaiterWebSocket] Already connected or connecting');
      return;
    }

    try {
      _updateStatus(WaiterConnectionStatus.connecting);
      debugPrint('[WaiterWebSocket] Connecting to $baseUrl for waiter $waiterId...');

      // Build WebSocket URL
      final uri = Uri.parse(baseUrl.replaceFirst('http', 'ws'));
      final wsUrl = uri.replace(
        path: '${uri.path}/waiter/$waiterId',
      );

      debugPrint('[WaiterWebSocket] WebSocket URL: $wsUrl');

      _channel = WebSocketChannel.connect(wsUrl);

      // Wait for connection to be established
      await _channel!.ready;

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
        cancelOnError: false,
      );

      _updateStatus(WaiterConnectionStatus.connected);
      _reconnectAttempts = 0;

      debugPrint('[WaiterWebSocket] Connected successfully');

      // Start heartbeat
      _startHeartbeat();

      // Send handshake
      _sendHandshake();
    } catch (e) {
      debugPrint('[WaiterWebSocket] Connection failed: $e');
      _updateStatus(WaiterConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    debugPrint('[WaiterWebSocket] Disconnecting...');

    _heartbeatTimer?.cancel();
    _reconnectTimer?.cancel();
    _heartbeatTimer = null;
    _reconnectTimer = null;

    await _channel?.sink.close();
    _channel = null;

    _updateStatus(WaiterConnectionStatus.disconnected);
  }

  /// Send handshake message
  void _sendHandshake() {
    final message = {
      'type': 'handshake',
      'data': {
        'waiterId': waiterId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    };

    _sendMessage(message);
  }

  /// Send message to server
  void _sendMessage(Map<String, dynamic> message) {
    if (_channel == null || !isConnected) {
      debugPrint('[WaiterWebSocket] Cannot send message: not connected');
      return;
    }

    try {
      final json = jsonEncode(message);
      _channel!.sink.add(json);
    } catch (e) {
      debugPrint('[WaiterWebSocket] Failed to send message: $e');
    }
  }

  /// Handle incoming message
  void _handleMessage(dynamic message) {
    try {
      final json = jsonDecode(message as String) as Map<String, dynamic>;
      final event = WaiterEvent.fromJson(json);

      debugPrint('[WaiterWebSocket] Received event: ${event.type.name}');

      // Handle special events
      if (event.type == WaiterEventType.ping) {
        _sendPong();
        return;
      }

      // Emit event to listeners
      _eventController?.add(event);
    } catch (e) {
      debugPrint('[WaiterWebSocket] Failed to parse message: $e');
    }
  }

  /// Handle connection error
  void _handleError(dynamic error) {
    debugPrint('[WaiterWebSocket] Error: $error');
    _updateStatus(WaiterConnectionStatus.error);
    _scheduleReconnect();
  }

  /// Handle disconnection
  void _handleDisconnection() {
    debugPrint('[WaiterWebSocket] Disconnected');
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _updateStatus(WaiterConnectionStatus.disconnected);
    _scheduleReconnect();
  }

  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (timer) {
      if (isConnected) {
        _sendPing();
      } else {
        timer.cancel();
      }
    });
  }

  /// Send ping to keep connection alive
  void _sendPing() {
    final message = {
      'type': 'ping',
      'data': {
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
    _sendMessage(message);
  }

  /// Send pong response
  void _sendPong() {
    final message = {
      'type': 'pong',
      'data': {
        'timestamp': DateTime.now().toIso8601String(),
      },
    };
    _sendMessage(message);
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[WaiterWebSocket] Max reconnect attempts reached');
      _updateStatus(WaiterConnectionStatus.error);
      return;
    }

    if (_reconnectTimer?.isActive ?? false) {
      return;
    }

    _reconnectAttempts++;
    _updateStatus(WaiterConnectionStatus.reconnecting);

    debugPrint(
      '[WaiterWebSocket] Scheduling reconnect attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds}s',
    );

    _reconnectTimer = Timer(_reconnectDelay, () {
      _reconnectTimer = null;
      connect();
    });
  }

  /// Update connection status
  void _updateStatus(WaiterConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController?.add(newStatus);
      debugPrint('[WaiterWebSocket] Status changed to: ${newStatus.name}');
    }
  }

  /// Subscribe to table updates
  void subscribeToTable(String tableId) {
    final message = {
      'type': 'subscribe_table',
      'data': {
        'tableId': tableId,
      },
    };
    _sendMessage(message);
  }

  /// Unsubscribe from table updates
  void unsubscribeFromTable(String tableId) {
    final message = {
      'type': 'unsubscribe_table',
      'data': {
        'tableId': tableId,
      },
    };
    _sendMessage(message);
  }

  /// Subscribe to order updates
  void subscribeToOrder(String orderId) {
    final message = {
      'type': 'subscribe_order',
      'data': {
        'orderId': orderId,
      },
    };
    _sendMessage(message);
  }

  /// Unsubscribe from order updates
  void unsubscribeFromOrder(String orderId) {
    final message = {
      'type': 'unsubscribe_order',
      'data': {
        'orderId': orderId,
      },
    };
    _sendMessage(message);
  }

  /// Dispose resources
  Future<void> dispose() async {
    debugPrint('[WaiterWebSocket] Disposing...');
    await disconnect();
    await _eventController?.close();
    await _statusController?.close();
    _eventController = null;
    _statusController = null;
  }
}

/// Helper extensions for parsing events
extension WaiterEventExtensions on WaiterEvent {
  /// Parse table from event data
  RestaurantTable? get table {
    try {
      if (data['table'] != null) {
        return RestaurantTable.fromJson(data['table'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[WaiterEvent] Failed to parse table: $e');
    }
    return null;
  }

  /// Parse order from event data
  TableOrder? get order {
    try {
      if (data['order'] != null) {
        return TableOrder.fromJson(data['order'] as Map<String, dynamic>);
      }
    } catch (e) {
      debugPrint('[WaiterEvent] Failed to parse order: $e');
    }
    return null;
  }

  /// Get table ID from event
  String? get tableId => data['tableId'] as String?;

  /// Get order ID from event
  String? get orderId => data['orderId'] as String?;

  /// Get table status from event
  TableStatus? get tableStatus {
    try {
      final statusStr = data['status'] as String?;
      if (statusStr != null) {
        return TableStatus.values.firstWhere(
          (s) => s.name == statusStr,
        );
      }
    } catch (e) {
      debugPrint('[WaiterEvent] Failed to parse table status: $e');
    }
    return null;
  }

  /// Get order status from event
  TableOrderStatus? get orderStatus {
    try {
      final statusStr = data['status'] as String?;
      if (statusStr != null) {
        return TableOrderStatus.values.firstWhere(
          (s) => s.name == statusStr,
        );
      }
    } catch (e) {
      debugPrint('[WaiterEvent] Failed to parse order status: $e');
    }
    return null;
  }
}
