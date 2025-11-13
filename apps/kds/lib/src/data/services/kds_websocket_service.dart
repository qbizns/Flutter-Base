/// KDS WebSocket Service
/// Real-time order updates following Odoo KDS patterns
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/kitchen_order.dart';

/// WebSocket connection status
enum WebSocketStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// WebSocket event types (Odoo-style)
enum KdsEventType {
  orderCreated,
  orderUpdated,
  orderStatusChanged,
  orderCancelled,
  itemCompleted,
  ping,
}

/// WebSocket event
class KdsWebSocketEvent {
  final KdsEventType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  KdsWebSocketEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory KdsWebSocketEvent.fromJson(Map<String, dynamic> json) {
    return KdsWebSocketEvent(
      type: _parseEventType(json['type'] as String),
      data: json['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  static KdsEventType _parseEventType(String type) {
    switch (type) {
      case 'order_created':
        return KdsEventType.orderCreated;
      case 'order_updated':
        return KdsEventType.orderUpdated;
      case 'order_status_changed':
        return KdsEventType.orderStatusChanged;
      case 'order_cancelled':
        return KdsEventType.orderCancelled;
      case 'item_completed':
        return KdsEventType.itemCompleted;
      case 'ping':
        return KdsEventType.ping;
      default:
        throw Exception('Unknown event type: $type');
    }
  }
}

/// KDS WebSocket Service
/// Handles real-time communication with backend following Odoo patterns
class KdsWebSocketService {
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  final String wsUrl;
  final Duration reconnectDelay;
  final Duration pingInterval;

  final _statusController = StreamController<WebSocketStatus>.broadcast();
  final _eventController = StreamController<KdsWebSocketEvent>.broadcast();
  final _orderController = StreamController<KitchenOrder>.broadcast();

  Stream<WebSocketStatus> get statusStream => _statusController.stream;
  Stream<KdsWebSocketEvent> get eventStream => _eventController.stream;
  Stream<KitchenOrder> get orderStream => _orderController.stream;

  WebSocketStatus _currentStatus = WebSocketStatus.disconnected;
  WebSocketStatus get currentStatus => _currentStatus;

  int _reconnectAttempts = 0;
  final int maxReconnectAttempts = 10;

  KdsWebSocketService({
    required this.wsUrl,
    this.reconnectDelay = const Duration(seconds: 5),
    this.pingInterval = const Duration(seconds: 30),
  });

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_currentStatus == WebSocketStatus.connected ||
        _currentStatus == WebSocketStatus.connecting) {
      return;
    }

    _updateStatus(WebSocketStatus.connecting);

    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      _updateStatus(WebSocketStatus.connected);
      _reconnectAttempts = 0;

      // Start ping timer
      _startPingTimer();

      // Subscribe to KDS events
      _subscribeToKdsEvents();
    } catch (e) {
      _updateStatus(WebSocketStatus.error);
      _scheduleReconnect();
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _pingTimer?.cancel();

    await _channel?.sink.close();
    _channel = null;

    _updateStatus(WebSocketStatus.disconnected);
  }

  /// Send message to server
  void send(Map<String, dynamic> message) {
    if (_currentStatus != WebSocketStatus.connected) {
      throw Exception('WebSocket not connected');
    }

    _channel?.sink.add(jsonEncode(message));
  }

  /// Subscribe to KDS events (Odoo pattern)
  void _subscribeToKdsEvents() {
    send({
      'type': 'subscribe',
      'channel': 'kds_updates',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// Handle incoming message
  void _handleMessage(dynamic message) {
    try {
      final data = jsonDecode(message as String) as Map<String, dynamic>;
      final event = KdsWebSocketEvent.fromJson(data);

      _eventController.add(event);

      // Handle specific event types
      switch (event.type) {
        case KdsEventType.orderCreated:
        case KdsEventType.orderUpdated:
          final order = KitchenOrder.fromJson(event.data);
          _orderController.add(order);
          break;

        case KdsEventType.orderStatusChanged:
          final order = KitchenOrder.fromJson(event.data);
          _orderController.add(order);
          break;

        case KdsEventType.orderCancelled:
          final order = KitchenOrder.fromJson(event.data);
          _orderController.add(order);
          break;

        case KdsEventType.itemCompleted:
          final order = KitchenOrder.fromJson(event.data);
          _orderController.add(order);
          break;

        case KdsEventType.ping:
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
    _updateStatus(WebSocketStatus.error);
    _scheduleReconnect();
  }

  /// Handle WebSocket disconnect
  void _handleDisconnect() {
    _updateStatus(WebSocketStatus.disconnected);
    _scheduleReconnect();
  }

  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    if (_reconnectAttempts >= maxReconnectAttempts) {
      _updateStatus(WebSocketStatus.error);
      return;
    }

    _reconnectTimer?.cancel();

    final delay = reconnectDelay * (_reconnectAttempts + 1);
    _updateStatus(WebSocketStatus.reconnecting);

    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect();
    });
  }

  /// Start ping timer to keep connection alive
  void _startPingTimer() {
    _pingTimer?.cancel();

    _pingTimer = Timer.periodic(pingInterval, (_) {
      if (_currentStatus == WebSocketStatus.connected) {
        _sendPing();
      }
    });
  }

  /// Send ping message
  void _sendPing() {
    try {
      send({
        'type': 'ping',
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
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Connection lost
    }
  }

  /// Update connection status
  void _updateStatus(WebSocketStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await disconnect();
    await _statusController.close();
    await _eventController.close();
    await _orderController.close();
  }
}

/// WebSocket service provider
final kdsWebSocketServiceProvider = Provider<KdsWebSocketService>((ref) {
  // Get WebSocket URL from config
  final config = ref.watch(configProvider);

  // Build WebSocket URL from API base URL
  String wsUrl = 'ws://localhost:8080/kds/ws'; // Default fallback

  if (config.apiBaseUrl.isNotEmpty) {
    // Convert HTTP/HTTPS to WS/WSS
    final baseUrl = config.apiBaseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
    wsUrl = '$baseUrl/kds/ws';
  }

  final service = KdsWebSocketService(wsUrl: wsUrl);

  // Dispose when provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
});

/// WebSocket status provider
final kdsWebSocketStatusProvider = StreamProvider<WebSocketStatus>((ref) {
  final service = ref.watch(kdsWebSocketServiceProvider);
  return service.statusStream;
});

/// Order updates stream provider
final kdsOrderUpdatesProvider = StreamProvider<KitchenOrder>((ref) {
  final service = ref.watch(kdsWebSocketServiceProvider);
  return service.orderStream;
});

/// Mock WebSocket Service for development
/// Simulates real-time order updates without backend
class MockKdsWebSocketService extends KdsWebSocketService {
  Timer? _mockOrderTimer;
  int _mockOrderCounter = 100;

  MockKdsWebSocketService({required super.wsUrl});

  @override
  Future<void> connect() async {
    _updateStatus(WebSocketStatus.connecting);

    // Simulate connection delay
    await Future.delayed(const Duration(seconds: 1));

    _updateStatus(WebSocketStatus.connected);

    // Start generating mock orders
    _startMockOrders();
  }

  void _startMockOrders() {
    // Generate new order every 30 seconds
    _mockOrderTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _generateMockOrder();
    });

    // Also generate some random status updates
    Timer.periodic(const Duration(seconds: 15), (_) {
      _generateMockStatusUpdate();
    });
  }

  void _generateMockOrder() {
    final now = DateTime.now();
    final orderNumber = 'ORD-${_mockOrderCounter++}';

    final order = KitchenOrder(
      id: _mockOrderCounter.toString(),
      orderNumber: orderNumber,
      createdAt: now,
      status: KitchenOrderStatus.newOrder,
      items: [
        const KitchenOrderItem(
          id: '1',
          productId: 'burger-1',
          productName: 'Classic Burger',
          categoryId: 'burgers',
          categoryName: 'Burgers',
          quantity: 1,
          basePrice: 12.99,
        ),
      ],
      tableNumber: '${(_mockOrderCounter % 20) + 1}',
      tableName: 'Table ${(_mockOrderCounter % 20) + 1}',
      stationIds: ['grill'],
    );

    _orderController.add(order);

    _eventController.add(KdsWebSocketEvent(
      type: KdsEventType.orderCreated,
      data: order.toJson(),
    ));
  }

  void _generateMockStatusUpdate() {
    // Simulate random status update for testing
    // In real implementation, this would come from WebSocket
  }

  @override
  Future<void> dispose() async {
    _mockOrderTimer?.cancel();
    await super.dispose();
  }
}

/// Mock WebSocket service provider for development
final mockKdsWebSocketServiceProvider = Provider<MockKdsWebSocketService>((ref) {
  final service = MockKdsWebSocketService(
    wsUrl: 'ws://mock',
  );

  // Auto-connect in development
  service.connect();

  ref.onDispose(() => service.dispose());

  return service;
});
