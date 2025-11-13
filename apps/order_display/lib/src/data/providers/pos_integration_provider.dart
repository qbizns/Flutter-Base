/// POS Integration Provider
/// Syncs customer display with POS register cart in real-time
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../models/customer_display_models.dart';
import '../services/customer_display_service.dart';

/// Provider that watches POS cart and syncs to customer display
/// This simulates the real-time connection between POS register and customer display
final posDisplaySyncProvider = Provider<PosDisplaySync>((ref) {
  final displayService = ref.watch(customerDisplayServiceProvider);
  return PosDisplaySync(ref, displayService);
});

/// Auto-start sync provider
/// Use this in app startup to automatically sync POS cart to display
final autoSyncProvider = Provider<void>((ref) {
  final sync = ref.watch(posDisplaySyncProvider);

  // Watch for cart changes and sync to display
  ref.listen<Cart>(
    cartNotifierProvider,
    (previous, next) {
      sync.syncCart(next);
    },
  );

  return;
});

/// POS Display Sync Service
/// Handles synchronization between POS register and customer display
class PosDisplaySync {
  final Ref _ref;
  final CustomerDisplayService _displayService;
  Timer? _syncTimer;

  PosDisplaySync(this._ref, this._displayService) {
    _startSync();
  }

  /// Start periodic sync (fallback for when watching doesn't work)
  void _startSync() {
    // Sync every 2 seconds as fallback
    _syncTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final cart = _ref.read(cartNotifierProvider);
      syncCart(cart);
    });
  }

  /// Sync POS cart to customer display
  void syncCart(Cart cart) {
    if (cart.isEmpty) {
      _displayService.showIdle();
      return;
    }

    // Convert POS cart to customer display cart
    final displayCart = _convertToCustomerCart(cart);
    _displayService.updateCart(displayCart);
  }

  /// Convert POS Cart to Customer Display Cart
  CustomerCart _convertToCustomerCart(Cart cart) {
    // Convert items
    final displayItems = cart.items.map((item) {
      return CustomerCartItem(
        id: item.id,
        productId: item.productId,
        productName: item.productName,
        unitPrice: item.basePrice,
        quantity: item.quantity,
        lineTotal: item.total,
        modifiers: item.selectedModifiers.map((m) => m.name).toList(),
        imageUrl: item.productImageUrl,
        sku: item.productSku,
        notes: item.notes,
      );
    }).toList();

    return CustomerCart(
      id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
      items: displayItems,
      subtotal: cart.subtotal,
      tax: cart.taxAmount,
      discount: cart.cartDiscount,
      total: cart.total,
      createdAt: DateTime.now(),
      lastScannedItemId: displayItems.isNotEmpty ? displayItems.last.id : null,
      customerName: cart.customerName,
      tableNumber: cart.tableName,
    );
  }

  /// Notify payment started
  void startPayment(double total) {
    _displayService.showPayment(
      PaymentInfo(
        total: total,
        tendered: 0,
        change: 0,
        paymentMethod: 'Processing...',
      ),
    );
  }

  /// Notify payment completed
  void completePayment({
    required double total,
    required double tendered,
    required String paymentMethod,
  }) {
    _displayService.showPayment(
      PaymentInfo(
        total: total,
        tendered: tendered,
        change: tendered - total,
        paymentMethod: paymentMethod,
      ),
    );

    // Show thank you after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _displayService.showThankYou();
    });
  }

  void dispose() {
    _syncTimer?.cancel();
  }
}

/// Payment Info model for customer display
class PaymentInfo {
  final double total;
  final double tendered;
  final double change;
  final String paymentMethod;

  PaymentInfo({
    required this.total,
    required this.tendered,
    required this.change,
    required this.paymentMethod,
  });
}
