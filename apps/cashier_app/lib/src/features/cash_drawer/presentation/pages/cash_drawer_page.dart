import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Cash Drawer Management Page
///
/// Features:
/// - Open/close cash drawer
/// - Starting cash count
/// - Cash in/out operations
/// - End of shift reconciliation
/// - Cash counting by denomination
class CashDrawerPage extends ConsumerStatefulWidget {
  const CashDrawerPage({super.key});

  @override
  ConsumerState<CashDrawerPage> createState() => _CashDrawerPageState();
}

class _CashDrawerPageState extends ConsumerState<CashDrawerPage> {
  bool _isDrawerOpen = true;
  double _startingCash = 200.00;
  double _expectedCash = 450.00; // Expected based on transactions
  double _actualCash = 0.0;

  // Denomination counts
  final Map<double, int> _denominations = {
    100.0: 0,
    50.0: 0,
    20.0: 10, // Starting with $200
    10.0: 0,
    5.0: 0,
    1.0: 0,
    0.25: 0,
    0.10: 0,
    0.05: 0,
    0.01: 0,
  };

  @override
  void initState() {
    super.initState();
    _calculateActualCash();
  }

  void _calculateActualCash() {
    _actualCash = _denominations.entries.fold(
      0.0,
      (sum, entry) => sum + (entry.key * entry.value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difference = _actualCash - _expectedCash;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Drawer'),
        actions: [
          Chip(
            label: Text(_isDrawerOpen ? 'Open' : 'Closed'),
            backgroundColor: _isDrawerOpen
                ? Colors.green.withOpacity(0.2)
                : Colors.red.withOpacity(0.2),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    'Starting Cash',
                    '\$${_startingCash.toStringAsFixed(2)}',
                    Icons.account_balance_wallet,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    'Expected Cash',
                    '\$${_expectedCash.toStringAsFixed(2)}',
                    Icons.calculate,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    'Actual Cash',
                    '\$${_actualCash.toStringAsFixed(2)}',
                    Icons.payments,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    theme,
                    'Difference',
                    '${difference >= 0 ? '+' : ''}\$${difference.toStringAsFixed(2)}',
                    difference >= 0 ? Icons.trending_up : Icons.trending_down,
                    difference >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Cash counting
            _buildCashCounting(theme),

            const SizedBox(height: 24),

            // Quick actions
            _buildQuickActions(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashCounting(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Count Cash',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Bills
            Text(
              'Bills',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...[100.0, 50.0, 20.0, 10.0, 5.0, 1.0].map((denomination) {
              return _buildDenominationRow(
                theme,
                '\$${denomination.toStringAsFixed(0)}',
                denomination,
              );
            }),

            const Divider(height: 32),

            // Coins
            Text(
              'Coins',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...[0.25, 0.10, 0.05, 0.01].map((denomination) {
              return _buildDenominationRow(
                theme,
                _getCoinLabel(denomination),
                denomination,
              );
            }),

            const SizedBox(height: 24),

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Counted',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '\$${_actualCash.toStringAsFixed(2)}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDenominationRow(ThemeData theme, String label, double denomination) {
    final count = _denominations[denomination] ?? 0;
    final total = denomination * count;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: count > 0
                ? () {
                    setState(() {
                      _denominations[denomination] = count - 1;
                      _calculateActualCash();
                    });
                  }
                : null,
          ),
          SizedBox(
            width: 60,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              controller: TextEditingController(text: count.toString()),
              onChanged: (value) {
                setState(() {
                  _denominations[denomination] = int.tryParse(value) ?? 0;
                  _calculateActualCash();
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                _denominations[denomination] = count + 1;
                _calculateActualCash();
              });
            },
          ),
          const Spacer(),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showCashInOutDialog,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Cash In/Out'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 56),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: _showEndShiftDialog,
            icon: const Icon(Icons.summarize),
            label: const Text('End Shift Report'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 56),
            ),
          ),
        ),
      ],
    );
  }

  void _showCashInOutDialog() {
    final typeController = TextEditingController();
    final amountController = TextEditingController();
    final reasonController = TextEditingController();
    String type = 'in';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Cash In/Out'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'in',
                      label: Text('Cash In'),
                      icon: Icon(Icons.add_circle),
                    ),
                    ButtonSegment(
                      value: 'out',
                      label: Text('Cash Out'),
                      icon: Icon(Icons.remove_circle),
                    ),
                  ],
                  selected: {type},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      type = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                if (type == 'in') {
                  setState(() {
                    _expectedCash += amount;
                  });
                } else {
                  setState(() {
                    _expectedCash -= amount;
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Cash $type recorded: \$${amount.toStringAsFixed(2)}'),
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Record'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndShiftDialog() {
    final difference = _actualCash - _expectedCash;
    final now = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End of Shift Report'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildReportRow('Date', DateFormat('MMM d, y').format(now)),
              _buildReportRow('Time', DateFormat('HH:mm').format(now)),
              _buildReportRow('Cashier', 'John Doe'),
              const Divider(height: 24),
              _buildReportRow('Starting Cash', '\$${_startingCash.toStringAsFixed(2)}'),
              _buildReportRow('Expected Cash', '\$${_expectedCash.toStringAsFixed(2)}'),
              _buildReportRow('Actual Cash', '\$${_actualCash.toStringAsFixed(2)}'),
              const Divider(height: 24),
              _buildReportRow(
                'Difference',
                '${difference >= 0 ? '+' : ''}\$${difference.toStringAsFixed(2)}',
                isHighlighted: true,
                color: difference >= 0 ? Colors.green : Colors.red,
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing report...')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Report'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isDrawerOpen = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Shift ended successfully')),
              );
            },
            child: const Text('Close Drawer'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportRow(
    String label,
    String value, {
    bool isHighlighted = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getCoinLabel(double denomination) {
    if (denomination == 0.25) return '25¢';
    if (denomination == 0.10) return '10¢';
    if (denomination == 0.05) return '5¢';
    if (denomination == 0.01) return '1¢';
    return '';
  }
}
