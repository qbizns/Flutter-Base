/// Customer Display Integration Service
/// Sends real-time updates from POS register to customer display
/// Following Odoo POS customer display patterns
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/order.dart';

/// Customer Display Integration Service Provider
final customerDisplayIntegrationServiceProvider =
    Provider<CustomerDisplayIntegrationService>((ref) {
  final service = CustomerDisplayIntegrationService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Customer Display Enabled Provider
final customerDisplayEnabledProvider = StateProvider<bool>((ref) => false);

/// Connected Displays Provider
final connectedDisplaysProvider = StateProvider<List<ConnectedDisplay>>((ref) => []);

/// Customer Display Integration Service
/// Manages communication with customer-facing displays
class CustomerDisplayIntegrationService {
  final Map<String, WebSocketChannel> _displayChannels = {};
  final Map<String, Timer> _heartbeatTimers = {};
  bool _isDisposed = false;
  bool _enabled = false;

  /// Enable customer display integration
  void enable() {
    _enabled = true;
    debugPrint('[Customer Display] Integration enabled');
  }

  /// Disable customer display integration
  void disable() {
    _enabled = false;
    _disconnectAllDisplays();
    debugPrint('[Customer Display] Integration disabled');
  }

  /// Check if enabled
  bool get isEnabled => _enabled;

  /// Register a display connection
  void registerDisplay(String displayId, WebSocketChannel channel) {
    if (_isDisposed) return;

    _displayChannels[displayId] = channel;
    _startHeartbeat(displayId);

    debugPrint('[Customer Display] Display registered: $displayId');

    // Listen for messages from display
    channel.stream.listen(
      (data) => _handleDisplayMessage(displayId, data),
      onError: (error) {
        debugPrint('[Customer Display] Error from $displayId: $error');
        _unregisterDisplay(displayId);
      },
      onDone: () {
        debugPrint('[Customer Display] Display disconnected: $displayId');
        _unregisterDisplay(displayId);
      },
    );
  }

  /// Unregister a display
  void _unregisterDisplay(String displayId) {
    _heartbeatTimers[displayId]?.cancel();
    _heartbeatTimers.remove(displayId);
    _displayChannels[displayId]?.sink.close();
    _displayChannels.remove(displayId);
    debugPrint('[Customer Display] Display unregistered: $displayId');
  }

  /// Send event to all displays
  void _sendToAllDisplays(String type, Map<String, dynamic> payload) {
    if (!_enabled || _isDisposed) return;

    final message = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
      'payload': payload,
    };

    final jsonString = jsonEncode(message);

    for (final entry in _displayChannels.entries) {
      try {
        entry.value.sink.add(jsonString);
        debugPrint('[Customer Display] Sent $type to ${entry.key}');
      } catch (error) {
        debugPrint(
            '[Customer Display] Failed to send to ${entry.key}: $error');
      }
    }
  }

  /// Send cart update
  void sendCartUpdate(Cart cart) {
    if (!_enabled) return;

    final cartData = {
      'id': cart.id,
      'items': cart.items.map((item) => _cartItemToJson(item)).toList(),
      'subtotal': cart.subtotal,
      'tax': cart.tax,
      'discount': cart.discount,
      'total': cart.total,
      'customerName': cart.customerName,
      'createdAt': DateTime.now().toIso8601String(),
      'lastScannedItemId': cart.items.isNotEmpty ? cart.items.last.id : null,
    };

    _sendToAllDisplays('cart_updated', {'cart': cartData});
  }

  /// Send item added event
  void sendItemAdded(CartItem item) {
    if (!_enabled) return;

    _sendToAllDisplays('item_added', {
      'item': _cartItemToJson(item, isLastScanned: true),
    });
  }

  /// Send item removed event
  void sendItemRemoved(String itemId) {
    if (!_enabled) return;

    _sendToAllDisplays('item_removed', {'itemId': itemId});
  }

  /// Send item quantity changed event
  void sendItemQuantityChanged(String itemId, int newQuantity) {
    if (!_enabled) return;

    _sendToAllDisplays('item_quantity_changed', {
      'itemId': itemId,
      'newQuantity': newQuantity,
    });
  }

  /// Send cart cleared event
  void sendCartCleared() {
    if (!_enabled) return;

    _sendToAllDisplays('cart_cleared', {});
  }

  /// Send payment started event
  void sendPaymentStarted(String method, double amount) {
    if (!_enabled) return;

    _sendToAllDisplays('payment_started', {
      'method': method,
      'amount': amount,
    });
  }

  /// Send payment updated event
  void sendPaymentUpdated(
    String status, {
    String? errorMessage,
    String? transactionId,
  }) {
    if (!_enabled) return;

    _sendToAllDisplays('payment_updated', {
      'status': status,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (transactionId != null) 'transactionId': transactionId,
    });
  }

  /// Send order completed event
  void sendOrderCompleted(Order order) {
    if (!_enabled) return;

    final orderData = {
      'id': order.id,
      'orderNumber': order.orderNumber,
      'total': order.total,
      'totalItems': order.items.length,
      'completedAt': DateTime.now().toIso8601String(),
      'customerName': order.customerName,
    };

    _sendToAllDisplays('order_completed', {'order': orderData});
  }

  /// Send display to idle
  void sendDisplayIdle() {
    if (!_enabled) return;

    _sendToAllDisplays('display_idle', {});
  }

  /// Send marketing content update
  void sendMarketingContent({
    required String type,
    String? title,
    String? subtitle,
    String? imageUrl,
    List<String>? bulletPoints,
  }) {
    if (!_enabled) return;

    _sendToAllDisplays('marketing_content_updated', {
      'content': {
        'id': 'content_${DateTime.now().millisecondsSinceEpoch}',
        'type': type,
        if (title != null) 'title': title,
        if (subtitle != null) 'subtitle': subtitle,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (bulletPoints != null) 'bulletPoints': bulletPoints,
      }
    });
  }

  // Private methods

  Map<String, dynamic> _cartItemToJson(CartItem item,
      {bool isLastScanned = false}) {
    return {
      'id': item.id,
      'productId': item.product.id,
      'productName': item.product.name,
      'quantity': item.quantity,
      'unitPrice': item.product.price,
      'lineTotal': item.lineTotal,
      'imageUrl': item.product.imageUrl,
      'categoryName': item.product.category?.name,
      'modifiers': item.modifiers?.map((m) => m.name).toList() ?? [],
      'discount': item.discount,
      'isLastScanned': isLastScanned,
      'scannedAt': DateTime.now().toIso8601String(),
    };
  }

  void _handleDisplayMessage(String displayId, dynamic data) {
    try {
      final jsonData = jsonDecode(data as String) as Map<String, dynamic>;
      final type = jsonData['type'] as String;

      debugPrint('[Customer Display] Received $type from $displayId');

      // Handle messages from display (if needed)
      switch (type) {
        case 'handshake':
          _sendHandshakeResponse(displayId);
          break;
        case 'heartbeat':
          _sendHeartbeatResponse(displayId);
          break;
        default:
          debugPrint('[Customer Display] Unknown message type: $type');
      }
    } catch (error) {
      debugPrint('[Customer Display] Failed to handle message: $error');
    }
  }

  void _sendHandshakeResponse(String displayId) {
    final channel = _displayChannels[displayId];
    if (channel == null) return;

    final response = jsonEncode({
      'id': 'handshake_response_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'handshake_response',
      'timestamp': DateTime.now().toIso8601String(),
      'payload': {
        'acknowledged': true,
        'serverVersion': '1.0.0',
      },
    });

    channel.sink.add(response);
  }

  void _sendHeartbeatResponse(String displayId) {
    final channel = _displayChannels[displayId];
    if (channel == null) return;

    final response = jsonEncode({
      'id': 'heartbeat_response_${DateTime.now().millisecondsSinceEpoch}',
      'type': 'heartbeat_response',
      'timestamp': DateTime.now().toIso8601String(),
      'payload': {},
    });

    channel.sink.add(response);
  }

  void _startHeartbeat(String displayId) {
    _heartbeatTimers[displayId] = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (_displayChannels.containsKey(displayId)) {
          // Check if display is still alive via heartbeat
          debugPrint('[Customer Display] Checking heartbeat for $displayId');
        }
      },
    );
  }

  void _disconnectAllDisplays() {
    for (final displayId in _displayChannels.keys.toList()) {
      _unregisterDisplay(displayId);
    }
  }

  /// Get count of connected displays
  int get connectedDisplayCount => _displayChannels.length;

  /// Get list of connected display IDs
  List<String> get connectedDisplayIds => _displayChannels.keys.toList();

  /// Dispose resources
  void dispose() {
    _isDisposed = true;
    _disconnectAllDisplays();
  }
}

/// Connected Display Model
class ConnectedDisplay {
  final String displayId;
  final String displayName;
  final DateTime connectedAt;

  ConnectedDisplay({
    required this.displayId,
    required this.displayName,
    required this.connectedAt,
  });
}
