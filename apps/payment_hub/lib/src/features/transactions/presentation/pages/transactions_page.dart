import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Transactions Page - Payment transaction logs and monitoring
class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  String _selectedStatus = 'All';
  String _selectedProvider = 'All';

  final transactions = [
    Transaction('TXN001', 125.50, PaymentProvider.stripe, TransactionStatus.completed, PaymentType.card, DateTime.now().subtract(const Duration(minutes: 5))),
    Transaction('TXN002', 89.99, PaymentProvider.square, TransactionStatus.completed, PaymentType.card, DateTime.now().subtract(const Duration(minutes: 15))),
    Transaction('TXN003', 45.00, PaymentProvider.stripe, TransactionStatus.failed, PaymentType.card, DateTime.now().subtract(const Duration(minutes: 25))),
    Transaction('TXN004', 210.75, PaymentProvider.stripe, TransactionStatus.refunded, PaymentType.card, DateTime.now().subtract(const Duration(hours: 1))),
    Transaction('TXN005', 67.25, PaymentProvider.square, TransactionStatus.pending, PaymentType.wallet, DateTime.now().subtract(const Duration(hours: 2))),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = transactions.where((t) {
      if (_selectedStatus != 'All' && t.status.name != _selectedStatus.toLowerCase()) return false;
      if (_selectedProvider != 'All' && t.provider.name != _selectedProvider.toLowerCase()) return false;
      return true;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: ['All', 'Completed', 'Pending', 'Failed', 'Refunded']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedStatus = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProvider,
                    decoration: const InputDecoration(
                      labelText: 'Provider',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: ['All', 'Stripe', 'Square']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedProvider = v!),
                  ),
                ),
              ],
            ),
          ),

          // Stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(child: _buildStatCard(theme, 'Total', NumberFormat.currency(symbol: '\$').format(transactions.fold<double>(0, (s, t) => s + t.amount)), Icons.attach_money, Colors.green)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(theme, 'Count', transactions.length.toString(), Icons.receipt, Colors.blue)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transactions list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final txn = filtered[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getStatusColor(txn.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getPaymentIcon(txn.type), color: _getStatusColor(txn.status)),
                    ),
                    title: Text(txn.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${txn.provider.name.toUpperCase()} • ${txn.type.name}'),
                        Text(DateFormat('MMM dd, h:mm a').format(txn.timestamp), style: theme.textTheme.bodySmall),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$').format(txn.amount),
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: txn.status == TransactionStatus.refunded ? Colors.red : Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(txn.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            txn.status.name.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(txn.status)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed: return Colors.green;
      case TransactionStatus.pending: return Colors.orange;
      case TransactionStatus.failed: return Colors.red;
      case TransactionStatus.refunded: return Colors.grey;
    }
  }

  IconData _getPaymentIcon(PaymentType type) {
    switch (type) {
      case PaymentType.card: return Icons.credit_card;
      case PaymentType.wallet: return Icons.account_balance_wallet;
      case PaymentType.cash: return Icons.money;
    }
  }
}

class Transaction {
  final String id;
  final double amount;
  final PaymentProvider provider;
  final TransactionStatus status;
  final PaymentType type;
  final DateTime timestamp;
  Transaction(this.id, this.amount, this.provider, this.status, this.type, this.timestamp);
}

enum PaymentProvider { stripe, square }
enum TransactionStatus { completed, pending, failed, refunded }
enum PaymentType { card, wallet, cash }
