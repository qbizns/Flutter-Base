import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Transaction Sync - View and manage synced transactions
class TransactionSyncPage extends ConsumerStatefulWidget {
  const TransactionSyncPage({super.key});

  @override
  ConsumerState<TransactionSyncPage> createState() => _TransactionSyncPageState();
}

class _TransactionSyncPageState extends ConsumerState<TransactionSyncPage> {
  String _selectedType = 'All';
  String _selectedStatus = 'All';
  String _selectedProvider = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock transaction data
    final transactions = [
      SyncedTransaction('TXN001', TransactionType.sale, 1250.50, DateTime.now().subtract(const Duration(hours: 1)), AccountingProvider.quickbooks, SyncStatus.synced, 'INV-2024-001', 'Cash Sale - Store #1'),
      SyncedTransaction('TXN002', TransactionType.expense, 850.00, DateTime.now().subtract(const Duration(hours: 2)), AccountingProvider.quickbooks, SyncStatus.synced, 'EXP-2024-045', 'Office Supplies Purchase'),
      SyncedTransaction('TXN003', TransactionType.sale, 3420.75, DateTime.now().subtract(const Duration(hours: 3)), AccountingProvider.xero, SyncStatus.pending, null, 'Catering Service - Corporate Client'),
      SyncedTransaction('TXN004', TransactionType.payment, 5000.00, DateTime.now().subtract(const Duration(hours: 4)), AccountingProvider.quickbooks, SyncStatus.synced, 'PAY-2024-128', 'Vendor Payment - Supplier ABC'),
      SyncedTransaction('TXN005', TransactionType.invoice, 2840.25, DateTime.now().subtract(const Duration(hours: 5)), AccountingProvider.xero, SyncStatus.error, null, 'Monthly Service Contract'),
      SyncedTransaction('TXN006', TransactionType.expense, 425.50, DateTime.now().subtract(const Duration(hours: 6)), AccountingProvider.quickbooks, SyncStatus.synced, 'EXP-2024-046', 'Utility Bill Payment'),
      SyncedTransaction('TXN007', TransactionType.sale, 680.00, DateTime.now().subtract(const Duration(days: 1)), AccountingProvider.xero, SyncStatus.synced, 'INV-2024-002', 'Retail Sale - Store #2'),
      SyncedTransaction('TXN008', TransactionType.refund, 125.00, DateTime.now().subtract(const Duration(days: 1, hours: 2)), AccountingProvider.quickbooks, SyncStatus.synced, 'REF-2024-005', 'Customer Refund'),
    ];

    // Apply filters
    final filteredTransactions = transactions.where((t) {
      if (_selectedType != 'All' && t.type.name != _selectedType.toLowerCase()) return false;
      if (_selectedStatus != 'All' && t.status.name != _selectedStatus.toLowerCase()) return false;
      if (_selectedProvider != 'All' && t.provider.name != _selectedProvider.toLowerCase()) return false;
      return true;
    }).toList();

    final syncedCount = transactions.where((t) => t.status == SyncStatus.synced).length;
    final pendingCount = transactions.where((t) => t.status == SyncStatus.pending).length;
    final errorCount = transactions.where((t) => t.status == SyncStatus.error).length;
    final totalAmount = filteredTransactions.where((t) => t.type == TransactionType.sale).fold<double>(0, (sum, t) => sum + t.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction Sync')),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            '$syncedCount',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                          Text('Synced', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.hourglass_empty, color: Colors.orange.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            '$pendingCount',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                          ),
                          Text('Pending', style: theme.textTheme.bodySmall),
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
                          Icon(Icons.error, color: Colors.red.shade700, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            '$errorCount',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                          ),
                          Text('Errors', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.attach_money, color: theme.colorScheme.onPrimaryContainer, size: 28),
                          const SizedBox(height: 8),
                          Text(
                            NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalAmount),
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                          ),
                          Text('Sales Total', style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Sale', 'Expense', 'Invoice', 'Payment', 'Refund']
                        .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedType = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Synced', 'Pending', 'Error']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedProvider,
                    decoration: const InputDecoration(
                      labelText: 'Provider',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Quickbooks', 'Xero', 'Sage']
                        .map((provider) => DropdownMenuItem(value: provider, child: Text(provider)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedProvider = value!),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Transactions list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final transaction = filteredTransactions[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getSyncStatusColor(transaction.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getTransactionTypeIcon(transaction.type), color: _getSyncStatusColor(transaction.status), size: 20),
                    ),
                    title: Row(
                      children: [
                        Text(transaction.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getSyncStatusColor(transaction.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            transaction.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: _getSyncStatusColor(transaction.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('${transaction.type.name.toUpperCase()} • ${transaction.provider.name} • ${DateFormat('MMM dd, h:mm a').format(transaction.timestamp)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$').format(transaction.amount),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        if (transaction.status == SyncStatus.error)
                          Text(
                            'RETRY',
                            style: TextStyle(fontSize: 10, color: Colors.red.shade700, fontWeight: FontWeight.bold),
                          ),
                      ],
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow('Transaction ID', transaction.id),
                            _buildInfoRow('Type', transaction.type.name.toUpperCase()),
                            _buildInfoRow('Amount', NumberFormat.currency(symbol: '\$').format(transaction.amount)),
                            _buildInfoRow('Provider', transaction.provider.name.toUpperCase()),
                            _buildInfoRow('Status', transaction.status.name.toUpperCase()),
                            _buildInfoRow('Timestamp', DateFormat('MMM dd, yyyy h:mm a').format(transaction.timestamp)),
                            if (transaction.externalRef != null)
                              _buildInfoRow('External Ref', transaction.externalRef!),
                            const Divider(height: 24),
                            Text('Description', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(transaction.description, style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (transaction.status == SyncStatus.synced) ...[
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.visibility, size: 18),
                                      label: const Text('View in ${AccountingProvider.quickbooks}'),
                                    ),
                                  ),
                                ] else if (transaction.status == SyncStatus.error) ...[
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.refresh, size: 18),
                                      label: const Text('Retry Sync'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.edit, size: 18),
                                      label: const Text('Edit & Retry'),
                                    ),
                                  ),
                                ] else ...[
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.sync, size: 18),
                                      label: const Text('Force Sync'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
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

  Color _getSyncStatusColor(SyncStatus status) {
    switch (status) {
      case SyncStatus.synced: return Colors.green;
      case SyncStatus.pending: return Colors.orange;
      case SyncStatus.error: return Colors.red;
    }
  }

  IconData _getTransactionTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.sale: return Icons.shopping_cart;
      case TransactionType.expense: return Icons.money_off;
      case TransactionType.invoice: return Icons.receipt;
      case TransactionType.payment: return Icons.payment;
      case TransactionType.refund: return Icons.keyboard_return;
    }
  }
}

// Models
class SyncedTransaction {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime timestamp;
  final AccountingProvider provider;
  final SyncStatus status;
  final String? externalRef;
  final String description;

  SyncedTransaction(this.id, this.type, this.amount, this.timestamp, this.provider, this.status, this.externalRef, this.description);
}

enum TransactionType { sale, expense, invoice, payment, refund }
enum AccountingProvider { quickbooks, xero, sage }
enum SyncStatus { synced, pending, error }
