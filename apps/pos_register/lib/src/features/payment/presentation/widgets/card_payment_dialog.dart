/// Card Payment Dialog
/// Processes card payments via Device Bridge payment terminal
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

import '../../../data/providers/hardware_providers.dart';

/// Card Payment Dialog
/// Handles card payment processing with payment terminal
class CardPaymentDialog extends ConsumerStatefulWidget {
  const CardPaymentDialog({
    super.key,
    required this.totalAmount,
  });

  final double totalAmount;

  @override
  ConsumerState<CardPaymentDialog> createState() => _CardPaymentDialogState();

  static Future<double?> show(
    BuildContext context, {
    required double totalAmount,
  }) {
    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CardPaymentDialog(totalAmount: totalAmount),
    );
  }
}

class _CardPaymentDialogState extends ConsumerState<CardPaymentDialog> {
  PaymentStatus _status = PaymentStatus.waiting;
  String _statusMessage = 'Insert, tap, or swipe card...';
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _processCardPayment();
  }

  Future<void> _processCardPayment() async {
    setState(() {
      _isProcessing = true;
      _status = PaymentStatus.processing;
      _statusMessage = 'Processing payment...';
    });

    try {
      final hardware = ref.read(hardwareServiceProvider);

      // Process card payment through Device Bridge
      final result = await hardware.processCardPayment(
        amount: widget.totalAmount,
        currency: 'USD',
      );

      result.when(
        success: (transactionId) {
          if (mounted) {
            setState(() {
              _status = PaymentStatus.approved;
              _statusMessage = 'Payment approved';
            });

            // Auto-close after short delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).pop(widget.totalAmount);
              }
            });
          }
        },
        failure: (failure) {
          if (mounted) {
            setState(() {
              _status = PaymentStatus.declined;
              _statusMessage = failure.message;
              _isProcessing = false;
            });
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _status = PaymentStatus.error;
          _statusMessage = 'Payment failed: $e';
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status icon
            _buildStatusIcon(),
            const SizedBox(height: 24),

            // Amount
            Text(
              '\$${widget.totalAmount.toStringAsFixed(2)}',
              style: VodoTextStyles.display.copyWith(
                color: VodoColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Status message
            Text(
              _statusMessage,
              style: VodoTextStyles.bodyLarge.copyWith(
                color: _getStatusColor(),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Action buttons
            if (!_isProcessing && _status != PaymentStatus.approved)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  if (_status == PaymentStatus.declined ||
                      _status == PaymentStatus.error) ...[
                    const SizedBox(width: 16),
                    FilledButton(
                      onPressed: _processCardPayment,
                      child: const Text('Try Again'),
                    ),
                  ],
                ],
              ),

            // Processing indicator
            if (_isProcessing) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Please wait...',
                style: VodoTextStyles.bodySmall.copyWith(
                  color: VodoColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    IconData icon;
    Color color;

    switch (_status) {
      case PaymentStatus.waiting:
        icon = Icons.credit_card;
        color = VodoColors.primary;
        break;
      case PaymentStatus.processing:
        icon = Icons.sync;
        color = VodoColors.warning;
        break;
      case PaymentStatus.approved:
        icon = Icons.check_circle;
        color = VodoColors.success;
        break;
      case PaymentStatus.declined:
        icon = Icons.error;
        color = VodoColors.danger;
        break;
      case PaymentStatus.error:
        icon = Icons.warning;
        color = VodoColors.danger;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: 64,
        color: color,
      ),
    );
  }

  Color _getStatusColor() {
    switch (_status) {
      case PaymentStatus.waiting:
        return VodoColors.textPrimary;
      case PaymentStatus.processing:
        return VodoColors.warning;
      case PaymentStatus.approved:
        return VodoColors.success;
      case PaymentStatus.declined:
      case PaymentStatus.error:
        return VodoColors.danger;
    }
  }
}

enum PaymentStatus {
  waiting,
  processing,
  approved,
  declined,
  error,
}
