/// Payment Page
/// Vodo-style payment processing page following Odoo POS patterns
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import '../../../session/presentation/widgets/session_guard.dart';
import '../widgets/vodo_payment_grid.dart';
import '../widgets/cash_payment_dialog.dart';

/// Payment page for processing order payment
class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage> {
  final List<_PaymentLine> _paymentLines = [];
  bool _isProcessing = false;

  double get _totalPaid =>
      _paymentLines.fold(0.0, (sum, line) => sum + line.amount);
  double get _remainingAmount => _cart.total - _totalPaid;
  bool get _isFullyPaid => _remainingAmount <= 0.01;

  Cart get _cart => ref.watch(cartNotifierProvider);

  @override
  Widget build(BuildContext context) {
    if (_cart.isEmpty) {
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
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'Payment',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SessionGuard(
        requireOpenSession: true,
        child: Column(
          children: [
            // Payment summary header
            _buildPaymentSummary(),

            // Payment lines (if any)
            if (_paymentLines.isNotEmpty) _buildPaymentLines(),

            // Payment method grid or validation
            Expanded(
              child: SingleChildScrollView(
                padding: VodoDimensions.paddingLg,
                child: Column(
                  children: [
                    if (!_isFullyPaid)
                      ResponsiveVodoPaymentGrid(
                        methods: VodoPaymentMethod.all,
                        onMethodSelected: _handlePaymentMethodSelected,
                        totalAmount: _remainingAmount,
                      )
                    else
                      _buildPaymentComplete(),
                  ],
                ),
              ),
            ),

            // Action buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: VodoDimensions.paddingLg,
      decoration: BoxDecoration(
        color: VodoColors.backgroundPrimary,
        border: const Border(
          bottom: BorderSide(color: VodoColors.border, width: 2),
        ),
      ),
      child: Column(
        children: [
          // Order total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Total',
                style: VodoTextStyles.titleMedium.copyWith(
                  color: VodoColors.textSecondary,
                ),
              ),
              Text(
                '\$${_cart.total.toStringAsFixed(2)}',
                style: VodoTextStyles.price.copyWith(
                  color: VodoColors.textPrimary,
                ),
              ),
            ],
          ),

          if (_paymentLines.isNotEmpty) ...[
            const SizedBox(height: VodoDimensions.spacingMd),
            const Divider(),
            const SizedBox(height: VodoDimensions.spacingMd),

            // Amount paid
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Amount Paid',
                  style: VodoTextStyles.titleMedium.copyWith(
                    color: VodoColors.textSecondary,
                  ),
                ),
                Text(
                  '\$${_totalPaid.toStringAsFixed(2)}',
                  style: VodoTextStyles.priceMedium.copyWith(
                    color: VodoColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: VodoDimensions.spacingSm),

            // Remaining amount
            Container(
              padding: VodoDimensions.paddingMd,
              decoration: BoxDecoration(
                color: _isFullyPaid
                    ? VodoColors.success.withOpacity(0.1)
                    : VodoColors.warning.withOpacity(0.1),
                borderRadius: VodoDimensions.borderRadiusMd,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _isFullyPaid ? Icons.check_circle : Icons.pending,
                        color: _isFullyPaid
                            ? VodoColors.success
                            : VodoColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      Text(
                        _isFullyPaid ? 'Paid in Full' : 'Remaining',
                        style: VodoTextStyles.titleSmall.copyWith(
                          color: _isFullyPaid
                              ? VodoColors.success
                              : VodoColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (!_isFullyPaid)
                    Text(
                      '\$${_remainingAmount.toStringAsFixed(2)}',
                      style: VodoTextStyles.priceMedium.copyWith(
                        color: VodoColors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentLines() {
    return Container(
      margin: VodoDimensions.paddingMd,
      decoration: BoxDecoration(
        color: VodoColors.backgroundPrimary,
        borderRadius: VodoDimensions.borderRadiusMd,
        border: Border.all(color: VodoColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: VodoDimensions.paddingMd,
            child: Text(
              'Payment Methods',
              style: VodoTextStyles.titleSmall.copyWith(
                color: VodoColors.textSecondary,
              ),
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _paymentLines.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildPaymentLineItem(_paymentLines[index], index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentLineItem(_PaymentLine line, int index) {
    return ListTile(
      leading: Container(
        padding: VodoDimensions.paddingSm,
        decoration: BoxDecoration(
          color: line.method.color.withOpacity(0.1),
          borderRadius: VodoDimensions.borderRadiusSm,
        ),
        child: Icon(
          line.method.icon,
          color: line.method.color,
          size: 20,
        ),
      ),
      title: Text(
        line.method.name,
        style: VodoTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: line.reference != null
          ? Text(
              line.reference!,
              style: VodoTextStyles.bodySmall.copyWith(
                color: VodoColors.textSecondary,
              ),
            )
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '\$${line.amount.toStringAsFixed(2)}',
            style: VodoTextStyles.priceMedium.copyWith(
              color: line.method.color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: VodoDimensions.spacingSm),
          IconButton(
            onPressed: () => _removePaymentLine(index),
            icon: const Icon(Icons.close, size: 18),
            color: VodoColors.danger,
            tooltip: 'Remove payment',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentComplete() {
    return Container(
      padding: VodoDimensions.paddingXl,
      child: Column(
        children: [
          // Success icon
          Container(
            padding: VodoDimensions.paddingXl,
            decoration: BoxDecoration(
              color: VodoColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: VodoColors.success,
            ),
          ),

          const SizedBox(height: VodoDimensions.spacingXl),

          Text(
            'Payment Complete',
            style: VodoTextStyles.headlineMedium.copyWith(
              color: VodoColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: VodoDimensions.spacingSm),

          Text(
            'Ready to complete the order',
            style: VodoTextStyles.bodyLarge.copyWith(
              color: VodoColors.textSecondary,
            ),
          ),

          const SizedBox(height: VodoDimensions.spacingXl),

          // Change amount (if any)
          if (_totalPaid > _cart.total)
            Container(
              padding: VodoDimensions.paddingLg,
              decoration: BoxDecoration(
                color: VodoColors.info.withOpacity(0.1),
                borderRadius: VodoDimensions.borderRadiusMd,
                border: Border.all(color: VodoColors.info),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.change_circle,
                        color: VodoColors.info,
                        size: 24,
                      ),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      Text(
                        'Change Due',
                        style: VodoTextStyles.titleMedium.copyWith(
                          color: VodoColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: VodoDimensions.spacingSm),
                  Text(
                    '\$${(_totalPaid - _cart.total).toStringAsFixed(2)}',
                    style: VodoTextStyles.display.copyWith(
                      color: VodoColors.info,
                      fontWeight: FontWeight.w700,
                      fontSize: 48,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: VodoDimensions.paddingLg,
      decoration: const BoxDecoration(
        color: VodoColors.backgroundPrimary,
        border: Border(
          top: BorderSide(color: VodoColors.border, width: 2),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: _isProcessing ? null : () => context.pop(),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
              ),
              child: const Text('Cancel'),
            ),
          ),

          const SizedBox(width: VodoDimensions.spacingMd),

          // Validate order button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isFullyPaid && !_isProcessing
                  ? _handleValidateOrder
                  : null,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, VodoDimensions.buttonHeightLg),
                backgroundColor: VodoColors.success,
                disabledBackgroundColor: VodoColors.backgroundSecondary,
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          VodoColors.textOnPrimary,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.check_circle),
                        const SizedBox(width: VodoDimensions.spacingSm),
                        Text(
                          'Validate Order',
                          style: VodoTextStyles.button.copyWith(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePaymentMethodSelected(VodoPaymentMethod method) async {
    double? amount;

    switch (method.id) {
      case 'cash':
        amount = await CashPaymentDialog.show(
          context,
          totalAmount: _remainingAmount,
        );
        break;

      case 'card':
        // TODO: Implement card payment with Device Bridge
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Card payment with Device Bridge coming in next commit'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;

      default:
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${method.name} payment coming soon'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return;
    }

    if (amount != null && amount > 0) {
      setState(() {
        _paymentLines.add(_PaymentLine(
          method: method,
          amount: amount,
          reference: method.id == 'cash' ? 'Cash payment' : null,
        ));
      });
    }
  }

  void _removePaymentLine(int index) {
    setState(() {
      _paymentLines.removeAt(index);
    });
  }

  Future<void> _handleValidateOrder() async {
    setState(() => _isProcessing = true);

    try {
      // TODO: Create order with payment information
      // This will be integrated with backend API

      await Future.delayed(const Duration(seconds: 1)); // Simulated API call

      if (!mounted) return;

      // Clear cart
      ref.read(cartNotifierProvider.notifier).clear();

      // Show success and navigate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order completed successfully!'),
          backgroundColor: VodoColors.success,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate back to POS
      context.go('/');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing order: $e'),
          backgroundColor: VodoColors.danger,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

/// Payment line model
class _PaymentLine {
  final VodoPaymentMethod method;
  final double amount;
  final String? reference;

  _PaymentLine({
    required this.method,
    required this.amount,
    this.reference,
  });
}
