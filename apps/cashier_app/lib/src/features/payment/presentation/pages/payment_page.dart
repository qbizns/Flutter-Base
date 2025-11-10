import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import '../../../transactions/domain/models/transaction.dart';

/// Payment Processing Page
///
/// Features:
/// - Payment method selection
/// - Tip calculation
/// - Cash handling with change calculation
/// - Card processing
/// - Receipt generation
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({
    required this.order,
    super.key,
  });

  final Order order;

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  PaymentMethod _selectedPaymentMethod = PaymentMethod.cash;
  double _tipAmount = 0.0;
  final _cashTenderedController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _cashTenderedController.dispose();
    super.dispose();
  }

  double get _orderTotal => widget.order.total;
  double get _totalWithTip => _orderTotal + _tipAmount;
  double get _cashTendered => double.tryParse(_cashTenderedController.text) ?? 0.0;
  double get _change => _cashTendered - _totalWithTip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Payment - Order #${widget.order.orderNumber}'),
      ),
      body: Row(
        children: [
          // Left: Payment details
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Payment method selection
                  _buildPaymentMethodSection(theme),

                  const SizedBox(height: 24),

                  // Tip section
                  _buildTipSection(theme),

                  const SizedBox(height: 24),

                  // Cash handling (if cash selected)
                  if (_selectedPaymentMethod == PaymentMethod.cash)
                    _buildCashSection(theme),

                  // Card processing (if card selected)
                  if (_selectedPaymentMethod == PaymentMethod.card)
                    _buildCardSection(theme),

                  // Digital wallet (if selected)
                  if (_selectedPaymentMethod == PaymentMethod.digitalWallet)
                    _buildDigitalWalletSection(theme),
                ],
              ),
            ),
          ),

          // Right: Order summary
          SizedBox(
            width: 400,
            child: _buildOrderSummary(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Method',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PaymentMethod.values.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedPaymentMethod = method;
                      _cashTenderedController.clear();
                    });
                  },
                  avatar: Icon(
                    _getPaymentIcon(method),
                    size: 20,
                  ),
                  label: Text(method.label),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipSection(ThemeData theme) {
    final tipOptions = [0.0, 0.10, 0.15, 0.18, 0.20];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Add Tip',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_tipAmount > 0)
                  Text(
                    '\$${_tipAmount.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: tipOptions.map((percentage) {
                final tipAmount = _orderTotal * percentage;
                final isSelected = (_tipAmount - tipAmount).abs() < 0.01;

                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _tipAmount = selected ? tipAmount : 0.0;
                    });
                  },
                  label: Text(
                    percentage == 0
                        ? 'No Tip'
                        : '${(percentage * 100).toInt()}% (\$${tipAmount.toStringAsFixed(2)})',
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Custom Tip Amount',
                prefixText: '\$',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (value) {
                setState(() {
                  _tipAmount = double.tryParse(value) ?? 0.0;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cash Payment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _cashTenderedController,
              decoration: const InputDecoration(
                labelText: 'Cash Tendered',
                prefixText: '\$',
                border: OutlineInputBorder(),
                helperText: 'Amount received from customer',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              onChanged: (_) {
                setState(() {});
              },
              autofocus: true,
            ),
            const SizedBox(height: 16),
            // Quick amount buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [20, 50, 100].map((amount) {
                return OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _cashTenderedController.text = amount.toString();
                    });
                  },
                  child: Text('\$$amount'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            // Change display
            if (_cashTendered > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _change >= 0
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _change >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Change Due',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_change >= 0 ? _change.toStringAsFixed(2) : '0.00'}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _change >= 0 ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Card Payment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Insert, Tap, or Swipe Card',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Waiting for card terminal...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDigitalWalletSection(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Digital Wallet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.phone_android,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap Phone on Terminal',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Apple Pay or Google Pay',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Text(
              'Order Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.order.items.length,
              itemBuilder: (context, index) {
                final item = widget.order.items[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(
                        '${item.quantity}x',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.productName)),
                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              children: [
                _buildSummaryRow('Subtotal', widget.order.subtotal),
                const SizedBox(height: 8),
                _buildSummaryRow('Tax', widget.order.tax),
                if (_tipAmount > 0) ...[
                  const SizedBox(height: 8),
                  _buildSummaryRow('Tip', _tipAmount),
                ],
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '\$${_totalWithTip.toStringAsFixed(2)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: _canProcessPayment() ? _processPayment : null,
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_isProcessing ? 'Processing...' : 'Complete Payment'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          '\$${amount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  bool _canProcessPayment() {
    if (_isProcessing) return false;

    switch (_selectedPaymentMethod) {
      case PaymentMethod.cash:
        return _cashTendered >= _totalWithTip;
      case PaymentMethod.card:
      case PaymentMethod.digitalWallet:
      case PaymentMethod.giftCard:
        return true;
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Show success and print receipt
    _showPaymentSuccessDialog();

    setState(() {
      _isProcessing = false;
    });
  }

  void _showPaymentSuccessDialog() {
    final receiptNumber = DateTime.now().millisecondsSinceEpoch % 100000;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 64,
        ),
        title: const Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Receipt #$receiptNumber'),
            const SizedBox(height: 16),
            if (_selectedPaymentMethod == PaymentMethod.cash && _change > 0)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Change Due',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${_change.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing receipt...')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Receipt'),
          ),
          FilledButton(
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

  IconData _getPaymentIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.digitalWallet:
        return Icons.phone_android;
      case PaymentMethod.giftCard:
        return Icons.card_giftcard;
    }
  }
}
