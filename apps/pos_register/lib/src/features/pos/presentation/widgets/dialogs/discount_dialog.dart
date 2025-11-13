import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum DiscountType {
  percentage,
  fixed,
}

class DiscountResult {
  final DiscountType type;
  final double value;
  final String? reason;

  const DiscountResult({
    required this.type,
    required this.value,
    this.reason,
  });
}

/// Discount dialog for POS
class DiscountDialog extends StatefulWidget {
  const DiscountDialog({
    super.key,
    required this.orderTotal,
  });

  final double orderTotal;

  @override
  State<DiscountDialog> createState() => _DiscountDialogState();

  static Future<DiscountResult?> show(
    BuildContext context, {
    required double orderTotal,
  }) {
    return showDialog<DiscountResult>(
      context: context,
      builder: (context) => DiscountDialog(orderTotal: orderTotal),
    );
  }
}

class _DiscountDialogState extends State<DiscountDialog> {
  final _valueController = TextEditingController();
  final _reasonController = TextEditingController();
  DiscountType _selectedType = DiscountType.percentage;
  String? _errorText;

  @override
  void dispose() {
    _valueController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  bool _validateDiscount() {
    final value = double.tryParse(_valueController.text);

    if (value == null || value <= 0) {
      setState(() => _errorText = 'Please enter a valid discount value');
      return false;
    }

    if (_selectedType == DiscountType.percentage) {
      if (value > 100) {
        setState(() => _errorText = 'Percentage cannot exceed 100%');
        return false;
      }
    } else {
      if (value > widget.orderTotal) {
        setState(() => _errorText = 'Discount cannot exceed order total');
        return false;
      }
    }

    setState(() => _errorText = null);
    return true;
  }

  double _calculateDiscountAmount() {
    final value = double.tryParse(_valueController.text) ?? 0;
    if (_selectedType == DiscountType.percentage) {
      return widget.orderTotal * (value / 100);
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    final discountAmount = _calculateDiscountAmount();
    final newTotal = widget.orderTotal - discountAmount;

    return Dialog(
      child: Container(
        width: 450,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.discount, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Apply Discount',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Discount type selector
            const Text(
              'Discount Type',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            SegmentedButton<DiscountType>(
              segments: const [
                ButtonSegment(
                  value: DiscountType.percentage,
                  label: Text('Percentage'),
                  icon: Icon(Icons.percent),
                ),
                ButtonSegment(
                  value: DiscountType.fixed,
                  label: Text('Fixed Amount'),
                  icon: Icon(Icons.attach_money),
                ),
              ],
              selected: {_selectedType},
              onSelectionChanged: (Set<DiscountType> newSelection) {
                setState(() {
                  _selectedType = newSelection.first;
                  _valueController.clear();
                  _errorText = null;
                });
              },
            ),
            const SizedBox(height: 20),

            // Discount value input
            TextField(
              controller: _valueController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                labelText: _selectedType == DiscountType.percentage
                    ? 'Discount Percentage'
                    : 'Discount Amount',
                hintText: _selectedType == DiscountType.percentage ? '10' : '5.00',
                prefixText: _selectedType == DiscountType.fixed ? '\$ ' : null,
                suffixText: _selectedType == DiscountType.percentage ? '%' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                errorText: _errorText,
              ),
              onChanged: (_) {
                setState(() => _errorText = null);
              },
            ),
            const SizedBox(height: 16),

            // Reason input
            TextField(
              controller: _reasonController,
              decoration: InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'e.g., Manager approval, Loyalty reward',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Original Total:'),
                      Text(
                        '\$${widget.orderTotal.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount:'),
                      Text(
                        '-\$${discountAmount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'New Total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '\$${newTotal.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_validateDiscount()) {
                      final value = double.parse(_valueController.text);
                      Navigator.of(context).pop(
                        DiscountResult(
                          type: _selectedType,
                          value: value,
                          reason: _reasonController.text.isEmpty
                              ? null
                              : _reasonController.text,
                        ),
                      );
                    }
                  },
                  child: const Text('Apply Discount'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
