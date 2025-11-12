import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

import '../../../session/presentation/widgets/session_guard.dart';

/// Checkout page for completing orders and processing payments
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  int _currentStep = 0;
  PaymentMethod? _selectedPaymentMethod;
  double _tipAmount = 0;
  OrderType _orderType = OrderType.dineIn;
  String? _selectedTableId;

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartNotifierProvider);

    if (cart.isEmpty) {
      // Redirect if cart is empty
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go('/');
        }
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SessionGuard(
        requireOpenSession: true,
        child: Stepper(
        currentStep: _currentStep,
        onStepContinue: _handleStepContinue,
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep--);
          } else {
            context.pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                FilledButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == 3 ? 'Complete Payment' : 'Continue'),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Back'),
                ),
              ],
            ),
          );
        },
        steps: [
          // Step 1: Order Type & Table
          Step(
            title: const Text('Order Details'),
            content: _buildOrderDetailsStep(cart),
            isActive: _currentStep >= 0,
            state: _currentStep > 0 ? StepState.complete : StepState.indexed,
          ),

          // Step 2: Review Order
          Step(
            title: const Text('Review Order'),
            content: _buildReviewOrderStep(cart),
            isActive: _currentStep >= 1,
            state: _currentStep > 1 ? StepState.complete : StepState.indexed,
          ),

          // Step 3: Add Tip
          Step(
            title: const Text('Add Tip'),
            content: TipSelector(
              subtotal: cart.subtotal,
              onTipChanged: (tip) {
                setState(() => _tipAmount = tip);
                ref.read(cartNotifierProvider.notifier).setTip(tip);
              },
            ),
            isActive: _currentStep >= 2,
            state: _currentStep > 2 ? StepState.complete : StepState.indexed,
          ),

          // Step 4: Payment Method
          Step(
            title: const Text('Payment Method'),
            content: PaymentMethodGrid(
              selectedMethod: _selectedPaymentMethod,
              onMethodSelected: (method) {
                setState(() => _selectedPaymentMethod = method);
              },
            ),
            isActive: _currentStep >= 3,
            state: _currentStep > 3 ? StepState.complete : StepState.indexed,
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsStep(Cart cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Type',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: OrderType.values.map((type) {
            return ChoiceChip(
              label: Text(_getOrderTypeLabel(type)),
              selected: _orderType == type,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _orderType = type);
                }
              },
            );
          }).toList(),
        ),
        if (_orderType == OrderType.dineIn) ...[
          const SizedBox(height: 24),
          const Text(
            'Select Table',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTableSelector(),
        ],
      ],
    );
  }

  Widget _buildTableSelector() {
    final tablesAsync = ref.watch(availableTablesProvider());

    return tablesAsync.when(
      data: (tables) {
        if (tables.isEmpty) {
          return const Text('No available tables');
        }

        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tables.map((table) {
            return ChoiceChip(
              label: Text('${table.name} (${table.capacity} seats)'),
              selected: _selectedTableId == table.id,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedTableId = table.id);
                }
              },
            );
          }).toList(),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Error loading tables'),
    );
  }

  Widget _buildReviewOrderStep(Cart cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Order Summary',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...cart.items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OrderItemTile(
                item: item,
                showQuantityControls: false,
              ),
            )),
        const Divider(height: 32),
        _buildSummaryRow('Subtotal', cart.subtotal),
        if (cart.cartDiscount > 0)
          _buildSummaryRow('Discount', -cart.cartDiscount),
        _buildSummaryRow('Tax', cart.taxAmount),
        const Divider(height: 24),
        _buildSummaryRow('Total', cart.total, bold: true),
      ],
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.bold : null,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleStepContinue() async {
    if (_currentStep < 3) {
      // Validate current step
      if (_currentStep == 0 &&
          _orderType == OrderType.dineIn &&
          _selectedTableId == null) {
        _showError('Please select a table');
        return;
      }

      setState(() => _currentStep++);
    } else {
      // Final step - process payment
      await _processPayment();
    }
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) {
      _showError('Please select a payment method');
      return;
    }

    final cart = ref.read(cartNotifierProvider);

    try {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      // Create order first
      final order = Order(
        id: '',
        orderNumber: '',
        status: OrderStatus.pending,
        orderType: _orderType,
        items: cart.items,
        createdAt: DateTime.now(),
        tableId: _selectedTableId,
        subtotal: cart.subtotal,
        discountAmount: cart.cartDiscount,
        taxAmount: cart.taxAmount,
        tipAmount: _tipAmount,
        total: cart.total,
        paymentStatus: PaymentStatus.pending,
      );

      final createOrderResult = await ref.read(createOrderUseCaseProvider)(order);

      final createdOrder = await createOrderResult.when(
        success: (order) => order,
        failure: (error) => throw Exception(error.message),
      );

      // Create payment
      final payment = Payment(
        id: '',
        orderId: createdOrder.id,
        amount: cart.total - _tipAmount,
        method: _selectedPaymentMethod!,
        status: PaymentStatus.pending,
        tipAmount: _tipAmount,
        createdAt: DateTime.now(),
      );

      final paymentResult = await ref.read(processPaymentUseCaseProvider)(payment);

      await paymentResult.when(
        success: (processedPayment) async {
          // If table selected, assign order to table
          if (_selectedTableId != null) {
            await ref.read(assignOrderToTableUseCaseProvider)(
              _selectedTableId!,
              createdOrder.id,
            );
          }

          // Clear cart
          ref.read(cartNotifierProvider.notifier).clear();

          // Close loading
          if (mounted) {
            Navigator.pop(context);
          }

          // Show success and go home
          _showSuccess(processedPayment);
        },
        failure: (error) {
          if (mounted) {
            Navigator.pop(context);
          }
          throw Exception(error.message);
        },
      );
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
      }
      _showError('Payment failed: $e');
    }
  }

  void _showSuccess(Payment payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Order completed successfully'),
            const SizedBox(height: 8),
            Text(
              '\$${payment.totalAmount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/');
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _getOrderTypeLabel(OrderType type) {
    switch (type) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
      case OrderType.driveThru:
        return 'Drive-Thru';
      case OrderType.online:
        return 'Online';
    }
  }
}
