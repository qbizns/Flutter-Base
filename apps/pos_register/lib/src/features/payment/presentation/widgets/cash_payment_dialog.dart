/// Cash Payment Dialog Widget
/// Vodo-style cash payment with numpad and change calculation (Odoo-inspired)
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Cash payment dialog following Odoo POS patterns
class CashPaymentDialog extends StatefulWidget {
  final double totalAmount;
  final VoidCallback? onConfirm;

  const CashPaymentDialog({
    super.key,
    required this.totalAmount,
    this.onConfirm,
  });

  /// Show cash payment dialog
  static Future<double?> show(
    BuildContext context, {
    required double totalAmount,
  }) {
    return showDialog<double>(
      context: context,
      barrierDismissible: false,
      builder: (context) => CashPaymentDialog(totalAmount: totalAmount),
    );
  }

  @override
  State<CashPaymentDialog> createState() => _CashPaymentDialogState();
}

class _CashPaymentDialogState extends State<CashPaymentDialog> {
  double _receivedAmount = 0.0;
  String _displayText = '0';
  bool _hasDecimal = false;
  int _decimalPlaces = 0;

  double get _changeAmount => _receivedAmount - widget.totalAmount;
  bool get _isValid => _receivedAmount >= widget.totalAmount;

  @override
  void initState() {
    super.initState();
    // Pre-fill with exact amount
    _receivedAmount = widget.totalAmount;
    _displayText = widget.totalAmount.toStringAsFixed(2);
    _hasDecimal = true;
    _decimalPlaces = 2;
  }

  void _handleNumberPressed(String number) {
    setState(() {
      if (_displayText == '0') {
        _displayText = number;
      } else {
        if (_hasDecimal) {
          if (_decimalPlaces < 2) {
            _displayText += number;
            _decimalPlaces++;
          }
        } else {
          _displayText += number;
        }
      }
      _receivedAmount = double.tryParse(_displayText) ?? 0.0;
    });
  }

  void _handleDecimalPressed() {
    if (!_hasDecimal) {
      setState(() {
        _displayText += '.';
        _hasDecimal = true;
        _decimalPlaces = 0;
      });
    }
  }

  void _handleClearPressed() {
    setState(() {
      _displayText = '0';
      _receivedAmount = 0.0;
      _hasDecimal = false;
      _decimalPlaces = 0;
    });
  }

  void _handleBackspacePressed() {
    if (_displayText.length > 1) {
      setState(() {
        final lastChar = _displayText[_displayText.length - 1];
        if (lastChar == '.') {
          _hasDecimal = false;
        } else if (_hasDecimal) {
          _decimalPlaces--;
        }
        _displayText = _displayText.substring(0, _displayText.length - 1);
        _receivedAmount = double.tryParse(_displayText) ?? 0.0;
      });
    } else {
      _handleClearPressed();
    }
  }

  void _handleQuickAmount(double amount) {
    setState(() {
      _receivedAmount = amount;
      _displayText = amount.toStringAsFixed(2);
      _hasDecimal = true;
      _decimalPlaces = 2;
    });
  }

  void _handleConfirm() {
    if (_isValid) {
      Navigator.of(context).pop(_receivedAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: VodoDimensions.paddingLg,
              decoration: const BoxDecoration(
                color: VodoColors.success,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(VodoDimensions.radiusMd),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.attach_money,
                    color: VodoColors.textOnPrimary,
                    size: 28,
                  ),
                  const SizedBox(width: VodoDimensions.spacingSm),
                  Expanded(
                    child: Text(
                      'Cash Payment',
                      style: VodoTextStyles.titleLarge.copyWith(
                        color: VodoColors.textOnPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close,
                      color: VodoColors.textOnPrimary,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: VodoDimensions.paddingLg,
              child: Column(
                children: [
                  // Amount due
                  Container(
                    padding: VodoDimensions.paddingMd,
                    decoration: BoxDecoration(
                      color: VodoColors.backgroundSecondary,
                      borderRadius: VodoDimensions.borderRadiusMd,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Amount Due',
                          style: VodoTextStyles.bodyLarge.copyWith(
                            color: VodoColors.textSecondary,
                          ),
                        ),
                        Text(
                          '\$${widget.totalAmount.toStringAsFixed(2)}',
                          style: VodoTextStyles.price.copyWith(
                            color: VodoColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingLg),

                  // Received amount display
                  Container(
                    padding: VodoDimensions.paddingLg,
                    decoration: BoxDecoration(
                      color: _isValid
                          ? VodoColors.success.withOpacity(0.1)
                          : VodoColors.danger.withOpacity(0.1),
                      borderRadius: VodoDimensions.borderRadiusMd,
                      border: Border.all(
                        color: _isValid ? VodoColors.success : VodoColors.danger,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Received',
                          style: VodoTextStyles.labelMedium.copyWith(
                            color: VodoColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$$_displayText',
                          style: VodoTextStyles.display.copyWith(
                            fontSize: 48,
                            color: _isValid ? VodoColors.success : VodoColors.danger,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: VodoDimensions.spacingMd),

                  // Change amount (if valid)
                  if (_isValid)
                    Container(
                      padding: VodoDimensions.paddingMd,
                      decoration: BoxDecoration(
                        color: VodoColors.info.withOpacity(0.1),
                        borderRadius: VodoDimensions.borderRadiusMd,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.change_circle,
                                color: VodoColors.info,
                                size: 20,
                              ),
                              const SizedBox(width: VodoDimensions.spacingSm),
                              Text(
                                'Change',
                                style: VodoTextStyles.titleSmall.copyWith(
                                  color: VodoColors.info,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '\$${_changeAmount.toStringAsFixed(2)}',
                            style: VodoTextStyles.priceMedium.copyWith(
                              color: VodoColors.info,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: VodoDimensions.spacingLg),

                  // Quick amount buttons (Odoo-style)
                  Row(
                    children: [
                      _buildQuickAmountButton(widget.totalAmount, 'Exact'),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      _buildQuickAmountButton(10, '\$10'),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      _buildQuickAmountButton(20, '\$20'),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      _buildQuickAmountButton(50, '\$50'),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      _buildQuickAmountButton(100, '\$100'),
                    ],
                  ),

                  const SizedBox(height: VodoDimensions.spacingLg),

                  // Numpad (Odoo-style)
                  _buildNumpad(),

                  const SizedBox(height: VodoDimensions.spacingLg),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize:
                                const Size(0, VodoDimensions.buttonHeightLg),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: VodoDimensions.spacingMd),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _isValid ? _handleConfirm : null,
                          style: ElevatedButton.styleFrom(
                            minimumSize:
                                const Size(0, VodoDimensions.buttonHeightLg),
                            backgroundColor: VodoColors.success,
                            disabledBackgroundColor:
                                VodoColors.backgroundSecondary,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle),
                              const SizedBox(width: VodoDimensions.spacingSm),
                              Text(
                                'Confirm Payment',
                                style: VodoTextStyles.button,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount, String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _handleQuickAmount(amount),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
          side: BorderSide(
            color: _receivedAmount == amount
                ? VodoColors.success
                : VodoColors.border,
            width: _receivedAmount == amount ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: VodoTextStyles.labelSmall.copyWith(
            fontWeight: _receivedAmount == amount
                ? FontWeight.w700
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildNumpad() {
    return Column(
      children: [
        Row(
          children: [
            _buildNumButton('7'),
            const SizedBox(width: VodoDimensions.spacingSm),
            _buildNumButton('8'),
            const SizedBox(width: VodoDimensions.spacingSm),
            _buildNumButton('9'),
          ],
        ),
        const SizedBox(height: VodoDimensions.spacingSm),
        Row(
          children: [
            _buildNumButton('4'),
            const SizedBox(width: VodoDimensions.spacingSm),
            _buildNumButton('5'),
            const SizedBox(width: VodoDimensions.spacingSm),
            _buildNumButton('6'),
          ],
        ),
        const SizedBox(height: VodoDimensions.spacingSm),
        Row(
          children: [
            _buildNumButton('1'),
            const SizedBox(width: VodoDimensions.spacingSm),
            _buildNumButton('2'),
            const SizedBox(width: VodoDimensions.spacingSm),
            _buildNumButton('3'),
          ],
        ),
        const SizedBox(height: VodoDimensions.spacingSm),
        Row(
          children: [
            _buildActionButton(
              icon: Icons.backspace_outlined,
              onPressed: _handleBackspacePressed,
              color: VodoColors.warning,
            ),
            const SizedBox(width: VodoDimensions.spacingSm),
            _buildNumButton('0'),
            const SizedBox(width: VodoDimensions.spacingSm),
            _buildActionButton(
              label: '.',
              onPressed: _handleDecimalPressed,
              color: VodoColors.info,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNumButton(String number) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _handleNumberPressed(number),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 60),
          backgroundColor: VodoColors.backgroundPrimary,
          foregroundColor: VodoColors.textPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: VodoDimensions.borderRadiusMd,
            side: const BorderSide(color: VodoColors.border),
          ),
        ),
        child: Text(
          number,
          style: VodoTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    IconData? icon,
    String? label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, 60),
          backgroundColor: color.withOpacity(0.1),
          foregroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: VodoDimensions.borderRadiusMd,
            side: BorderSide(color: color),
          ),
        ),
        child: icon != null
            ? Icon(icon, size: 28)
            : Text(
                label!,
                style: VodoTextStyles.headlineMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
