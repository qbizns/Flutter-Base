/// Order Workflow Validator
/// Validates complete order workflow and business rules
library;

import 'package:pos_core/pos_core.dart';

/// Validation result
class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  factory ValidationResult.success({List<String> warnings = const []}) {
    return ValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  factory ValidationResult.failure(List<String> errors) {
    return ValidationResult(
      isValid: false,
      errors: errors,
    );
  }

  bool get hasWarnings => warnings.isNotEmpty;
  bool get hasErrors => errors.isNotEmpty;

  String get summary {
    if (isValid && !hasWarnings) return 'Valid';
    if (isValid && hasWarnings) return 'Valid with ${warnings.length} warning(s)';
    return 'Invalid: ${errors.length} error(s)';
  }
}

/// Order workflow validator following Odoo business rules
class OrderWorkflowValidator {
  /// Validate order creation
  static ValidationResult validateOrderCreation({
    required List<OrderItem> items,
    required OrderType orderType,
    String? tableId,
    String? customerId,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Must have at least one item
    if (items.isEmpty) {
      errors.add('Order must have at least one item');
    }

    // Validate each item
    for (final item in items) {
      if (item.quantity <= 0) {
        errors.add('Item ${item.productName} has invalid quantity: ${item.quantity}');
      }

      if (item.basePrice < 0) {
        errors.add('Item ${item.productName} has invalid price: ${item.basePrice}');
      }
    }

    // Dine-in orders should have table
    if (orderType == OrderType.dineIn && tableId == null) {
      warnings.add('Dine-in order without table assignment');
    }

    // Delivery orders should have customer
    if (orderType == OrderType.delivery && customerId == null) {
      warnings.add('Delivery order without customer information');
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors);
  }

  /// Validate order modification
  static ValidationResult validateOrderModification({
    required Order order,
    required String action,
    OrderItem? newItem,
    String? itemId,
    int? newQuantity,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if order can be modified
    if (!order.canModify) {
      errors.add('Order ${order.orderNumber} cannot be modified (status: ${order.status.name})');
    }

    // Validate based on action
    switch (action) {
      case 'add_item':
        if (newItem == null) {
          errors.add('New item is required for add_item action');
        } else {
          if (newItem.quantity <= 0) {
            errors.add('Item quantity must be positive');
          }
          if (newItem.basePrice < 0) {
            errors.add('Item price cannot be negative');
          }
        }
        break;

      case 'update_quantity':
        if (itemId == null || newQuantity == null) {
          errors.add('Item ID and new quantity are required for update_quantity action');
        } else if (newQuantity < 0) {
          errors.add('Quantity cannot be negative');
        } else if (newQuantity == 0) {
          warnings.add('Setting quantity to 0 will remove the item');
        }

        // Check if item exists
        if (itemId != null && !order.items.any((item) => item.id == itemId)) {
          errors.add('Item not found in order');
        }
        break;

      case 'remove_item':
        if (itemId == null) {
          errors.add('Item ID is required for remove_item action');
        }

        // Check if item exists
        if (itemId != null && !order.items.any((item) => item.id == itemId)) {
          errors.add('Item not found in order');
        }

        // Warn if removing last item
        if (order.items.length == 1) {
          errors.add('Cannot remove last item. Cancel order instead.');
        }
        break;

      default:
        errors.add('Unknown action: $action');
    }

    // Warn if modifying confirmed order
    if (order.status == OrderStatus.confirmed) {
      warnings.add('Modifying confirmed order - kitchen may have started preparation');
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors);
  }

  /// Validate status transition
  static ValidationResult validateStatusTransition({
    required OrderStatus currentStatus,
    required OrderStatus newStatus,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Check if transition is valid
    if (!_isValidTransition(currentStatus, newStatus)) {
      errors.add(
        'Invalid status transition: ${currentStatus.name} → ${newStatus.name}',
      );
      errors.add('Valid transitions from ${currentStatus.name}: ${_getValidTransitions(currentStatus).map((s) => s.name).join(", ")}');
    }

    // Warn about important transitions
    if (currentStatus == OrderStatus.preparing && newStatus == OrderStatus.cancelled) {
      warnings.add('Cancelling order that is being prepared - may result in waste');
    }

    if (currentStatus == OrderStatus.ready && newStatus == OrderStatus.hold) {
      warnings.add('Putting ready order on hold - food quality may degrade');
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors);
  }

  /// Validate order totals
  static ValidationResult validateOrderTotals({
    required Order order,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Calculate expected subtotal
    final expectedSubtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    // Check subtotal
    if ((order.subtotal - expectedSubtotal).abs() > 0.01) {
      errors.add(
        'Subtotal mismatch: expected $expectedSubtotal, got ${order.subtotal}',
      );
    }

    // Calculate expected discount
    final expectedDiscount = order.discountPercent > 0
        ? order.subtotal * (order.discountPercent / 100)
        : order.discountAmount;

    if ((order.discountAmount - expectedDiscount).abs() > 0.01) {
      errors.add(
        'Discount mismatch: expected $expectedDiscount, got ${order.discountAmount}',
      );
    }

    // Calculate expected tax
    final subtotalAfterDiscount = order.subtotal - order.discountAmount;
    final expectedTax = subtotalAfterDiscount * (order.taxPercent / 100);

    if ((order.taxAmount - expectedTax).abs() > 0.01) {
      errors.add(
        'Tax mismatch: expected $expectedTax, got ${order.taxAmount}',
      );
    }

    // Calculate expected total
    final expectedTotal = subtotalAfterDiscount + order.taxAmount + order.tipAmount;

    if ((order.total - expectedTotal).abs() > 0.01) {
      errors.add(
        'Total mismatch: expected $expectedTotal, got ${order.total}',
      );
    }

    // Warn about unusual values
    if (order.discountPercent > 50) {
      warnings.add('Discount exceeds 50% - verify authorization');
    }

    if (order.tipAmount > order.subtotal * 0.25) {
      warnings.add('Tip exceeds 25% of subtotal - verify amount');
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors);
  }

  /// Validate payment
  static ValidationResult validatePayment({
    required Order order,
    required double paymentAmount,
    required String paymentMethod,
  }) {
    final errors = <String>[];
    final warnings = <String>[];

    // Payment must be positive
    if (paymentAmount <= 0) {
      errors.add('Payment amount must be positive');
    }

    // Check if order is paid
    if (order.isPaid) {
      errors.add('Order is already paid');
    }

    // Warn about overpayment
    if (paymentAmount > order.remainingAmount + 0.01) {
      warnings.add(
        'Payment exceeds remaining amount by \$${(paymentAmount - order.remainingAmount).toStringAsFixed(2)}',
      );
    }

    // Warn about underpayment
    if (paymentAmount < order.remainingAmount - 0.01) {
      warnings.add(
        'Partial payment: \$${order.remainingAmount - paymentAmount} remaining',
      );
    }

    // Validate payment method
    final validMethods = ['cash', 'card', 'mobile', 'other'];
    if (!validMethods.contains(paymentMethod.toLowerCase())) {
      warnings.add('Unknown payment method: $paymentMethod');
    }

    return errors.isEmpty
        ? ValidationResult.success(warnings: warnings)
        : ValidationResult.failure(errors);
  }

  // ==================== PRIVATE HELPERS ====================

  static bool _isValidTransition(OrderStatus from, OrderStatus to) {
    final validTransitions = _getValidTransitions(from);
    return validTransitions.contains(to);
  }

  static List<OrderStatus> _getValidTransitions(OrderStatus from) {
    switch (from) {
      case OrderStatus.draft:
        return [OrderStatus.confirmed, OrderStatus.cancelled];
      case OrderStatus.pending:
        return [OrderStatus.confirmed, OrderStatus.cancelled];
      case OrderStatus.confirmed:
        return [OrderStatus.preparing, OrderStatus.cancelled, OrderStatus.hold];
      case OrderStatus.preparing:
        return [OrderStatus.ready, OrderStatus.hold, OrderStatus.cancelled];
      case OrderStatus.ready:
        return [OrderStatus.delivering, OrderStatus.completed, OrderStatus.hold];
      case OrderStatus.delivering:
        return [OrderStatus.completed, OrderStatus.hold];
      case OrderStatus.hold:
        return [OrderStatus.preparing, OrderStatus.cancelled];
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return []; // Terminal states
    }
  }
}
