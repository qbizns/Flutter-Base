/// Display WebSocket Protocol
/// Protocol for real-time communication between POS register and customer display
/// Following Odoo POS customer display patterns
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../models/customer_display_models.dart';

part 'display_protocol.freezed.dart';
part 'display_protocol.g.dart';

/// Display Message
/// Base message type for POS-Display communication
@freezed
class DisplayMessage with _$DisplayMessage {
  const DisplayMessage._();

  const factory DisplayMessage({
    required String id,
    required String type,
    required DateTime timestamp,
    required Map<String, dynamic> payload,
    String? sessionId,
  }) = _DisplayMessage;

  factory DisplayMessage.fromJson(Map<String, dynamic> json) =>
      _$DisplayMessageFromJson(json);

  /// Create message from event
  factory DisplayMessage.fromEvent(DisplayEvent event) {
    return DisplayMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      type: event.type,
      timestamp: DateTime.now(),
      payload: event.toPayload(),
    );
  }
}

/// Display Event
/// Events sent from POS to customer display
abstract class DisplayEvent {
  String get type;
  Map<String, dynamic> toPayload();

  factory DisplayEvent.fromPayload(String type, Map<String, dynamic> payload) {
    switch (type) {
      case 'cart_updated':
        return CartUpdatedEvent.fromPayload(payload);
      case 'item_added':
        return ItemAddedEvent.fromPayload(payload);
      case 'item_removed':
        return ItemRemovedEvent.fromPayload(payload);
      case 'item_quantity_changed':
        return ItemQuantityChangedEvent.fromPayload(payload);
      case 'cart_cleared':
        return CartClearedEvent.fromPayload(payload);
      case 'payment_started':
        return PaymentStartedEvent.fromPayload(payload);
      case 'payment_updated':
        return PaymentUpdatedEvent.fromPayload(payload);
      case 'order_completed':
        return OrderCompletedEvent.fromPayload(payload);
      case 'display_idle':
        return DisplayIdleEvent.fromPayload(payload);
      case 'marketing_content_updated':
        return MarketingContentUpdatedEvent.fromPayload(payload);
      default:
        throw UnimplementedError('Unknown event type: $type');
    }
  }
}

/// Cart Updated Event
/// Sent when entire cart is updated
class CartUpdatedEvent implements DisplayEvent {
  final CustomerCart cart;

  CartUpdatedEvent(this.cart);

  @override
  String get type => 'cart_updated';

  @override
  Map<String, dynamic> toPayload() {
    return {'cart': cart.toJson()};
  }

  factory CartUpdatedEvent.fromPayload(Map<String, dynamic> payload) {
    return CartUpdatedEvent(
      CustomerCart.fromJson(payload['cart'] as Map<String, dynamic>),
    );
  }
}

/// Item Added Event
/// Sent when item is added to cart
class ItemAddedEvent implements DisplayEvent {
  final CustomerCartItem item;

  ItemAddedEvent(this.item);

  @override
  String get type => 'item_added';

  @override
  Map<String, dynamic> toPayload() {
    return {'item': item.toJson()};
  }

  factory ItemAddedEvent.fromPayload(Map<String, dynamic> payload) {
    return ItemAddedEvent(
      CustomerCartItem.fromJson(payload['item'] as Map<String, dynamic>),
    );
  }
}

/// Item Removed Event
/// Sent when item is removed from cart
class ItemRemovedEvent implements DisplayEvent {
  final String itemId;

  ItemRemovedEvent(this.itemId);

  @override
  String get type => 'item_removed';

  @override
  Map<String, dynamic> toPayload() {
    return {'itemId': itemId};
  }

  factory ItemRemovedEvent.fromPayload(Map<String, dynamic> payload) {
    return ItemRemovedEvent(payload['itemId'] as String);
  }
}

/// Item Quantity Changed Event
/// Sent when item quantity is updated
class ItemQuantityChangedEvent implements DisplayEvent {
  final String itemId;
  final int newQuantity;

  ItemQuantityChangedEvent(this.itemId, this.newQuantity);

  @override
  String get type => 'item_quantity_changed';

  @override
  Map<String, dynamic> toPayload() {
    return {
      'itemId': itemId,
      'newQuantity': newQuantity,
    };
  }

  factory ItemQuantityChangedEvent.fromPayload(Map<String, dynamic> payload) {
    return ItemQuantityChangedEvent(
      payload['itemId'] as String,
      payload['newQuantity'] as int,
    );
  }
}

/// Cart Cleared Event
/// Sent when cart is cleared/cancelled
class CartClearedEvent implements DisplayEvent {
  CartClearedEvent();

  @override
  String get type => 'cart_cleared';

  @override
  Map<String, dynamic> toPayload() {
    return {};
  }

  factory CartClearedEvent.fromPayload(Map<String, dynamic> payload) {
    return CartClearedEvent();
  }
}

/// Payment Started Event
/// Sent when payment process begins
class PaymentStartedEvent implements DisplayEvent {
  final PaymentMethod method;
  final double amount;

  PaymentStartedEvent(this.method, this.amount);

  @override
  String get type => 'payment_started';

  @override
  Map<String, dynamic> toPayload() {
    return {
      'method': method.name,
      'amount': amount,
    };
  }

  factory PaymentStartedEvent.fromPayload(Map<String, dynamic> payload) {
    return PaymentStartedEvent(
      PaymentMethod.values.firstWhere(
        (m) => m.name == payload['method'],
        orElse: () => PaymentMethod.cash,
      ),
      (payload['amount'] as num).toDouble(),
    );
  }
}

/// Payment Updated Event
/// Sent when payment status changes
class PaymentUpdatedEvent implements DisplayEvent {
  final PaymentStatus status;
  final String? errorMessage;
  final String? transactionId;

  PaymentUpdatedEvent(this.status, {this.errorMessage, this.transactionId});

  @override
  String get type => 'payment_updated';

  @override
  Map<String, dynamic> toPayload() {
    return {
      'status': status.name,
      if (errorMessage != null) 'errorMessage': errorMessage,
      if (transactionId != null) 'transactionId': transactionId,
    };
  }

  factory PaymentUpdatedEvent.fromPayload(Map<String, dynamic> payload) {
    return PaymentUpdatedEvent(
      PaymentStatus.values.firstWhere(
        (s) => s.name == payload['status'],
        orElse: () => PaymentStatus.pending,
      ),
      errorMessage: payload['errorMessage'] as String?,
      transactionId: payload['transactionId'] as String?,
    );
  }
}

/// Order Completed Event
/// Sent when order is completed
class OrderCompletedEvent implements DisplayEvent {
  final CompletedOrder order;

  OrderCompletedEvent(this.order);

  @override
  String get type => 'order_completed';

  @override
  Map<String, dynamic> toPayload() {
    return {'order': order.toJson()};
  }

  factory OrderCompletedEvent.fromPayload(Map<String, dynamic> payload) {
    return OrderCompletedEvent(
      CompletedOrder.fromJson(payload['order'] as Map<String, dynamic>),
    );
  }
}

/// Display Idle Event
/// Sent to return display to idle state
class DisplayIdleEvent implements DisplayEvent {
  DisplayIdleEvent();

  @override
  String get type => 'display_idle';

  @override
  Map<String, dynamic> toPayload() {
    return {};
  }

  factory DisplayIdleEvent.fromPayload(Map<String, dynamic> payload) {
    return DisplayIdleEvent();
  }
}

/// Marketing Content Updated Event
/// Sent to update idle screen marketing content
class MarketingContentUpdatedEvent implements DisplayEvent {
  final MarketingContent content;

  MarketingContentUpdatedEvent(this.content);

  @override
  String get type => 'marketing_content_updated';

  @override
  Map<String, dynamic> toPayload() {
    return {'content': content.toJson()};
  }

  factory MarketingContentUpdatedEvent.fromPayload(
      Map<String, dynamic> payload) {
    return MarketingContentUpdatedEvent(
      MarketingContent.fromJson(payload['content'] as Map<String, dynamic>),
    );
  }
}

/// Connection State
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error;

  String get displayName {
    switch (this) {
      case ConnectionState.disconnected:
        return 'Disconnected';
      case ConnectionState.connecting:
        return 'Connecting...';
      case ConnectionState.connected:
        return 'Connected';
      case ConnectionState.reconnecting:
        return 'Reconnecting...';
      case ConnectionState.error:
        return 'Connection Error';
    }
  }

  bool get isConnected => this == ConnectionState.connected;
  bool get isConnecting =>
      this == ConnectionState.connecting ||
      this == ConnectionState.reconnecting;
  bool get hasError =>
      this == ConnectionState.error || this == ConnectionState.disconnected;
}

/// Display Configuration
@freezed
class DisplayConfiguration with _$DisplayConfiguration {
  const factory DisplayConfiguration({
    required String displayId,
    required String displayName,
    @Default('localhost') String serverHost,
    @Default(8080) int serverPort,
    @Default(true) bool autoReconnect,
    @Default(5) int reconnectDelaySeconds,
    @Default(3) int maxReconnectAttempts,
    @Default(30) int heartbeatIntervalSeconds,
    @Default(true) bool enableIdleTimeout,
    @Default(30) int idleTimeoutSeconds,
  }) = _DisplayConfiguration;

  factory DisplayConfiguration.fromJson(Map<String, dynamic> json) =>
      _$DisplayConfigurationFromJson(json);

  /// Get WebSocket URL
  factory DisplayConfiguration.defaults() {
    return DisplayConfiguration(
      displayId: 'display_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Customer Display',
    );
  }
}
