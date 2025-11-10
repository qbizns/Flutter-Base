import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

/// Bumped Order - Tracks orders that were bumped with timestamp
class BumpedOrder {
  const BumpedOrder({
    required this.order,
    required this.bumpedAt,
  });

  final Order order;
  final DateTime bumpedAt;
}

/// Bumped Orders Notifier - Manages list of recently bumped orders
class BumpedOrdersNotifier extends StateNotifier<List<BumpedOrder>> {
  BumpedOrdersNotifier() : super([]);

  /// Add order to bumped list
  void addBumpedOrder(Order order) {
    final bumpedOrder = BumpedOrder(
      order: order,
      bumpedAt: DateTime.now(),
    );

    state = [bumpedOrder, ...state];

    // Keep only last 20 bumped orders
    if (state.length > 20) {
      state = state.sublist(0, 20);
    }

    // Remove orders older than 2 hours
    _cleanupOldOrders();
  }

  /// Remove order from bumped list (when recalled)
  void removeBumpedOrder(String orderId) {
    state = state.where((b) => b.order.id != orderId).toList();
  }

  /// Clear all bumped orders
  void clearAll() {
    state = [];
  }

  /// Clean up orders older than 2 hours
  void _cleanupOldOrders() {
    final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
    state = state.where((b) => b.bumpedAt.isAfter(twoHoursAgo)).toList();
  }

  /// Get bumped order by ID
  BumpedOrder? getBumpedOrder(String orderId) {
    try {
      return state.firstWhere((b) => b.order.id == orderId);
    } catch (e) {
      return null;
    }
  }
}

/// Provider for bumped orders
final bumpedOrdersProvider = StateNotifierProvider<BumpedOrdersNotifier, List<BumpedOrder>>((ref) {
  return BumpedOrdersNotifier();
});
