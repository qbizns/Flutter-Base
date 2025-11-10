import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cart/providers/cart_provider.dart';

/// Order Type
enum OrderType {
  dineIn('Dine In', Icons.restaurant),
  takeaway('Takeaway', Icons.shopping_bag),
  delivery('Delivery', Icons.delivery_dining);

  final String label;
  final IconData icon;

  const OrderType(this.label, this.icon);
}

/// Checkout Page
///
/// Features:
/// - Order type selection
/// - Delivery address (if delivery)
/// - Payment method selection
/// - Special instructions
/// - Order summary
/// - Place order
class CheckoutPage extends ConsumerStatefulWidget {
  const CheckoutPage({super.key});

  @override
  ConsumerState<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends ConsumerState<CheckoutPage> {
  OrderType _selectedOrderType = OrderType.delivery;
  String? _selectedAddress;
  String? _selectedPaymentMethod;
  final _notesController = TextEditingController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartProvider);

    if (cart.items.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/menu');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Order type selection
                _buildSection(
                  context,
                  title: 'Order Type',
                  child: _buildOrderTypeSelector(theme),
                ),

                const SizedBox(height: 24),

                // Delivery address (if delivery)
                if (_selectedOrderType == OrderType.delivery) ...[
                  _buildSection(
                    context,
                    title: 'Delivery Address',
                    child: _buildAddressSelector(theme),
                  ),
                  const SizedBox(height: 24),
                ],

                // Payment method
                _buildSection(
                  context,
                  title: 'Payment Method',
                  child: _buildPaymentMethodSelector(theme),
                ),

                const SizedBox(height: 24),

                // Special instructions
                _buildSection(
                  context,
                  title: 'Special Instructions (Optional)',
                  child: TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Add any special requests or instructions...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Order summary
                _buildSection(
                  context,
                  title: 'Order Summary',
                  child: _buildOrderSummary(theme, cart),
                ),
              ],
            ),
          ),

          // Place order button
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: FilledButton(
                  onPressed: _isProcessing ? null : _placeOrder,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _isProcessing
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'Place Order - \$${cart.total.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildOrderTypeSelector(ThemeData theme) {
    return Row(
      children: OrderType.values.map((type) {
        final isSelected = _selectedOrderType == type;

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedOrderType = type;
                });
              },
              avatar: Icon(
                type.icon,
                color: isSelected
                    ? theme.colorScheme.onSecondaryContainer
                    : theme.colorScheme.onSurface,
                size: 20,
              ),
              label: SizedBox(
                width: double.infinity,
                child: Text(
                  type.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressSelector(ThemeData theme) {
    final addresses = [
      '123 Main St, Apt 4B, New York, NY 10001',
      '456 Oak Avenue, Brooklyn, NY 11201',
    ];

    return Column(
      children: [
        ...addresses.map((address) {
          final isSelected = _selectedAddress == address;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: RadioListTile<String>(
              value: address,
              groupValue: _selectedAddress,
              onChanged: (value) {
                setState(() {
                  _selectedAddress = value;
                });
              },
              title: Text(
                address,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              secondary: const Icon(Icons.location_on),
            ),
          );
        }),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Add address feature coming soon')),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Add New Address'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodSelector(ThemeData theme) {
    final methods = [
      {'id': 'card', 'label': 'Credit/Debit Card', 'icon': Icons.credit_card, 'subtitle': '**** **** **** 4242'},
      {'id': 'cash', 'label': 'Cash on Delivery', 'icon': Icons.money, 'subtitle': 'Pay when you receive'},
      {'id': 'wallet', 'label': 'Digital Wallet', 'icon': Icons.account_balance_wallet, 'subtitle': 'Apple Pay, Google Pay'},
    ];

    return Column(
      children: methods.map((method) {
        final isSelected = _selectedPaymentMethod == method['id'];

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: RadioListTile<String>(
            value: method['id'] as String,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value;
              });
            },
            title: Text(
              method['label'] as String,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(method['subtitle'] as String),
            secondary: Icon(method['icon'] as IconData),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary(ThemeData theme, cart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Items
            ...cart.items.map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}x ${item.product.name}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '\$${item.totalPrice.toStringAsFixed(2)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const Divider(height: 24),

            // Subtotal
            _buildSummaryRow(theme, 'Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 8),

            // Tax
            _buildSummaryRow(theme, 'Tax (8%)', '\$${cart.tax.toStringAsFixed(2)}'),
            const SizedBox(height: 8),

            // Delivery fee
            if (_selectedOrderType == OrderType.delivery)
              _buildSummaryRow(theme, 'Delivery Fee', '\$${cart.deliveryFee.toStringAsFixed(2)}'),

            const Divider(height: 24),

            // Total
            _buildSummaryRow(
              theme,
              'Total',
              '\$${cart.total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    ThemeData theme,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )
              : theme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: isTotal
              ? theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
        ),
      ],
    );
  }

  Future<void> _placeOrder() async {
    // Validate
    if (_selectedOrderType == OrderType.delivery && _selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate order processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Clear cart
    ref.read(cartProvider.notifier).clear();

    // Show success and navigate
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          Icons.check_circle,
          color: Theme.of(context).colorScheme.primary,
          size: 64,
        ),
        title: const Text('Order Placed Successfully!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Your order has been confirmed.'),
            const SizedBox(height: 8),
            Text(
              'Order #${DateTime.now().millisecondsSinceEpoch % 10000}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/orders');
            },
            child: const Text('Track Order'),
          ),
        ],
      ),
    );

    setState(() {
      _isProcessing = false;
    });
  }
}
