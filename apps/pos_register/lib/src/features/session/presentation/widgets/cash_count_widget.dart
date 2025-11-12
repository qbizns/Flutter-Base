/// Cash Count Widget
/// Vodo-style widget for counting cash denominations
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos_core/pos_core.dart';
import '../../domain/models/cash_count.dart';

/// Cash counting widget with bill and coin counters
class CashCountWidget extends StatefulWidget {
  final CashCount cashCount;
  final ValueChanged<CashCount> onChanged;
  final bool enabled;

  const CashCountWidget({
    super.key,
    required this.cashCount,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<CashCountWidget> createState() => _CashCountWidgetState();
}

class _CashCountWidgetState extends State<CashCountWidget> {
  late CashCount _cashCount;

  @override
  void initState() {
    super.initState();
    _cashCount = widget.cashCount;
  }

  @override
  void didUpdateWidget(CashCountWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cashCount != oldWidget.cashCount) {
      _cashCount = widget.cashCount;
    }
  }

  void _updateDenomination(double value, int quantity) {
    final updated = _cashCount.updateDenomination(value, quantity);
    setState(() => _cashCount = updated);
    widget.onChanged(updated);
  }

  void _resetCount() {
    final reset = _cashCount.reset();
    setState(() => _cashCount = reset);
    widget.onChanged(reset);
  }

  @override
  Widget build(BuildContext context) {
    final bills = _cashCount.denominations
        .where((d) => d.type == DenominationType.bill)
        .toList();
    final coins = _cashCount.denominations
        .where((d) => d.type == DenominationType.coin)
        .toList();

    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
      ),
      child: Padding(
        padding: VodoDimensions.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with total
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cash Count',
                        style: VodoTextStyles.titleMedium,
                      ),
                      const SizedBox(height: VodoDimensions.spacingXs),
                      Text(
                        'Count your bills and coins',
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: VodoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Total',
                      style: VodoTextStyles.labelMedium.copyWith(
                        color: VodoColors.textSecondary,
                      ),
                    ),
                    Text(
                      '\$${_cashCount.totalAmount.toStringAsFixed(2)}',
                      style: VodoTextStyles.price.copyWith(
                        color: VodoColors.success,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: VodoDimensions.spacingLg),

            // Bills section
            Container(
              padding: VodoDimensions.paddingMd,
              decoration: BoxDecoration(
                color: VodoColors.backgroundSecondary,
                borderRadius: VodoDimensions.borderRadiusMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        size: VodoDimensions.iconSizeMd,
                        color: VodoColors.success,
                      ),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      Text(
                        'Bills',
                        style: VodoTextStyles.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: VodoDimensions.spacingMd),
                  ...bills.map((denom) {
                    return _DenominationRow(
                      denomination: denom,
                      onChanged: (qty) => _updateDenomination(denom.value, qty),
                      enabled: widget.enabled,
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: VodoDimensions.spacingMd),

            // Coins section
            Container(
              padding: VodoDimensions.paddingMd,
              decoration: BoxDecoration(
                color: VodoColors.backgroundSecondary,
                borderRadius: VodoDimensions.borderRadiusMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.monetization_on,
                        size: VodoDimensions.iconSizeMd,
                        color: VodoColors.warning,
                      ),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      Text(
                        'Coins',
                        style: VodoTextStyles.titleSmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: VodoDimensions.spacingMd),
                  ...coins.map((denom) {
                    return _DenominationRow(
                      denomination: denom,
                      onChanged: (qty) => _updateDenomination(denom.value, qty),
                      enabled: widget.enabled,
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: VodoDimensions.spacingMd),

            // Reset button
            if (widget.enabled)
              TextButton.icon(
                onPressed: _resetCount,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Count'),
                style: TextButton.styleFrom(
                  foregroundColor: VodoColors.danger,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Denomination row widget
class _DenominationRow extends StatefulWidget {
  final CashDenomination denomination;
  final ValueChanged<int> onChanged;
  final bool enabled;

  const _DenominationRow({
    required this.denomination,
    required this.onChanged,
    required this.enabled,
  });

  @override
  State<_DenominationRow> createState() => _DenominationRowState();
}

class _DenominationRowState extends State<_DenominationRow> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.denomination.quantity == 0
          ? ''
          : widget.denomination.quantity.toString(),
    );
  }

  @override
  void didUpdateWidget(_DenominationRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.denomination.quantity != oldWidget.denomination.quantity) {
      _controller.text = widget.denomination.quantity == 0
          ? ''
          : widget.denomination.quantity.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _increment() {
    final newQty = widget.denomination.quantity + 1;
    widget.onChanged(newQty);
  }

  void _decrement() {
    if (widget.denomination.quantity > 0) {
      final newQty = widget.denomination.quantity - 1;
      widget.onChanged(newQty);
    }
  }

  void _handleTextChange(String value) {
    final qty = int.tryParse(value) ?? 0;
    widget.onChanged(qty);
  }

  String _formatValue(double value) {
    if (value >= 1) {
      return '\$${value.toStringAsFixed(0)}';
    } else {
      return '\$${value.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: VodoDimensions.spacingSm),
      child: Row(
        children: [
          // Denomination value
          SizedBox(
            width: 70,
            child: Text(
              _formatValue(widget.denomination.value),
              style: VodoTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Decrement button
          IconButton(
            onPressed: widget.enabled &&
                    widget.denomination.quantity > 0
                ? _decrement
                : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: VodoColors.danger,
            iconSize: VodoDimensions.iconSizeMd,
          ),

          // Quantity input
          SizedBox(
            width: 80,
            child: TextFormField(
              controller: _controller,
              enabled: widget.enabled,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              decoration: const InputDecoration(
                hintText: '0',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: VodoDimensions.spacingSm,
                  vertical: VodoDimensions.spacingSm,
                ),
              ),
              style: VodoTextStyles.titleMedium,
              onChanged: _handleTextChange,
            ),
          ),

          // Increment button
          IconButton(
            onPressed: widget.enabled ? _increment : null,
            icon: const Icon(Icons.add_circle_outline),
            color: VodoColors.success,
            iconSize: VodoDimensions.iconSizeMd,
          ),

          const Spacer(),

          // Amount for this denomination
          Text(
            '\$${widget.denomination.amount.toStringAsFixed(2)}',
            style: VodoTextStyles.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.denomination.amount > 0
                  ? VodoColors.success
                  : VodoColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
