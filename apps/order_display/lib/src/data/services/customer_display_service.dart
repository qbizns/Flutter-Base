/// Customer Display Service
/// Manages the customer-facing POS display state
/// Following Odoo POS customer display patterns
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/customer_display_models.dart';

/// Customer Display Service Provider
final customerDisplayServiceProvider = Provider<CustomerDisplayService>((ref) {
  return CustomerDisplayService();
});

/// Current Display State Provider
final customerDisplayStateProvider =
    StateNotifierProvider<CustomerDisplayStateNotifier, CustomerDisplayState>(
  (ref) {
    final service = ref.watch(customerDisplayServiceProvider);
    return CustomerDisplayStateNotifier(service);
  },
);

/// Customer Display Service
/// Manages state and sync with POS register following Odoo patterns
class CustomerDisplayService {
  final _stateController =
      StreamController<CustomerDisplayState>.broadcast();
  CustomerDisplayState _currentState = CustomerDisplayState.idle(
    content: MarketingContent.welcome(),
  );

  Timer? _idleTimer;
  final Duration _idleTimeout = const Duration(seconds: 30);

  /// Stream of display state changes
  Stream<CustomerDisplayState> get stateStream => _stateController.stream;

  /// Get current state
  CustomerDisplayState get currentState => _currentState;

  /// Initialize service
  void initialize() {
    _startIdleTimer();
    debugPrint('Customer Display Service initialized');
  }

  /// Update cart (called when POS register adds/removes items)
  void updateCart(CustomerCart cart) {
    _currentState = CustomerDisplayState.showingCart(cart);
    _stateController.add(_currentState);
    _resetIdleTimer();
    debugPrint('Cart updated: ${cart.items.length} items, total: \$${cart.total}');
  }

  /// Add item to cart
  void addItem(CustomerCartItem item) {
    if (_currentState.currentCart == null) {
      // Create new cart
      final cart = CustomerCart(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        items: [item],
        subtotal: item.lineTotal,
        tax: item.lineTotal * 0.1, // 10% tax
        discount: 0,
        total: item.lineTotal * 1.1,
        createdAt: DateTime.now(),
        lastScannedItemId: item.id,
      );
      updateCart(cart);
    } else {
      // Update existing cart
      final currentCart = _currentState.currentCart!;

      // Check if item already exists
      final existingIndex = currentCart.items.indexWhere(
        (i) => i.productId == item.productId &&
               _modifiersMatch(i.modifiers, item.modifiers),
      );

      List<CustomerCartItem> updatedItems;
      if (existingIndex >= 0) {
        // Update quantity of existing item
        updatedItems = List.from(currentCart.items);
        final existing = updatedItems[existingIndex];
        updatedItems[existingIndex] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
          lineTotal: existing.unitPrice * (existing.quantity + item.quantity),
          isLastScanned: true,
          scannedAt: DateTime.now(),
        );
      } else {
        // Add new item
        updatedItems = [...currentCart.items, item.copyWith(
          isLastScanned: true,
          scannedAt: DateTime.now(),
        )];
      }

      // Recalculate totals
      final subtotal = updatedItems.fold(
        0.0,
        (sum, i) => sum + i.lineTotal,
      );
      final tax = subtotal * 0.1;
      final total = subtotal + tax - currentCart.discount;

      final updatedCart = currentCart.copyWith(
        items: updatedItems,
        subtotal: subtotal,
        tax: tax,
        total: total,
        lastScannedItemId: item.id,
      );

      updateCart(updatedCart);
    }
  }

  /// Remove item from cart
  void removeItem(String itemId) {
    if (_currentState.currentCart == null) return;

    final currentCart = _currentState.currentCart!;
    final updatedItems = currentCart.items
        .where((item) => item.id != itemId)
        .toList();

    if (updatedItems.isEmpty) {
      // Cart is empty, go to idle
      showIdle();
    } else {
      // Recalculate totals
      final subtotal = updatedItems.fold(
        0.0,
        (sum, i) => sum + i.lineTotal,
      );
      final tax = subtotal * 0.1;
      final total = subtotal + tax - currentCart.discount;

      final updatedCart = currentCart.copyWith(
        items: updatedItems,
        subtotal: subtotal,
        tax: tax,
        total: total,
      );

      updateCart(updatedCart);
    }
  }

  /// Update item quantity
  void updateItemQuantity(String itemId, int newQuantity) {
    if (_currentState.currentCart == null) return;

    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    final currentCart = _currentState.currentCart!;
    final updatedItems = currentCart.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(
          quantity: newQuantity,
          lineTotal: item.unitPrice * newQuantity,
          isLastScanned: true,
          scannedAt: DateTime.now(),
        );
      }
      return item;
    }).toList();

    // Recalculate totals
    final subtotal = updatedItems.fold(
      0.0,
      (sum, i) => sum + i.lineTotal,
    );
    final tax = subtotal * 0.1;
    final total = subtotal + tax - currentCart.discount;

    final updatedCart = currentCart.copyWith(
      items: updatedItems,
      subtotal: subtotal,
      tax: tax,
      total: total,
      lastScannedItemId: itemId,
    );

    updateCart(updatedCart);
  }

  /// Clear cart (cancel order)
  void clearCart() {
    showIdle();
  }

  /// Start payment
  void startPayment(PaymentMethod method, double amount) {
    final payment = PaymentProgress(
      id: 'payment_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      paymentMethod: method,
      status: PaymentStatus.processing,
      startedAt: DateTime.now(),
    );

    _currentState = CustomerDisplayState.processingPayment(payment);
    _stateController.add(_currentState);
    _cancelIdleTimer();
    debugPrint('Payment started: ${method.displayName}, \$${amount}');
  }

  /// Update payment status
  void updatePaymentStatus(PaymentStatus status, {String? errorMessage, String? transactionId}) {
    if (_currentState.paymentProgress == null) return;

    final updatedPayment = _currentState.paymentProgress!.copyWith(
      status: status,
      errorMessage: errorMessage,
      transactionId: transactionId,
    );

    _currentState = _currentState.copyWith(
      paymentProgress: updatedPayment,
    );
    _stateController.add(_currentState);

    // If payment successful, show thank you after delay
    if (status == PaymentStatus.success) {
      Future.delayed(const Duration(seconds: 2), () {
        completeOrder();
      });
    }

    // If payment failed or cancelled, go back to cart
    if (status == PaymentStatus.failed || status == PaymentStatus.cancelled) {
      Future.delayed(const Duration(seconds: 3), () {
        if (_currentState.currentCart != null) {
          updateCart(_currentState.currentCart!);
        } else {
          showIdle();
        }
      });
    }
  }

  /// Complete order
  void completeOrder() {
    final cart = _currentState.currentCart;
    if (cart == null) {
      showIdle();
      return;
    }

    final completed = CompletedOrder(
      id: cart.id,
      orderNumber: 'ORD-${DateTime.now().millisecondsSinceEpoch % 1000}',
      total: cart.total,
      totalItems: cart.totalItems,
      completedAt: DateTime.now(),
      customerName: cart.customerName,
    );

    _currentState = CustomerDisplayState.completedOrder(completed);
    _stateController.add(_currentState);
    debugPrint('Order completed: ${completed.orderNumber}');

    // Return to idle after showing thank you
    Future.delayed(const Duration(seconds: 5), () {
      showIdle();
    });
  }

  /// Show idle screen
  void showIdle({MarketingContent? content}) {
    _currentState = CustomerDisplayState.idle(
      content: content ?? MarketingContent.welcome(),
    );
    _stateController.add(_currentState);
    _startIdleTimer();
    debugPrint('Display returned to idle');
  }

  /// Update marketing content
  void updateMarketingContent(MarketingContent content) {
    if (_currentState.isIdle) {
      _currentState = _currentState.copyWith(
        marketingContent: content,
      );
      _stateController.add(_currentState);
    }
  }

  /// Load mock demo data
  void loadMockDemo() {
    Future.delayed(const Duration(seconds: 2), () {
      // Add first item
      addItem(const CustomerCartItem(
        id: 'item1',
        productId: 'burger1',
        productName: 'Classic Burger',
        quantity: 1,
        unitPrice: 12.99,
        lineTotal: 12.99,
        categoryName: 'Burgers',
        modifiers: ['No onions', 'Extra cheese'],
      ));
    });

    Future.delayed(const Duration(seconds: 4), () {
      // Add second item
      addItem(const CustomerCartItem(
        id: 'item2',
        productId: 'fries1',
        productName: 'French Fries',
        quantity: 2,
        unitPrice: 3.99,
        lineTotal: 7.98,
        categoryName: 'Sides',
      ));
    });

    Future.delayed(const Duration(seconds: 6), () {
      // Add third item
      addItem(const CustomerCartItem(
        id: 'item3',
        productId: 'drink1',
        productName: 'Cola',
        quantity: 2,
        unitPrice: 2.49,
        lineTotal: 4.98,
        categoryName: 'Drinks',
      ));
    });

    Future.delayed(const Duration(seconds: 10), () {
      // Start payment
      if (_currentState.currentCart != null) {
        startPayment(
          PaymentMethod.card,
          _currentState.currentCart!.total,
        );
      }
    });

    Future.delayed(const Duration(seconds: 13), () {
      // Complete payment
      updatePaymentStatus(
        PaymentStatus.success,
        transactionId: 'TXN123456',
      );
    });
  }

  // Private methods

  void _startIdleTimer() {
    _cancelIdleTimer();
    _idleTimer = Timer(_idleTimeout, () {
      if (!_currentState.isIdle) {
        showIdle();
      }
    });
  }

  void _resetIdleTimer() {
    _cancelIdleTimer();
    _startIdleTimer();
  }

  void _cancelIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = null;
  }

  bool _modifiersMatch(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    final aSet = Set<String>.from(a);
    final bSet = Set<String>.from(b);
    return aSet.difference(bSet).isEmpty;
  }

  /// Dispose resources
  void dispose() {
    _cancelIdleTimer();
    _stateController.close();
  }
}

/// Customer Display State Notifier
/// Manages display state with Riverpod
class CustomerDisplayStateNotifier extends StateNotifier<CustomerDisplayState> {
  final CustomerDisplayService _service;
  StreamSubscription<CustomerDisplayState>? _subscription;

  CustomerDisplayStateNotifier(this._service)
      : super(CustomerDisplayState.idle(content: MarketingContent.welcome())) {
    _service.initialize();
    state = _service.currentState;

    _subscription = _service.stateStream.listen((newState) {
      state = newState;
    });
  }

  /// Public methods for UI to call

  void addItem(CustomerCartItem item) => _service.addItem(item);
  void removeItem(String itemId) => _service.removeItem(itemId);
  void updateQuantity(String itemId, int quantity) =>
      _service.updateItemQuantity(itemId, quantity);
  void clearCart() => _service.clearCart();
  void startPayment(PaymentMethod method, double amount) =>
      _service.startPayment(method, amount);
  void updatePaymentStatus(PaymentStatus status,
          {String? errorMessage, String? transactionId}) =>
      _service.updatePaymentStatus(status,
          errorMessage: errorMessage, transactionId: transactionId);
  void completeOrder() => _service.completeOrder();
  void showIdle({MarketingContent? content}) =>
      _service.showIdle(content: content);
  void updateMarketingContent(MarketingContent content) =>
      _service.updateMarketingContent(content);
  void loadMockDemo() => _service.loadMockDemo();

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
