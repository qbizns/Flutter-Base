import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:intl/intl.dart';

/// Stock Adjustment Page - Manual stock corrections
///
/// Features:
/// - Add/remove stock for products
/// - Reason tracking (waste, damage, theft, count correction)
/// - Notes field for details
/// - Batch adjustments
/// - Adjustment history
class StockAdjustmentPage extends ConsumerStatefulWidget {
  const StockAdjustmentPage({
    this.productId,
    super.key,
  });

  final String? productId;

  @override
  ConsumerState<StockAdjustmentPage> createState() => _StockAdjustmentPageState();
}

class _StockAdjustmentPageState extends ConsumerState<StockAdjustmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _quantityController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedProductId;
  AdjustmentType _adjustmentType = AdjustmentType.add;
  AdjustmentReason _reason = AdjustmentReason.countCorrection;

  @override
  void initState() {
    super.initState();
    _selectedProductId = widget.productId;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Adjustment'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: productsAsync.when(
        data: (products) {
          final selectedProduct = _selectedProductId != null
              ? products.where((p) => p.id == _selectedProductId).firstOrNull
              : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions card
                  Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Adjust stock levels for manual corrections, waste, damage, or theft.',
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Product selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Product *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.inventory_2),
                    ),
                    value: _selectedProductId,
                    items: products.map((product) {
                      return DropdownMenuItem(
                        value: product.id,
                        child: Text(product.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProductId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a product';
                      }
                      return null;
                    },
                  ),

                  if (selectedProduct != null) ...[
                    const SizedBox(height: 16),

                    // Current stock display
                    Card(
                      elevation: 0,
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Current Stock Level',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                  Text(
                                    '${_getCurrentStock(selectedProduct)} units',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Value',
                                  style: theme.textTheme.bodySmall,
                                ),
                                Text(
                                  '\$${(_getCurrentStock(selectedProduct) * selectedProduct.price).toStringAsFixed(2)}',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Adjustment type
                  SegmentedButton<AdjustmentType>(
                    segments: const [
                      ButtonSegment(
                        value: AdjustmentType.add,
                        label: Text('Add Stock'),
                        icon: Icon(Icons.add),
                      ),
                      ButtonSegment(
                        value: AdjustmentType.remove,
                        label: Text('Remove Stock'),
                        icon: Icon(Icons.remove),
                      ),
                    ],
                    selected: {_adjustmentType},
                    onSelectionChanged: (Set<AdjustmentType> newSelection) {
                      setState(() {
                        _adjustmentType = newSelection.first;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Quantity
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Quantity *',
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        _adjustmentType == AdjustmentType.add
                            ? Icons.add_circle_outline
                            : Icons.remove_circle_outline,
                      ),
                      helperText: 'Enter the number of units to ${_adjustmentType == AdjustmentType.add ? 'add' : 'remove'}',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final quantity = int.tryParse(value);
                      if (quantity == null || quantity <= 0) {
                        return 'Please enter a valid positive number';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 24),

                  // Reason
                  DropdownButtonFormField<AdjustmentReason>(
                    decoration: const InputDecoration(
                      labelText: 'Reason *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    value: _reason,
                    items: AdjustmentReason.values.map((reason) {
                      return DropdownMenuItem(
                        value: reason,
                        child: Text(_getReasonLabel(reason)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _reason = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Notes
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note_outlined),
                      helperText: 'Add any additional details about this adjustment',
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),

                  // Preview card
                  if (selectedProduct != null && _quantityController.text.isNotEmpty) ...[
                    Card(
                      color: theme.colorScheme.tertiaryContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preview',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onTertiaryContainer,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Stock',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                    Text(
                                      '${_getCurrentStock(selectedProduct)} units',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: theme.colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                Icon(
                                  _adjustmentType == AdjustmentType.add
                                      ? Icons.arrow_forward
                                      : Icons.arrow_forward,
                                  color: theme.colorScheme.onTertiaryContainer,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'New Stock',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                    Text(
                                      '${_calculateNewStock(selectedProduct)} units',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onTertiaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 56),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: FilledButton.icon(
                          onPressed: _submitAdjustment,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 56),
                          ),
                          icon: const Icon(Icons.check),
                          label: const Text('Save Adjustment'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // Adjustment history
                  Text(
                    'Recent Adjustments',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildAdjustmentHistory(context, selectedProduct),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading products')),
      ),
    );
  }

  Widget _buildAdjustmentHistory(BuildContext context, Product? product) {
    final theme = Theme.of(context);

    // Mock adjustment history
    final history = product != null ? _getMockHistory(product) : <StockAdjustment>[];

    if (history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48,
                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 8),
                Text(
                  'No adjustment history',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: history.map((adjustment) {
        final isIncrease = adjustment.type == AdjustmentType.add;
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isIncrease
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isIncrease ? Icons.add : Icons.remove,
                color: isIncrease ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              '${isIncrease ? '+' : '-'}${adjustment.quantity} units',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(_getReasonLabel(adjustment.reason)),
                Text(
                  DateFormat('MMM d, h:mm a').format(adjustment.date),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            trailing: adjustment.notes.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      _showAdjustmentDetails(context, adjustment);
                    },
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  void _showAdjustmentDetails(BuildContext context, StockAdjustment adjustment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adjustment Details'),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow('Date', DateFormat('MMM d, yyyy h:mm a').format(adjustment.date)),
            _buildDetailRow('Type', adjustment.type == AdjustmentType.add ? 'Add' : 'Remove'),
            _buildDetailRow('Quantity', '${adjustment.quantity} units'),
            _buildDetailRow('Reason', _getReasonLabel(adjustment.reason)),
            if (adjustment.notes.isNotEmpty) _buildDetailRow('Notes', adjustment.notes),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _submitAdjustment() {
    if (_formKey.currentState!.validate()) {
      final product = ref.read(productsProvider()).value?.firstWhere(
            (p) => p.id == _selectedProductId,
          );

      if (product == null) return;

      final quantity = int.parse(_quantityController.text);
      final newStock = _calculateNewStock(product);

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Confirm Adjustment'),
          content: Text(
            'Adjust stock for ${product.name}?\n\n'
            'Current: ${_getCurrentStock(product)} units\n'
            'New: $newStock units\n\n'
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Stock adjusted for ${product.name}. New level: $newStock units',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );

                // In real app: save stock adjustment to database
              },
              child: const Text('Confirm'),
            ),
          ],
        ),
      );
    }
  }

  int _getCurrentStock(Product product) {
    // Mock - in real app would get from inventory database
    return (product.id.hashCode % 50).abs();
  }

  int _calculateNewStock(Product product) {
    final currentStock = _getCurrentStock(product);
    final quantity = int.tryParse(_quantityController.text) ?? 0;

    return _adjustmentType == AdjustmentType.add
        ? currentStock + quantity
        : currentStock - quantity;
  }

  String _getReasonLabel(AdjustmentReason reason) {
    switch (reason) {
      case AdjustmentReason.countCorrection:
        return 'Count Correction';
      case AdjustmentReason.waste:
        return 'Waste';
      case AdjustmentReason.damage:
        return 'Damage';
      case AdjustmentReason.theft:
        return 'Theft';
      case AdjustmentReason.returned:
        return 'Returned to Supplier';
      case AdjustmentReason.other:
        return 'Other';
    }
  }

  List<StockAdjustment> _getMockHistory(Product product) {
    return [
      StockAdjustment(
        type: AdjustmentType.add,
        quantity: 20,
        reason: AdjustmentReason.countCorrection,
        date: DateTime.now().subtract(const Duration(days: 2)),
        notes: 'Physical count found more stock',
      ),
      StockAdjustment(
        type: AdjustmentType.remove,
        quantity: 5,
        reason: AdjustmentReason.waste,
        date: DateTime.now().subtract(const Duration(days: 5)),
        notes: 'Expired items removed',
      ),
    ];
  }
}

// Enums
enum AdjustmentType { add, remove }

enum AdjustmentReason {
  countCorrection,
  waste,
  damage,
  theft,
  returned,
  other,
}

// Data class
class StockAdjustment {
  final AdjustmentType type;
  final int quantity;
  final AdjustmentReason reason;
  final DateTime date;
  final String notes;

  StockAdjustment({
    required this.type,
    required this.quantity,
    required this.reason,
    required this.date,
    required this.notes,
  });
}
