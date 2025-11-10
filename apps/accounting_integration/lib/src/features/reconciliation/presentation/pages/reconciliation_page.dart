import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Reconciliation - Match and verify transactions
class ReconciliationPage extends ConsumerStatefulWidget {
  const ReconciliationPage({super.key});

  @override
  ConsumerState<ReconciliationPage> createState() => _ReconciliationPageState();
}

class _ReconciliationPageState extends ConsumerState<ReconciliationPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock reconciliation data
    final discrepancies = [
      Discrepancy('DISC001', 1250.50, 1250.00, DiscrepancyType.amountMismatch, DateTime.now().subtract(const Duration(hours: 2)), 'TXN-2024-145', 'INV-145'),
      Discrepancy('DISC002', 840.25, 0, DiscrepancyType.missingInAccounting, DateTime.now().subtract(const Duration(hours: 5)), 'TXN-2024-148', null),
      Discrepancy('DISC003', 0, 525.00, DiscrepancyType.missingInPOS, DateTime.now().subtract(const Duration(days: 1)), null, 'INV-152'),
      Discrepancy('DISC004', 3200.00, 3210.00, DiscrepancyType.amountMismatch, DateTime.now().subtract(const Duration(days: 1, hours: 3)), 'TXN-2024-142', 'INV-142'),
    ];

    final periods = [
      ReconciliationPeriod('October 2024', DateTime(2024, 10, 1), DateTime(2024, 10, 31), ReconciliationStatus.reconciled, 15680.50, 15680.50, 0, 245),
      ReconciliationPeriod('November 2024 (Week 1)', DateTime(2024, 11, 1), DateTime(2024, 11, 7), ReconciliationStatus.reconciled, 8920.25, 8920.25, 0, 142),
      ReconciliationPeriod('November 2024 (Week 2)', DateTime(2024, 11, 8), DateTime(2024, 11, 10), ReconciliationStatus.inProgress, 4615.75, 4565.25, 50.50, 68),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconciliation'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Discrepancies', icon: Icon(Icons.warning)),
            Tab(text: 'Periods', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Discrepancies tab
          _buildDiscrepanciesTab(theme, discrepancies),

          // Periods tab
          _buildPeriodsTab(theme, periods),
        ],
      ),
    );
  }

  Widget _buildDiscrepanciesTab(ThemeData theme, List<Discrepancy> discrepancies) {
    final amountMismatch = discrepancies.where((d) => d.type == DiscrepancyType.amountMismatch).length;
    final missingInAccounting = discrepancies.where((d) => d.type == DiscrepancyType.missingInAccounting).length;
    final missingInPOS = discrepancies.where((d) => d.type == DiscrepancyType.missingInPOS).length;
    final totalVariance = discrepancies.fold<double>(0, (sum, d) => sum + (d.posAmount - d.accountingAmount).abs());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Summary cards
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.compare_arrows, color: Colors.orange.shade700, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        '$amountMismatch',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                      ),
                      Text('Amount Mismatch', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.remove_circle, color: Colors.red.shade700, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        '$missingInAccounting',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                      ),
                      Text('Missing in Accounting', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: Colors.purple.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.add_circle, color: Colors.purple.shade700, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        '$missingInPOS',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                      ),
                      Text('Missing in POS', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: theme.colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(Icons.account_balance, color: theme.colorScheme.onErrorContainer, size: 28),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(totalVariance),
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onErrorContainer),
                      ),
                      Text('Total Variance', style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text('Unresolved Discrepancies', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...discrepancies.map((discrepancy) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getDiscrepancyTypeColor(discrepancy.type).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning, color: _getDiscrepancyTypeColor(discrepancy.type), size: 20),
            ),
            title: Row(
              children: [
                Text(discrepancy.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getDiscrepancyTypeColor(discrepancy.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getDiscrepancyTypeLabel(discrepancy.type),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getDiscrepancyTypeColor(discrepancy.type),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text('Detected ${_formatTime(discrepancy.timestamp)}'),
            trailing: Text(
              '\$${(discrepancy.posAmount - discrepancy.accountingAmount).abs().toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Discrepancy ID', discrepancy.id),
                    _buildInfoRow('Type', _getDiscrepancyTypeLabel(discrepancy.type)),
                    _buildInfoRow('POS Amount', NumberFormat.currency(symbol: '\$').format(discrepancy.posAmount)),
                    _buildInfoRow('Accounting Amount', NumberFormat.currency(symbol: '\$').format(discrepancy.accountingAmount)),
                    _buildInfoRow('Variance', NumberFormat.currency(symbol: '\$').format((discrepancy.posAmount - discrepancy.accountingAmount).abs())),
                    if (discrepancy.posRef != null)
                      _buildInfoRow('POS Reference', discrepancy.posRef!),
                    if (discrepancy.accountingRef != null)
                      _buildInfoRow('Accounting Reference', discrepancy.accountingRef!),
                    _buildInfoRow('Detected', DateFormat('MMM dd, yyyy h:mm a').format(discrepancy.timestamp)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.visibility, size: 18),
                            label: const Text('View Details'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Resolve'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildPeriodsTab(ThemeData theme, List<ReconciliationPeriod> periods) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Reconciliation Periods', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...periods.map((period) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getPeriodStatusColor(period.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.calendar_today, color: _getPeriodStatusColor(period.status), size: 20),
            ),
            title: Row(
              children: [
                Text(period.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPeriodStatusColor(period.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    period.status.name.toUpperCase().replaceAll('_', ' '),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getPeriodStatusColor(period.status),
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text('${DateFormat('MMM dd').format(period.startDate)} - ${DateFormat('MMM dd, yyyy').format(period.endDate)} • ${period.transactionCount} transactions'),
            trailing: period.variance == 0
                ? Icon(Icons.check_circle, color: Colors.green.shade700)
                : Text(
                    '\$${period.variance.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow('Period', period.name),
                    _buildInfoRow('Start Date', DateFormat('MMM dd, yyyy').format(period.startDate)),
                    _buildInfoRow('End Date', DateFormat('MMM dd, yyyy').format(period.endDate)),
                    _buildInfoRow('Status', period.status.name.toUpperCase().replaceAll('_', ' ')),
                    _buildInfoRow('Transactions', '${period.transactionCount}'),
                    const Divider(height: 24),
                    _buildInfoRow('POS Total', NumberFormat.currency(symbol: '\$').format(period.posTotal)),
                    _buildInfoRow('Accounting Total', NumberFormat.currency(symbol: '\$').format(period.accountingTotal)),
                    _buildInfoRow('Variance', NumberFormat.currency(symbol: '\$').format(period.variance)),
                    const SizedBox(height: 16),
                    if (period.status == ReconciliationStatus.inProgress) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.sync, size: 18),
                              label: const Text('Refresh'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.check, size: 18),
                              label: const Text('Complete'),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Export Report'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.undo, size: 18),
                              label: const Text('Reopen'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getDiscrepancyTypeColor(DiscrepancyType type) {
    switch (type) {
      case DiscrepancyType.amountMismatch: return Colors.orange;
      case DiscrepancyType.missingInAccounting: return Colors.red;
      case DiscrepancyType.missingInPOS: return Colors.purple;
    }
  }

  String _getDiscrepancyTypeLabel(DiscrepancyType type) {
    switch (type) {
      case DiscrepancyType.amountMismatch: return 'AMOUNT MISMATCH';
      case DiscrepancyType.missingInAccounting: return 'MISSING IN ACCOUNTING';
      case DiscrepancyType.missingInPOS: return 'MISSING IN POS';
    }
  }

  Color _getPeriodStatusColor(ReconciliationStatus status) {
    switch (status) {
      case ReconciliationStatus.reconciled: return Colors.green;
      case ReconciliationStatus.inProgress: return Colors.orange;
      case ReconciliationStatus.pending: return Colors.grey;
    }
  }

  String _formatTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

// Models
class Discrepancy {
  final String id;
  final double posAmount;
  final double accountingAmount;
  final DiscrepancyType type;
  final DateTime timestamp;
  final String? posRef;
  final String? accountingRef;

  Discrepancy(this.id, this.posAmount, this.accountingAmount, this.type, this.timestamp, this.posRef, this.accountingRef);
}

class ReconciliationPeriod {
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final ReconciliationStatus status;
  final double posTotal;
  final double accountingTotal;
  final double variance;
  final int transactionCount;

  ReconciliationPeriod(this.name, this.startDate, this.endDate, this.status, this.posTotal, this.accountingTotal, this.variance, this.transactionCount);
}

enum DiscrepancyType { amountMismatch, missingInAccounting, missingInPOS }
enum ReconciliationStatus { pending, inProgress, reconciled }
