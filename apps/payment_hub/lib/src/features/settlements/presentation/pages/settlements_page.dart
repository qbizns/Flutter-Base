import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Settlements Page - Settlement reports and reconciliation
class SettlementsPage extends ConsumerWidget {
  const SettlementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final settlements = [
      Settlement('SET001', 5420.50, SettlementStatus.completed, PaymentProvider.stripe, DateTime.now().subtract(const Duration(days: 1)), 45),
      Settlement('SET002', 3890.25, SettlementStatus.pending, PaymentProvider.square, DateTime.now(), 32),
      Settlement('SET003', 6125.75, SettlementStatus.completed, PaymentProvider.stripe, DateTime.now().subtract(const Duration(days: 2)), 58),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Settlements')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Row(
            children: [
              Expanded(
                child: Card(
                  color: theme.colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Settled', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(settlements.where((s) => s.status == SettlementStatus.completed).fold<double>(0, (sum, s) => sum + s.amount)),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pending', style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(settlements.where((s) => s.status == SettlementStatus.pending).fold<double>(0, (sum, s) => sum + s.amount)),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Settlements list
          Text('Settlement History', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...settlements.map((settlement) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(settlement.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.account_balance, color: _getStatusColor(settlement.status)),
              ),
              title: Text(settlement.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              subtitle: Text('${settlement.provider.name.toUpperCase()} • ${DateFormat('MMM dd, yyyy').format(settlement.date)}'),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    NumberFormat.currency(symbol: '\$').format(settlement.amount),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(settlement.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      settlement.status.name.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(settlement.status)),
                    ),
                  ),
                ],
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildDetailRow('Settlement ID', settlement.id),
                      _buildDetailRow('Provider', settlement.provider.name.toUpperCase()),
                      _buildDetailRow('Amount', NumberFormat.currency(symbol: '\$').format(settlement.amount)),
                      _buildDetailRow('Transactions', settlement.transactionCount.toString()),
                      _buildDetailRow('Date', DateFormat('MMM dd, yyyy h:mm a').format(settlement.date)),
                      _buildDetailRow('Status', settlement.status.name.toUpperCase()),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.download, size: 18),
                              label: const Text('Export'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.visibility, size: 18),
                              label: const Text('Details'),
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
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getStatusColor(SettlementStatus status) {
    switch (status) {
      case SettlementStatus.completed: return Colors.green;
      case SettlementStatus.pending: return Colors.orange;
    }
  }
}

class Settlement {
  final String id;
  final double amount;
  final SettlementStatus status;
  final PaymentProvider provider;
  final DateTime date;
  final int transactionCount;
  Settlement(this.id, this.amount, this.status, this.provider, this.date, this.transactionCount);
}

enum SettlementStatus { completed, pending }
enum PaymentProvider { stripe, square }
