import 'package:flutter/material.dart';

/// Numeric keypad widget for entering payment amounts.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    required this.onNumberTap,
    this.onClear,
    this.onBackspace,
    this.onDecimalTap,
    this.showDecimal = true,
    super.key,
  });

  final void Function(String) onNumberTap;
  final VoidCallback? onClear;
  final VoidCallback? onBackspace;
  final VoidCallback? onDecimalTap;
  final bool showDecimal;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      childAspectRatio: 1.5,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      padding: const EdgeInsets.all(16),
      children: [
        _buildNumberButton(context, '1'),
        _buildNumberButton(context, '2'),
        _buildNumberButton(context, '3'),
        _buildNumberButton(context, '4'),
        _buildNumberButton(context, '5'),
        _buildNumberButton(context, '6'),
        _buildNumberButton(context, '7'),
        _buildNumberButton(context, '8'),
        _buildNumberButton(context, '9'),
        if (showDecimal && onDecimalTap != null)
          _buildActionButton(
            context,
            '.',
            onDecimalTap!,
            icon: null,
          )
        else
          _buildActionButton(
            context,
            'C',
            onClear ?? () {},
            icon: Icons.clear,
          ),
        _buildNumberButton(context, '0'),
        _buildActionButton(
          context,
          '⌫',
          onBackspace ?? () {},
          icon: Icons.backspace_outlined,
        ),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, String number) {
    return FilledButton(
      onPressed: () => onNumberTap(number),
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(
        number,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    IconData? icon,
  }) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: icon != null
          ? Icon(icon, size: 24)
          : Text(
              label,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
    );
  }
}

/// Amount display with numeric keypad for entering payment amounts.
class AmountInput extends StatefulWidget {
  const AmountInput({
    required this.onAmountChanged,
    this.initialAmount = 0,
    this.label = 'Amount',
    super.key,
  });

  final void Function(double) onAmountChanged;
  final double initialAmount;
  final String label;

  @override
  State<AmountInput> createState() => _AmountInputState();
}

class _AmountInputState extends State<AmountInput> {
  late String _displayValue;

  @override
  void initState() {
    super.initState();
    _displayValue = widget.initialAmount > 0 ? widget.initialAmount.toStringAsFixed(2) : '0.00';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Amount Display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                widget.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\$$_displayValue',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Keypad
        NumericKeypad(
          onNumberTap: _handleNumberTap,
          onDecimalTap: _handleDecimalTap,
          onBackspace: _handleBackspace,
          onClear: _handleClear,
        ),
      ],
    );
  }

  void _handleNumberTap(String number) {
    setState(() {
      if (_displayValue == '0.00' || _displayValue == '0') {
        _displayValue = number;
      } else {
        _displayValue += number;
      }
      _updateAmount();
    });
  }

  void _handleDecimalTap() {
    if (!_displayValue.contains('.')) {
      setState(() {
        _displayValue += '.';
      });
    }
  }

  void _handleBackspace() {
    setState(() {
      if (_displayValue.length > 1) {
        _displayValue = _displayValue.substring(0, _displayValue.length - 1);
      } else {
        _displayValue = '0';
      }
      _updateAmount();
    });
  }

  void _handleClear() {
    setState(() {
      _displayValue = '0.00';
      _updateAmount();
    });
  }

  void _updateAmount() {
    final amount = double.tryParse(_displayValue) ?? 0.0;
    widget.onAmountChanged(amount);
  }
}
