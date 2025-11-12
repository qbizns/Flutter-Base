/// Payment Screen Widget
/// Shows payment in progress
/// Following Odoo POS customer display patterns
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

import '../../../../data/models/customer_display_models.dart';

/// Payment Screen
/// Displays payment processing status
class PaymentScreen extends StatefulWidget {
  final PaymentProgress? payment;

  const PaymentScreen({
    super.key,
    this.payment,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _processingController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Processing animation
    _processingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _processingController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _processingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.payment == null) {
      return _buildNoPayment();
    }

    final payment = widget.payment!;

    return Container(
      color: VodoColors.backgroundPrimary,
      child: Center(
        child: _buildPaymentStatus(context, payment),
      ),
    );
  }

  Widget _buildNoPayment() {
    return Center(
      child: Text(
        'No payment in progress',
        style: TextStyle(
          fontSize: 32,
          color: VodoColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildPaymentStatus(BuildContext context, PaymentProgress payment) {
    switch (payment.status) {
      case PaymentStatus.pending:
      case PaymentStatus.processing:
        return _buildProcessingView(context, payment);

      case PaymentStatus.success:
        return _buildSuccessView(context, payment);

      case PaymentStatus.failed:
        return _buildFailedView(context, payment);

      case PaymentStatus.cancelled:
        return _buildCancelledView(context, payment);
    }
  }

  Widget _buildProcessingView(BuildContext context, PaymentProgress payment) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated processing indicator
        ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            padding: const EdgeInsets.all(64),
            decoration: BoxDecoration(
              color: VodoColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: VodoColors.primary,
                width: 4,
              ),
            ),
            child: Icon(
              payment.paymentMethod.icon,
              size: 120,
              color: VodoColors.primary,
            ),
          ),
        ),

        const SizedBox(height: 64),

        // Processing text
        Text(
          'Processing Payment',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: VodoColors.primary,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 24),

        // Payment method
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
          decoration: BoxDecoration(
            color: VodoColors.backgroundSecondary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            payment.paymentMethod.displayName,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w600,
              color: VodoColors.textSecondary,
            ),
          ),
        ),

        const SizedBox(height: 48),

        // Amount
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: VodoColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: VodoColors.primary,
              width: 3,
            ),
          ),
          child: Column(
            children: [
              Text(
                'Amount',
                style: TextStyle(
                  fontSize: 24,
                  color: VodoColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                NumberFormat.currency(symbol: '\$').format(payment.amount),
                style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.w900,
                  color: VodoColors.primary,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 48),

        // Loading indicator
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            strokeWidth: 8,
            valueColor: AlwaysStoppedAnimation<Color>(VodoColors.primary),
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Please wait...',
          style: TextStyle(
            fontSize: 28,
            color: VodoColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessView(BuildContext context, PaymentProgress payment) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success icon
        Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: VodoColors.success.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 160,
            color: VodoColors.success,
          ),
        ),

        const SizedBox(height: 48),

        // Success message
        Text(
          'Payment Successful!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: VodoColors.success,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 24),

        // Amount
        Text(
          NumberFormat.currency(symbol: '\$').format(payment.amount),
          style: TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: VodoColors.textPrimary,
          ),
        ),

        const SizedBox(height: 32),

        // Transaction ID (if available)
        if (payment.transactionId != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            decoration: BoxDecoration(
              color: VodoColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt,
                  size: 24,
                  color: VodoColors.textSecondary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Transaction: ${payment.transactionId}',
                  style: TextStyle(
                    fontSize: 20,
                    color: VodoColors.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFailedView(BuildContext context, PaymentProgress payment) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Error icon
        Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: VodoColors.danger.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.error,
            size: 160,
            color: VodoColors.danger,
          ),
        ),

        const SizedBox(height: 48),

        // Error message
        Text(
          'Payment Failed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: VodoColors.danger,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 24),

        // Error details
        if (payment.errorMessage != null)
          Container(
            constraints: const BoxConstraints(maxWidth: 600),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: VodoColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: VodoColors.danger.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Text(
              payment.errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                color: VodoColors.danger,
              ),
            ),
          ),

        const SizedBox(height: 48),

        Text(
          'Please try again or use a different payment method',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            color: VodoColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCancelledView(BuildContext context, PaymentProgress payment) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cancel icon
        Container(
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: VodoColors.warning.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.cancel,
            size: 160,
            color: VodoColors.warning,
          ),
        ),

        const SizedBox(height: 48),

        // Cancelled message
        Text(
          'Payment Cancelled',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: VodoColors.warning,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Returning to cart...',
          style: TextStyle(
            fontSize: 32,
            color: VodoColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}
