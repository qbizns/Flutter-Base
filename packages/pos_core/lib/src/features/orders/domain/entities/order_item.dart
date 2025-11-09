import 'package:equatable/equatable.dart';
import '../../../products/domain/entities/modifier.dart';

/// Order item entity representing a product in an order.
///
/// Contains the product information, quantity, selected modifiers,
/// and calculated pricing.
class OrderItem extends Equatable {
  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.basePrice,
    required this.quantity,
    this.productSku,
    this.productImageUrl,
    this.categoryId,
    this.selectedPriceTier,
    this.selectedModifiers = const [],
    this.notes,
    this.discountAmount = 0,
    this.discountPercent = 0,
    this.taxAmount = 0,
    this.taxPercent = 0,
  });

  /// Unique identifier for this order item
  final String id;

  /// Product ID
  final String productId;

  /// Product name (snapshot at time of order)
  final String productName;

  /// Base price per unit
  final double basePrice;

  /// Quantity ordered
  final int quantity;

  /// Product SKU
  final String? productSku;

  /// Product image URL
  final String? productImageUrl;

  /// Category ID
  final String? categoryId;

  /// Selected price tier (size, etc.)
  final String? selectedPriceTier;

  /// Selected modifiers
  final List<SelectedModifier> selectedModifiers;

  /// Special instructions/notes
  final String? notes;

  /// Discount amount per unit
  final double discountAmount;

  /// Discount percentage
  final double discountPercent;

  /// Tax amount per unit
  final double taxAmount;

  /// Tax percentage
  final double taxPercent;

  /// Calculate total modifiers price
  double get modifiersTotal {
    return selectedModifiers.fold(
      0.0,
      (sum, modifier) => sum + modifier.price,
    );
  }

  /// Calculate price per unit (base + modifiers)
  double get unitPrice => basePrice + modifiersTotal;

  /// Calculate subtotal (before discount and tax)
  double get subtotal => unitPrice * quantity;

  /// Calculate total discount for this item
  double get totalDiscount {
    if (discountPercent > 0) {
      return subtotal * (discountPercent / 100);
    }
    return discountAmount * quantity;
  }

  /// Calculate subtotal after discount
  double get subtotalAfterDiscount => subtotal - totalDiscount;

  /// Calculate total tax for this item
  double get totalTax {
    if (taxPercent > 0) {
      return subtotalAfterDiscount * (taxPercent / 100);
    }
    return taxAmount * quantity;
  }

  /// Calculate total price (subtotal - discount + tax)
  double get total => subtotalAfterDiscount + totalTax;

  /// Copy with method for immutability
  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    double? basePrice,
    int? quantity,
    String? productSku,
    String? productImageUrl,
    String? categoryId,
    String? selectedPriceTier,
    List<SelectedModifier>? selectedModifiers,
    String? notes,
    double? discountAmount,
    double? discountPercent,
    double? taxAmount,
    double? taxPercent,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      basePrice: basePrice ?? this.basePrice,
      quantity: quantity ?? this.quantity,
      productSku: productSku ?? this.productSku,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      categoryId: categoryId ?? this.categoryId,
      selectedPriceTier: selectedPriceTier ?? this.selectedPriceTier,
      selectedModifiers: selectedModifiers ?? this.selectedModifiers,
      notes: notes ?? this.notes,
      discountAmount: discountAmount ?? this.discountAmount,
      discountPercent: discountPercent ?? this.discountPercent,
      taxAmount: taxAmount ?? this.taxAmount,
      taxPercent: taxPercent ?? this.taxPercent,
    );
  }

  @override
  List<Object?> get props => [
        id,
        productId,
        productName,
        basePrice,
        quantity,
        productSku,
        productImageUrl,
        categoryId,
        selectedPriceTier,
        selectedModifiers,
        notes,
        discountAmount,
        discountPercent,
        taxAmount,
        taxPercent,
      ];
}

/// Selected modifier with quantity (for multiple selections)
class SelectedModifier extends Equatable {
  const SelectedModifier({
    required this.modifierId,
    required this.modifierName,
    required this.price,
    this.quantity = 1,
  });

  final String modifierId;
  final String modifierName;
  final double price;
  final int quantity;

  SelectedModifier copyWith({
    String? modifierId,
    String? modifierName,
    double? price,
    int? quantity,
  }) {
    return SelectedModifier(
      modifierId: modifierId ?? this.modifierId,
      modifierName: modifierName ?? this.modifierName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [modifierId, modifierName, price, quantity];
}
