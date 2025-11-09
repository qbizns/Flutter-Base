import 'package:flutter/material.dart';

/// Widget for selecting tip amount.
///
/// Supports preset percentages and custom amount entry.
class TipSelector extends StatefulWidget {
  const TipSelector({
    required this.subtotal,
    required this.onTipChanged,
    this.presetPercentages = const [10, 15, 18, 20],
    this.initialTip = 0,
    super.key,
  });

  final double subtotal;
  final void Function(double) onTipChanged;
  final List<int> presetPercentages;
  final double initialTip;

  @override
  State<TipSelector> createState() => _TipSelectorState();
}

class _TipSelectorState extends State<TipSelector> {
  late double _tipAmount;
  int? _selectedPercentage;
  bool _customAmount = false;

  @override
  void initState() {
    super.initState();
    _tipAmount = widget.initialTip;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add Tip',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),

        // Preset Percentages
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...widget.presetPercentages.map(
              (percentage) => _buildPercentageChip(theme, percentage),
            ),
            _buildCustomChip(theme),
            _buildNoTipChip(theme),
          ],
        ),

        if (_customAmount) ...[
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              labelText: 'Custom Tip Amount',
              prefixText: '\$',
              border: const OutlineRectangleBorder(),
              filled: true,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0.0;
              setState(() {
                _tipAmount = amount;
                _selectedPercentage = null;
              });
              widget.onTipChanged(amount);
            },
          ),
        ],

        const SizedBox(height: 16),

        // Tip Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tip Amount',
                style: theme.textTheme.titleMedium,
              ),
              Text(
                '\$${_tipAmount.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPercentageChip(ThemeData theme, int percentage) {
    final isSelected = _selectedPercentage == percentage && !_customAmount;
    final amount = widget.subtotal * (percentage / 100);

    return ChoiceChip(
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$percentage%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.colorScheme.onPrimaryContainer : null,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimaryContainer.withOpacity(0.8)
                  : theme.colorScheme.outline,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPercentage = percentage;
          _customAmount = false;
          _tipAmount = amount;
        });
        widget.onTipChanged(amount);
      },
    );
  }

  Widget _buildCustomChip(ThemeData theme) {
    return ChoiceChip(
      label: const Text('Custom'),
      avatar: const Icon(Icons.edit, size: 18),
      selected: _customAmount,
      onSelected: (selected) {
        setState(() {
          _customAmount = true;
          _selectedPercentage = null;
        });
      },
    );
  }

  Widget _buildNoTipChip(ThemeData theme) {
    final isSelected = _tipAmount == 0 && !_customAmount;

    return ChoiceChip(
      label: const Text('No Tip'),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPercentage = null;
          _customAmount = false;
          _tipAmount = 0;
        });
        widget.onTipChanged(0);
      },
    );
  }
}
