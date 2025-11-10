import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

/// Checkout Page - Self-service payment
///
/// Features:
/// - Payment method selection (card, cash, mobile pay)
/// - Large payment buttons
/// - Order summary
/// - Payment processing simulation
/// - Navigate to order tracking
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  PaymentMethod? _selectedPaymentMethod;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: _isProcessing ? null : () => context.go('/cart'),
          tooltip: 'Back to Cart',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Order summary
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order Summary',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSummaryRow(
                      context,
                      '${cart.items.length} items',
                      '\$${cart.subtotal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      context,
                      'Tax',
                      '\$${cart.taxAmount.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 32),
                    _buildSummaryRow(
                      context,
                      'Total',
                      '\$${cart.total.toStringAsFixed(2)}',
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Payment method selection
            Text(
              'Select Payment Method',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Payment method buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.2,
                children: [
                  _buildPaymentMethodCard(
                    context,
                    PaymentMethod.card,
                    Icons.credit_card,
                    'Credit/Debit Card',
                    'Tap or insert your card',
                  ),
                  _buildPaymentMethodCard(
                    context,
                    PaymentMethod.cash,
                    Icons.money,
                    'Cash',
                    'Pay at counter',
                  ),
                  _buildPaymentMethodCard(
                    context,
                    PaymentMethod.mobilePay,
                    Icons.phone_android,
                    'Mobile Pay',
                    'Apple Pay, Google Pay',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Pay button
            SizedBox(
              height: 80,
              child: FilledButton(
                onPressed: _selectedPaymentMethod == null || _isProcessing
                    ? null
                    : _processPayment,
                style: FilledButton.styleFrom(
                  textStyle: theme.textTheme.displaySmall,
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                          SizedBox(width: 16),
                          Text('Processing...'),
                        ],
                      )
                    : Text('Pay \$${cart.total.toStringAsFixed(2)}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    BuildContext context,
    PaymentMethod method,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedPaymentMethod == method;

    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: _isProcessing
            ? null
            : () {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer
                      : null,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: isSelected
                      ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 12),
                Icon(
                  Icons.check_circle,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    final theme = Theme.of(context);
    final style = isTotal
        ? theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          )
        : theme.textTheme.titleLarge;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(
          value,
          style: style?.copyWith(
            color: isTotal ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == null) return;

    setState(() {
      _isProcessing = true;
    });

    final cart = ref.read(cartNotifierProvider);

    // Create order
    final order = Order(
      id: '',
      orderNumber: '',
      status: OrderStatus.preparing,
      orderType: OrderType.takeaway,
      items: cart.items,
      createdAt: DateTime.now(),
      subtotal: cart.subtotal,
      taxAmount: cart.taxAmount,
      total: cart.total,
      paymentStatus: PaymentStatus.pending,
    );

    // Submit order
    final orderResult = await ref.read(createOrderUseCaseProvider)(order);

    await orderResult.when(
      success: (createdOrder) async {
        // Process payment
        final payment = Payment(
          id: '',
          orderId: createdOrder.id,
          amount: cart.total,
          method: _selectedPaymentMethod!,
          status: PaymentStatus.completed,
          createdAt: DateTime.now(),
        );

        final paymentResult =
            await ref.read(processPaymentUseCaseProvider)(payment);

        await paymentResult.when(
          success: (_) {
            if (mounted) {
              // Clear cart
              ref.read(cartNotifierProvider.notifier).clear();

              // Navigate to order tracking
              context.go('/order-tracking/${createdOrder.orderNumber}');
            }
          },
          failure: (error) {
            if (mounted) {
              _showError('Payment failed: ${error.message}');
              setState(() {
                _isProcessing = false;
              });
            }
          },
        );
      },
      failure: (error) {
        if (mounted) {
          _showError('Order failed: ${error.message}');
          setState(() {
            _isProcessing = false;
          });
        }
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
