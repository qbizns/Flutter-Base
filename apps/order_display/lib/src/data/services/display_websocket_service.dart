/// Display WebSocket Service
/// Handles real-time WebSocket communication with POS register
/// Following Odoo POS customer display patterns
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../protocol/display_protocol.dart';
import 'customer_display_service.dart';

/// Display WebSocket Service Provider
final displayWebSocketServiceProvider =
    Provider<DisplayWebSocketService>((ref) {
  final service = DisplayWebSocketService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});

/// Connection State Provider
final displayConnectionStateProvider =
    StateProvider<ConnectionState>((ref) => ConnectionState.disconnected);

/// Display WebSocket Service
/// Manages WebSocket connection and message handling
class DisplayWebSocketService {
  final Ref _ref;
  WebSocketChannel? _channel;
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  DisplayConfiguration? _config;
  bool _isDisposed = false;

  DisplayWebSocketService(this._ref);

  /// Current connection state
  ConnectionState get connectionState =>
      _ref.read(displayConnectionStateProvider);

  /// Check if connected
  bool get isConnected => connectionState.isConnected;

  /// Connect to POS register
  Future<void> connect(DisplayConfiguration config) async {
    if (_isDisposed) return;

    _config = config;
    _updateConnectionState(ConnectionState.connecting);
    debugPrint(
        'Connecting to POS register at ${config.serverHost}:${config.serverPort}');

    try {
      // Build WebSocket URL
      final wsUrl =
          'ws://${config.serverHost}:${config.serverPort}/customer-display/${config.displayId}';

      // Create WebSocket channel
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      // Listen to messages
      _channel!.stream.listen(
        _handleMessage,
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _handleConnectionError(error);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _handleConnectionClosed();
        },
      );

      // Send initial handshake
      _sendHandshake();

      // Start heartbeat
      _startHeartbeat();

      // Update state
      _updateConnectionState(ConnectionState.connected);
      _reconnectAttempts = 0;

      debugPrint('Connected to POS register successfully');
    } catch (error) {
      debugPrint('Failed to connect: $error');
      _handleConnectionError(error);
    }
  }

  /// Disconnect from POS register
  void disconnect() {
    debugPrint('Disconnecting from POS register');
    _stopHeartbeat();
    _stopReconnectTimer();
    _channel?.sink.close();
    _channel = null;
    _updateConnectionState(ConnectionState.disconnected);
  }

  /// Send message to POS register
  void sendMessage(DisplayMessage message) {
    if (!isConnected || _channel == null) {
      debugPrint('Cannot send message: not connected');
      return;
    }

    try {
      final jsonString = jsonEncode(message.toJson());
      _channel!.sink.add(jsonString);
      debugPrint('Sent message: ${message.type}');
    } catch (error) {
      debugPrint('Failed to send message: $error');
    }
  }

  /// Send event to POS register
  void sendEvent(DisplayEvent event) {
    final message = DisplayMessage.fromEvent(event);
    sendMessage(message);
  }

  // Private methods

  void _handleMessage(dynamic data) {
    try {
      final jsonData = jsonDecode(data as String) as Map<String, dynamic>;
      final message = DisplayMessage.fromJson(jsonData);

      debugPrint('Received message: ${message.type}');

      // Handle special messages
      if (message.type == 'heartbeat_response') {
        // Heartbeat acknowledged
        return;
      }

      if (message.type == 'handshake_response') {
        debugPrint('Handshake acknowledged by POS register');
        return;
      }

      // Parse and handle display event
      final event = DisplayEvent.fromPayload(message.type, message.payload);
      _handleDisplayEvent(event);
    } catch (error) {
      debugPrint('Failed to handle message: $error');
    }
  }

  void _handleDisplayEvent(DisplayEvent event) {
    final displayService = _ref.read(customerDisplayServiceProvider);

    // Route event to appropriate handler
    if (event is CartUpdatedEvent) {
      displayService.updateCart(event.cart);
    } else if (event is ItemAddedEvent) {
      displayService.addItem(event.item);
    } else if (event is ItemRemovedEvent) {
      displayService.removeItem(event.itemId);
    } else if (event is ItemQuantityChangedEvent) {
      displayService.updateItemQuantity(event.itemId, event.newQuantity);
    } else if (event is CartClearedEvent) {
      displayService.clearCart();
    } else if (event is PaymentStartedEvent) {
      displayService.startPayment(event.method, event.amount);
    } else if (event is PaymentUpdatedEvent) {
      displayService.updatePaymentStatus(
        event.status,
        errorMessage: event.errorMessage,
        transactionId: event.transactionId,
      );
    } else if (event is OrderCompletedEvent) {
      displayService.completeOrder();
    } else if (event is DisplayIdleEvent) {
      displayService.showIdle();
    } else if (event is MarketingContentUpdatedEvent) {
      displayService.updateMarketingContent(event.content);
    }
  }

  void _handleConnectionError(dynamic error) {
    _updateConnectionState(ConnectionState.error);
    _stopHeartbeat();

    // Attempt reconnection if enabled
    if (_config?.autoReconnect == true && !_isDisposed) {
      _attemptReconnect();
    }
  }

  void _handleConnectionClosed() {
    _stopHeartbeat();

    if (_isDisposed) {
      _updateConnectionState(ConnectionState.disconnected);
      return;
    }

    // Attempt reconnection if enabled
    if (_config?.autoReconnect == true) {
      _updateConnectionState(ConnectionState.reconnecting);
      _attemptReconnect();
    } else {
      _updateConnectionState(ConnectionState.disconnected);
    }
  }

  void _attemptReconnect() {
    if (_config == null || _isDisposed) return;

    _reconnectAttempts++;

    if (_reconnectAttempts > (_config!.maxReconnectAttempts)) {
      debugPrint(
          'Max reconnection attempts reached (${_config!.maxReconnectAttempts})');
      _updateConnectionState(ConnectionState.error);
      _stopReconnectTimer();
      return;
    }

    debugPrint(
        'Attempting reconnection $_reconnectAttempts/${_config!.maxReconnectAttempts}...');

    _stopReconnectTimer();
    _reconnectTimer = Timer(
      Duration(seconds: _config!.reconnectDelaySeconds),
      () {
        if (!_isDisposed && _config != null) {
          connect(_config!);
        }
      },
    );
  }

  void _sendHandshake() {
    if (_config == null) return;

    final handshake = DisplayMessage(
      id: 'handshake_${DateTime.now().millisecondsSinceEpoch}',
      type: 'handshake',
      timestamp: DateTime.now(),
      payload: {
        'displayId': _config!.displayId,
        'displayName': _config!.displayName,
        'version': '1.0.0',
      },
    );

    sendMessage(handshake);
  }

  void _startHeartbeat() {
    if (_config == null) return;

    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      Duration(seconds: _config!.heartbeatIntervalSeconds),
      (_) => _sendHeartbeat(),
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  void _sendHeartbeat() {
    if (!isConnected) return;

    final heartbeat = DisplayMessage(
      id: 'heartbeat_${DateTime.now().millisecondsSinceEpoch}',
      type: 'heartbeat',
      timestamp: DateTime.now(),
      payload: {'displayId': _config?.displayId ?? ''},
    );

    sendMessage(heartbeat);
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _updateConnectionState(ConnectionState state) {
    if (!_isDisposed) {
      _ref.read(displayConnectionStateProvider.notifier).state = state;
    }
  }

  /// Dispose resources
  void dispose() {
    _isDisposed = true;
    disconnect();
  }
}

/// Mock WebSocket Service for testing
/// Simulates POS register sending events
class MockDisplayWebSocketService {
  final DisplayWebSocketService _realService;
  Timer? _mockTimer;

  MockDisplayWebSocketService(this._realService);

  /// Start mock demo
  void startMockDemo() {
    debugPrint('Starting mock WebSocket demo');

    _mockTimer?.cancel();

    // Simulate connection
    Future.delayed(const Duration(seconds: 1), () {
      debugPrint('[MOCK] Simulating POS connection');
    });

    // Simulate adding items
    Future.delayed(const Duration(seconds: 2), () {
      debugPrint('[MOCK] Adding burger to cart');
      _realService.sendEvent(ItemAddedEvent(
        const CustomerCartItem(
          id: 'item1',
          productId: 'burger1',
          productName: 'Classic Burger',
          quantity: 1,
          unitPrice: 12.99,
          lineTotal: 12.99,
          categoryName: 'Burgers',
          modifiers: ['No onions', 'Extra cheese'],
          isLastScanned: true,
        ),
      ));
    });

    Future.delayed(const Duration(seconds: 4), () {
      debugPrint('[MOCK] Adding fries to cart');
      _realService.sendEvent(ItemAddedEvent(
        const CustomerCartItem(
          id: 'item2',
          productId: 'fries1',
          productName: 'French Fries',
          quantity: 2,
          unitPrice: 3.99,
          lineTotal: 7.98,
          categoryName: 'Sides',
          isLastScanned: true,
        ),
      ));
    });

    Future.delayed(const Duration(seconds: 6), () {
      debugPrint('[MOCK] Adding drink to cart');
      _realService.sendEvent(ItemAddedEvent(
        const CustomerCartItem(
          id: 'item3',
          productId: 'drink1',
          productName: 'Cola',
          quantity: 2,
          unitPrice: 2.49,
          lineTotal: 4.98,
          categoryName: 'Drinks',
          isLastScanned: true,
        ),
      ));
    });

    Future.delayed(const Duration(seconds: 10), () {
      debugPrint('[MOCK] Starting payment');
      _realService.sendEvent(PaymentStartedEvent(
        PaymentMethod.card,
        28.84,
      ));
    });

    Future.delayed(const Duration(seconds: 13), () {
      debugPrint('[MOCK] Payment successful');
      _realService.sendEvent(PaymentUpdatedEvent(
        PaymentStatus.success,
        transactionId: 'TXN123456789',
      ));
    });
  }

  /// Stop mock demo
  void stopMockDemo() {
    _mockTimer?.cancel();
    _mockTimer = null;
  }

  /// Dispose
  void dispose() {
    stopMockDemo();
  }
}
