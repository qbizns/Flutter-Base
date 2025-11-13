/// Order Workflow Integration
/// Complete order lifecycle demonstration and testing utilities
library;

import 'package:uuid/uuid.dart';
import 'package:pos_core/pos_core.dart';
import 'order_workflow_validator.dart';

/// Order workflow integration helper
///
/// Demonstrates complete order lifecycle:
/// 1. Create order (draft)
/// 2. Add/modify items
/// 3. Confirm order (send to kitchen)
/// 4. Update status (preparing → ready → completed)
/// 5. Process payment
///
/// Usage:
/// ```dart
/// final workflow = OrderWorkflowIntegration();
/// final order = await workflow.createSampleOrder();
/// await workflow.executeFullWorkflow(order);
/// ```
class OrderWorkflowIntegration {
  static const _uuid = Uuid();

  /// Create a sample order for testing
  Order createSampleOrder({
    OrderType orderType = OrderType.dineIn,
    String? tableId,
    String? tableName,
    int itemCount = 3,
  }) {
    final orderId = _uuid.v4();
    final now = DateTime.now();

    // Create sample items
    final items = <OrderItem>[];

    for (int i = 0; i < itemCount; i++) {
      items.add(OrderItem(
        id: _uuid.v4(),
        productId: 'prod-$i',
        productName: _getSampleProductName(i),
        basePrice: _getSamplePrice(i),
        quantity: 1 + (i % 3),
        taxPercent: 8.5,
        categoryId: _getSampleCategory(i),
      ));
    }

    // Calculate totals
    final subtotal = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final taxAmount = subtotal * 0.085;
    final total = subtotal + taxAmount;

    return Order(
      id: orderId,
      orderNumber: 'ORD-${now.millisecondsSinceEpoch.toString().substring(8)}',
      status: OrderStatus.draft,
      orderType: orderType,
      items: items,
      tableId: tableId,
      tableName: tableName,
      subtotal: subtotal,
      taxAmount: taxAmount,
      taxPercent: 8.5,
      total: total,
      createdAt: now,
    );
  }

  /// Execute complete order workflow
  Future<WorkflowResult> executeFullWorkflow(Order initialOrder) async {
    final steps = <WorkflowStep>[];
    var currentOrder = initialOrder;

    try {
      // Step 1: Validate initial order
      steps.add(await _step1ValidateOrder(currentOrder));

      // Step 2: Confirm order
      final confirmResult = await _step2ConfirmOrder(currentOrder);
      steps.add(confirmResult);
      currentOrder = confirmResult.updatedOrder!;

      // Step 3: Route to kitchen
      steps.add(await _step3RouteToKitchen(currentOrder));

      // Step 4: Update to preparing
      final preparingResult = await _step4UpdateToPreparing(currentOrder);
      steps.add(preparingResult);
      currentOrder = preparingResult.updatedOrder!;

      // Step 5: Update to ready
      final readyResult = await _step5UpdateToReady(currentOrder);
      steps.add(readyResult);
      currentOrder = readyResult.updatedOrder!;

      // Step 6: Complete order
      final completeResult = await _step6CompleteOrder(currentOrder);
      steps.add(completeResult);
      currentOrder = completeResult.updatedOrder!;

      // Step 7: Process payment
      steps.add(await _step7ProcessPayment(currentOrder));

      return WorkflowResult(
        success: true,
        steps: steps,
        finalOrder: currentOrder,
      );
    } catch (e) {
      return WorkflowResult(
        success: false,
        steps: steps,
        finalOrder: currentOrder,
        error: e.toString(),
      );
    }
  }

  /// Test order modifications
  Future<WorkflowResult> testOrderModifications(Order initialOrder) async {
    final steps = <WorkflowStep>[];
    var currentOrder = initialOrder;

    try {
      // Test 1: Add item
      final addResult = await _testAddItem(currentOrder);
      steps.add(addResult);
      currentOrder = addResult.updatedOrder!;

      // Test 2: Update quantity
      final updateResult = await _testUpdateQuantity(currentOrder);
      steps.add(updateResult);
      currentOrder = updateResult.updatedOrder!;

      // Test 3: Remove item (if more than 2 items)
      if (currentOrder.items.length > 2) {
        final removeResult = await _testRemoveItem(currentOrder);
        steps.add(removeResult);
        currentOrder = removeResult.updatedOrder!;
      }

      // Test 4: Validate totals
      steps.add(await _testValidateTotals(currentOrder));

      return WorkflowResult(
        success: true,
        steps: steps,
        finalOrder: currentOrder,
      );
    } catch (e) {
      return WorkflowResult(
        success: false,
        steps: steps,
        finalOrder: currentOrder,
        error: e.toString(),
      );
    }
  }

  /// Test status transitions
  Future<WorkflowResult> testStatusTransitions(Order initialOrder) async {
    final steps = <WorkflowStep>[];
    var currentOrder = initialOrder;

    final transitions = [
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.completed,
    ];

    try {
      for (final newStatus in transitions) {
        final result = await _testStatusTransition(currentOrder, newStatus);
        steps.add(result);
        currentOrder = result.updatedOrder!;
      }

      return WorkflowResult(
        success: true,
        steps: steps,
        finalOrder: currentOrder,
      );
    } catch (e) {
      return WorkflowResult(
        success: false,
        steps: steps,
        finalOrder: currentOrder,
        error: e.toString(),
      );
    }
  }

  // ==================== WORKFLOW STEPS ====================

  Future<WorkflowStep> _step1ValidateOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final validation = OrderWorkflowValidator.validateOrderCreation(
      items: order.items,
      orderType: order.orderType,
      tableId: order.tableId,
      customerId: order.customerId,
    );

    return WorkflowStep(
      stepNumber: 1,
      stepName: 'Validate Order',
      success: validation.isValid,
      message: validation.summary,
      warnings: validation.warnings,
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<WorkflowStep> _step2ConfirmOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final updatedOrder = order.copyWith(
      status: OrderStatus.confirmed,
      updatedAt: DateTime.now(),
    );

    return WorkflowStep(
      stepNumber: 2,
      stepName: 'Confirm Order',
      success: true,
      message: 'Order confirmed and ready for kitchen',
      updatedOrder: updatedOrder,
      duration: const Duration(milliseconds: 200),
    );
  }

  Future<WorkflowStep> _step3RouteToKitchen(Order order) async {
    await Future.delayed(const Duration(milliseconds: 150));

    // Simulate kitchen routing
    final stationCount = _calculateStationCount(order);

    return WorkflowStep(
      stepNumber: 3,
      stepName: 'Route to Kitchen',
      success: true,
      message: 'Order routed to $stationCount kitchen station(s)',
      duration: const Duration(milliseconds: 150),
    );
  }

  Future<WorkflowStep> _step4UpdateToPreparing(Order order) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final updatedOrder = order.copyWith(
      status: OrderStatus.preparing,
      updatedAt: DateTime.now(),
    );

    return WorkflowStep(
      stepNumber: 4,
      stepName: 'Update to Preparing',
      success: true,
      message: 'Kitchen acknowledged - preparing order',
      updatedOrder: updatedOrder,
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<WorkflowStep> _step5UpdateToReady(Order order) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final updatedOrder = order.copyWith(
      status: OrderStatus.ready,
      updatedAt: DateTime.now(),
    );

    return WorkflowStep(
      stepNumber: 5,
      stepName: 'Update to Ready',
      success: true,
      message: 'Order ready for pickup/serving',
      updatedOrder: updatedOrder,
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<WorkflowStep> _step6CompleteOrder(Order order) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final now = DateTime.now();
    final updatedOrder = order.copyWith(
      status: OrderStatus.completed,
      updatedAt: now,
      completedAt: now,
    );

    return WorkflowStep(
      stepNumber: 6,
      stepName: 'Complete Order',
      success: true,
      message: 'Order completed successfully',
      updatedOrder: updatedOrder,
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<WorkflowStep> _step7ProcessPayment(Order order) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final validation = OrderWorkflowValidator.validatePayment(
      order: order,
      paymentAmount: order.total,
      paymentMethod: 'cash',
    );

    return WorkflowStep(
      stepNumber: 7,
      stepName: 'Process Payment',
      success: validation.isValid,
      message: 'Payment processed: \$${order.total.toStringAsFixed(2)}',
      duration: const Duration(milliseconds: 200),
    );
  }

  // ==================== MODIFICATION TESTS ====================

  Future<WorkflowStep> _testAddItem(Order order) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final newItem = OrderItem(
      id: _uuid.v4(),
      productId: 'prod-new',
      productName: 'Added Item',
      basePrice: 5.99,
      quantity: 1,
      taxPercent: 8.5,
    );

    final validation = OrderWorkflowValidator.validateOrderModification(
      order: order,
      action: 'add_item',
      newItem: newItem,
    );

    if (validation.isValid) {
      final updatedOrder = _recalculateTotals(
        order.copyWith(items: [...order.items, newItem]),
      );

      return WorkflowStep(
        stepNumber: 1,
        stepName: 'Add Item',
        success: true,
        message: 'Item added successfully',
        updatedOrder: updatedOrder,
        duration: const Duration(milliseconds: 100),
      );
    }

    return WorkflowStep(
      stepNumber: 1,
      stepName: 'Add Item',
      success: false,
      message: validation.errors.join(', '),
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<WorkflowStep> _testUpdateQuantity(Order order) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (order.items.isEmpty) {
      return WorkflowStep(
        stepNumber: 2,
        stepName: 'Update Quantity',
        success: false,
        message: 'No items to update',
        duration: const Duration(milliseconds: 100),
      );
    }

    final firstItem = order.items.first;
    final newQuantity = firstItem.quantity + 1;

    final validation = OrderWorkflowValidator.validateOrderModification(
      order: order,
      action: 'update_quantity',
      itemId: firstItem.id,
      newQuantity: newQuantity,
    );

    if (validation.isValid) {
      final updatedItems = order.items.map((item) {
        if (item.id == firstItem.id) {
          return item.copyWith(quantity: newQuantity);
        }
        return item;
      }).toList();

      final updatedOrder = _recalculateTotals(
        order.copyWith(items: updatedItems),
      );

      return WorkflowStep(
        stepNumber: 2,
        stepName: 'Update Quantity',
        success: true,
        message: 'Quantity updated: ${firstItem.quantity} → $newQuantity',
        updatedOrder: updatedOrder,
        duration: const Duration(milliseconds: 100),
      );
    }

    return WorkflowStep(
      stepNumber: 2,
      stepName: 'Update Quantity',
      success: false,
      message: validation.errors.join(', '),
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<WorkflowStep> _testRemoveItem(Order order) async {
    await Future.delayed(const Duration(milliseconds: 100));

    if (order.items.length <= 1) {
      return WorkflowStep(
        stepNumber: 3,
        stepName: 'Remove Item',
        success: false,
        message: 'Cannot remove last item',
        duration: const Duration(milliseconds: 100),
      );
    }

    final lastItem = order.items.last;

    final validation = OrderWorkflowValidator.validateOrderModification(
      order: order,
      action: 'remove_item',
      itemId: lastItem.id,
    );

    if (validation.isValid) {
      final updatedItems = order.items
          .where((item) => item.id != lastItem.id)
          .toList();

      final updatedOrder = _recalculateTotals(
        order.copyWith(items: updatedItems),
      );

      return WorkflowStep(
        stepNumber: 3,
        stepName: 'Remove Item',
        success: true,
        message: 'Item removed: ${lastItem.productName}',
        updatedOrder: updatedOrder,
        duration: const Duration(milliseconds: 100),
      );
    }

    return WorkflowStep(
      stepNumber: 3,
      stepName: 'Remove Item',
      success: false,
      message: validation.errors.join(', '),
      duration: const Duration(milliseconds: 100),
    );
  }

  Future<WorkflowStep> _testValidateTotals(Order order) async {
    await Future.delayed(const Duration(milliseconds: 50));

    final validation = OrderWorkflowValidator.validateOrderTotals(order: order);

    return WorkflowStep(
      stepNumber: 4,
      stepName: 'Validate Totals',
      success: validation.isValid,
      message: validation.isValid
          ? 'All totals calculated correctly'
          : validation.errors.join(', '),
      warnings: validation.warnings,
      duration: const Duration(milliseconds: 50),
    );
  }

  Future<WorkflowStep> _testStatusTransition(
    Order order,
    OrderStatus newStatus,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final validation = OrderWorkflowValidator.validateStatusTransition(
      currentStatus: order.status,
      newStatus: newStatus,
    );

    if (validation.isValid) {
      final updatedOrder = order.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      return WorkflowStep(
        stepNumber: 0,
        stepName: 'Status Transition',
        success: true,
        message: '${order.status.name} → ${newStatus.name}',
        updatedOrder: updatedOrder,
        warnings: validation.warnings,
        duration: const Duration(milliseconds: 100),
      );
    }

    return WorkflowStep(
      stepNumber: 0,
      stepName: 'Status Transition',
      success: false,
      message: validation.errors.join(', '),
      duration: const Duration(milliseconds: 100),
    );
  }

  // ==================== HELPERS ====================

  Order _recalculateTotals(Order order) {
    final subtotal = order.items.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );

    final discountAmount = order.discountPercent > 0
        ? subtotal * (order.discountPercent / 100)
        : order.discountAmount;

    final subtotalAfterDiscount = subtotal - discountAmount;

    final taxAmount = order.taxPercent > 0
        ? subtotalAfterDiscount * (order.taxPercent / 100)
        : order.taxAmount;

    final total = subtotalAfterDiscount + taxAmount;

    return order.copyWith(
      subtotal: subtotal,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      total: total,
    );
  }

  int _calculateStationCount(Order order) {
    final categories = order.items
        .map((item) => item.categoryId)
        .where((id) => id != null)
        .toSet();
    return categories.isEmpty ? 1 : categories.length;
  }

  String _getSampleProductName(int index) {
    const names = [
      'Classic Burger',
      'French Fries',
      'Coca Cola',
      'Caesar Salad',
      'Chocolate Cake',
    ];
    return names[index % names.length];
  }

  double _getSamplePrice(int index) {
    const prices = [8.99, 3.99, 2.50, 7.99, 5.99];
    return prices[index % prices.length];
  }

  String _getSampleCategory(int index) {
    const categories = ['cat-burgers', 'cat-food', 'cat-beverages', 'cat-salads', 'cat-desserts'];
    return categories[index % categories.length];
  }
}

/// Workflow execution result
class WorkflowResult {
  final bool success;
  final List<WorkflowStep> steps;
  final Order finalOrder;
  final String? error;

  WorkflowResult({
    required this.success,
    required this.steps,
    required this.finalOrder,
    this.error,
  });

  int get totalSteps => steps.length;
  int get successfulSteps => steps.where((s) => s.success).length;
  int get failedSteps => steps.where((s) => !s.success).length;

  Duration get totalDuration => steps.fold(
        Duration.zero,
        (sum, step) => sum + step.duration,
      );

  String get summary {
    if (success) {
      return 'Workflow completed successfully ($successfulSteps/$totalSteps steps) in ${totalDuration.inMilliseconds}ms';
    } else {
      return 'Workflow failed: $error ($successfulSteps/$totalSteps steps completed)';
    }
  }

  List<String> get allWarnings {
    return steps.expand((step) => step.warnings).toList();
  }
}

/// Individual workflow step result
class WorkflowStep {
  final int stepNumber;
  final String stepName;
  final bool success;
  final String message;
  final Order? updatedOrder;
  final List<String> warnings;
  final Duration duration;

  WorkflowStep({
    required this.stepNumber,
    required this.stepName,
    required this.success,
    required this.message,
    this.updatedOrder,
    this.warnings = const [],
    required this.duration,
  });

  String get statusIcon => success ? '✓' : '✗';

  String get summary =>
      '$statusIcon Step $stepNumber: $stepName - $message (${duration.inMilliseconds}ms)';
}
