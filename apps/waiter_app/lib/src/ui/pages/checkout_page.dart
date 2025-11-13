/// Checkout/Payment Page for Waiter App
/// Handle table checkout with payment options and bill splitting
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import '../../data/models/waiter_models.dart';
import '../../data/providers.dart';

/// Checkout Page
/// Process payment for a table order
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({
    super.key,
    required this.tableId,
  });

  final String tableId;

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  bool _isProcessing = false;
  double? _customTipAmount;
  double _tipPercent = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ordersAsync = ref.watch(tableOrdersProvider(widget.tableId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Table ${widget.tableId} - Checkout'),
        elevation: 0,
      ),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('Error loading order', style: theme.textTheme.titleLarge),
            ],
          ),
        ),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No active order'));
          }

          final order = orders.first;
          return _buildCheckoutContent(context, order);
        },
      ),
    );
  }

  Widget _buildCheckoutContent(BuildContext context, Order order) {
    final theme = Theme.of(context);
    final tipAmount = _customTipAmount ?? (order.subtotal * _tipPercent);
    final total = order.total + tipAmount;

    return Column(
      children: [
        // Order summary
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order items summary
                _buildOrderSummary(context, order),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Tip section
                Text(
                  'Add Tip',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildTipSection(order.subtotal),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Payment method
                Text(
                  'Payment Method',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildPaymentMethods(),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Total breakdown
                _buildTotalBreakdown(order, tipAmount, total),
              ],
            ),
          ),
        ),

        // Bottom action button
        _buildBottomButton(context, order, tipAmount, total),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context, Order order) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Order Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(item.productName),
                      ),
                      Text(
                        '\$${item.total.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTipSection(double subtotal) {
    return Column(
      children: [
        // Preset tip percentages
        Row(
          children: [
            Expanded(
              child: _buildTipButton('10%', 0.10, subtotal),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTipButton('15%', 0.15, subtotal),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTipButton('20%', 0.20, subtotal),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildTipButton('Custom', null, subtotal),
            ),
          ],
        ),
        if (_customTipAmount != null) ...[
          const SizedBox(height: 12),
          TextField(
            decoration: InputDecoration(
              labelText: 'Custom Tip Amount',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              setState(() {
                _customTipAmount = double.tryParse(value) ?? 0;
              });
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTipButton(String label, double? percent, double subtotal) {
    final isSelected = percent != null
        ? (_tipPercent == percent && _customTipAmount == null)
        : _customTipAmount != null;

    return OutlinedButton(
      onPressed: () {
        setState(() {
          if (percent != null) {
            _tipPercent = percent;
            _customTipAmount = null;
          } else {
            _customTipAmount = 0;
            _tipPercent = 0;
          }
        });
      },
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : null,
        foregroundColor: isSelected
            ? Theme.of(context).colorScheme.primary
            : null,
        side: BorderSide(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (percent != null)
            Text(
              '\$${(subtotal * percent).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      children: [
        _buildPaymentMethodTile(
          PaymentMethod.cash,
          'Cash',
          Icons.money,
          Colors.green,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodTile(
          PaymentMethod.card,
          'Card',
          Icons.credit_card,
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodTile(
          PaymentMethod.digital,
          'Digital Wallet',
          Icons.phone_android,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildPaymentMethodTile(
    PaymentMethod method,
    String label,
    IconData icon,
    Color color,
  ) {
    final isSelected = _selectedPaymentMethod == method;

    return InkWell(
      onTap: () {
        setState(() => _selectedPaymentMethod = method);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.05)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalBreakdown(Order order, double tipAmount, double total) {
    final theme = Theme.of(context);

    return Card(
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Subtotal', order.subtotal),
            const SizedBox(height: 8),
            _buildTotalRow('Tax', order.taxAmount),
            if (order.discountAmount > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow('Discount', -order.discountAmount, isDiscount: true),
            ],
            if (tipAmount > 0) ...[
              const SizedBox(height: 8),
              _buildTotalRow('Tip', tipAmount),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, double amount, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '${isDiscount ? '-' : ''}\$${amount.abs().toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDiscount ? Colors.green : null,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton(
    BuildContext context,
    Order order,
    double tipAmount,
    double total,
  ) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: FilledButton(
          onPressed: _isProcessing ? null : () => _processPayment(context, order, tipAmount, total),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle),
                    const SizedBox(width: 8),
                    Text(
                      'Complete Payment - \$${total.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    Order order,
    double tipAmount,
    double total,
  ) async {
    setState(() => _isProcessing = true);

    try {
      // Simulate payment processing
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Text('Payment successful - \$${total.toStringAsFixed(2)}'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to floor plan
      context.go('/');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

enum PaymentMethod {
  cash,
  card,
  digital,
}
