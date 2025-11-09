import 'package:equatable/equatable.dart';
import 'order_item.dart';

/// Shopping cart entity.
///
/// Represents the current order being built before submission.
/// Contains items, discounts, and calculates totals.
class Cart extends Equatable {
  const Cart({
    this.items = const [],
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.taxPercent = 0,
    this.tipAmount = 0,
    this.notes,
    this.tableId,
    this.tableName,
    this.customerId,
    this.customerName,
  });

  /// Items in the cart
  final List<OrderItem> items;

  /// Cart-level discount amount
  final double discountAmount;

  /// Cart-level discount percentage
  final double discountPercent;

  /// Tax percentage to apply
  final double taxPercent;

  /// Tip amount
  final double tipAmount;

  /// Order notes
  final String? notes;

  /// Table ID (for dine-in)
  final String? tableId;

  /// Table name
  final String? tableName;

  /// Customer ID
  final String? customerId;

  /// Customer name
  final String? customerName;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart has items
  bool get isNotEmpty => items.isNotEmpty;

  /// Get total number of items
  int get itemsCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Calculate subtotal (sum of all item totals before cart-level discount/tax)
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.total);
  }

  /// Calculate cart-level discount
  double get cartDiscount {
    if (discountPercent > 0) {
      return subtotal * (discountPercent / 100);
    }
    return discountAmount;
  }

  /// Calculate subtotal after discount
  double get subtotalAfterDiscount => subtotal - cartDiscount;

  /// Calculate tax amount
  double get taxAmount {
    if (taxPercent > 0) {
      return subtotalAfterDiscount * (taxPercent / 100);
    }
    return 0;
  }

  /// Calculate total
  double get total => subtotalAfterDiscount + taxAmount + tipAmount;

  /// Find item by product ID
  OrderItem? findItemByProductId(String productId) {
    try {
      return items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  /// Check if product is in cart
  bool containsProduct(String productId) {
    return items.any((item) => item.productId == productId);
  }

  /// Add item to cart
  Cart addItem(OrderItem item) {
    final updatedItems = List<OrderItem>.from(items)..add(item);
    return copyWith(items: updatedItems);
  }

  /// Remove item from cart
  Cart removeItem(String itemId) {
    final updatedItems = items.where((item) => item.id != itemId).toList();
    return copyWith(items: updatedItems);
  }

  /// Update item in cart
  Cart updateItem(String itemId, OrderItem updatedItem) {
    final updatedItems = items.map((item) {
      return item.id == itemId ? updatedItem : item;
    }).toList();
    return copyWith(items: updatedItems);
  }

  /// Update item quantity
  Cart updateItemQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      return removeItem(itemId);
    }

    final updatedItems = items.map((item) {
      return item.id == itemId ? item.copyWith(quantity: newQuantity) : item;
    }).toList();
    return copyWith(items: updatedItems);
  }

  /// Update item notes
  Cart updateItemNotes(String itemId, String notes) {
    final updatedItems = items.map((item) {
      return item.id == itemId ? item.copyWith(notes: notes) : item;
    }).toList();
    return copyWith(items: updatedItems);
  }

  /// Clear cart
  Cart clear() {
    return const Cart();
  }

  /// Apply cart-level discount
  Cart applyDiscount({double? amount, double? percent}) {
    return copyWith(
      discountAmount: amount ?? 0,
      discountPercent: percent ?? 0,
    );
  }

  /// Remove cart-level discount
  Cart removeDiscount() {
    return copyWith(
      discountAmount: 0,
      discountPercent: 0,
    );
  }

  /// Apply tax
  Cart applyTax(double taxPercent) {
    return copyWith(taxPercent: taxPercent);
  }

  /// Apply tip
  Cart applyTip(double tipAmount) {
    return copyWith(tipAmount: tipAmount);
  }

  /// Set tip (alias for applyTip)
  Cart setTip(double tipAmount) {
    return applyTip(tipAmount);
  }

  /// Set table
  Cart setTable(String? tableId, String? tableName) {
    return copyWith(
      tableId: tableId,
      tableName: tableName,
    );
  }

  /// Set customer
  Cart setCustomer(String? customerId, String? customerName) {
    return copyWith(
      customerId: customerId,
      customerName: customerName,
    );
  }

  /// Copy with method
  Cart copyWith({
    List<OrderItem>? items,
    double? discountAmount,
    double? discountPercent,
    double? taxPercent,
    double? tipAmount,
    String? notes,
    String? tableId,
    String? tableName,
    String? customerId,
    String? customerName,
  }) {
    return Cart(
      items: items ?? this.items,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      taxPercent: taxPercent ?? this.taxPercent,
      tipAmount: tipAmount ?? this.tipAmount,
      notes: notes ?? this.notes,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
    );
  }

  @override
  List<Object?> get props => [
        items,
        discountAmount,
        discountPercent,
        taxPercent,
        tipAmount,
        notes,
        tableId,
        tableName,
        customerId,
        customerName,
      ];
}
