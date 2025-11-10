import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/transaction.dart';

/// Transaction History Page
///
/// Features:
/// - View all completed transactions
/// - Filter by date, payment method, status
/// - Search by order number or customer
/// - Transaction details view
/// - Refund/void capabilities
class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactions = _getMockTransactions();
    final filteredTransactions = _filterTransactions(transactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Completed'),
            Tab(text: 'Refunded'),
            Tab(text: 'Voided'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search by order number or customer...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildStatistics(theme, transactions),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionsList(theme, filteredTransactions),
                _buildTransactionsList(
                  theme,
                  filteredTransactions
                      .where((t) => t.status == TransactionStatus.completed)
                      .toList(),
                ),
                _buildTransactionsList(
                  theme,
                  filteredTransactions
                      .where((t) => t.status == TransactionStatus.refunded)
                      .toList(),
                ),
                _buildTransactionsList(
                  theme,
                  filteredTransactions
                      .where((t) => t.status == TransactionStatus.voided)
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(ThemeData theme, List<Transaction> transactions) {
    final todayTransactions = transactions.where((t) {
      final today = DateTime.now();
      return t.timestamp.year == today.year &&
          t.timestamp.month == today.month &&
          t.timestamp.day == today.day;
    }).toList();

    final todayTotal = todayTransactions
        .where((t) => t.status == TransactionStatus.completed)
        .fold(0.0, (sum, t) => sum + t.total);

    final todayCount = todayTransactions.length;
    final avgTransaction = todayCount > 0 ? todayTotal / todayCount : 0.0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            theme,
            'Today\'s Sales',
            '\$${todayTotal.toStringAsFixed(2)}',
            Icons.attach_money,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Transactions',
            '$todayCount',
            Icons.receipt,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            theme,
            'Avg. Transaction',
            '\$${avgTransaction.toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
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
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsList(ThemeData theme, List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text('No transactions found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return _buildTransactionCard(theme, transaction);
      },
    );
  }

  Widget _buildTransactionCard(ThemeData theme, Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getPaymentMethodColor(transaction.paymentMethod)
                .withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getPaymentMethodIcon(transaction.paymentMethod),
            color: _getPaymentMethodColor(transaction.paymentMethod),
          ),
        ),
        title: Row(
          children: [
            Text(
              'Order #${transaction.orderId}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Chip(
              label: Text(
                transaction.status.label,
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getStatusColor(transaction.status),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${transaction.paymentMethod.label} • ${transaction.cashierName}',
            ),
            Text(
              DateFormat('MMM d, y HH:mm').format(transaction.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${transaction.total.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            if (transaction.tip > 0)
              Text(
                '+\$${transaction.tip.toStringAsFixed(2)} tip',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                ),
              ),
          ],
        ),
        onTap: () {
          _showTransactionDetails(context, transaction);
        },
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDetailRow('Receipt #', transaction.receiptNumber ?? 'N/A'),
              _buildDetailRow('Order #', transaction.orderId),
              _buildDetailRow('Status', transaction.status.label),
              _buildDetailRow('Payment Method', transaction.paymentMethod.label),
              if (transaction.cardLastFour != null)
                _buildDetailRow('Card', '**** ${transaction.cardLastFour}'),
              const Divider(height: 24),
              _buildDetailRow('Subtotal', '\$${transaction.subtotal.toStringAsFixed(2)}'),
              _buildDetailRow('Tax', '\$${transaction.tax.toStringAsFixed(2)}'),
              if (transaction.tip > 0)
                _buildDetailRow('Tip', '\$${transaction.tip.toStringAsFixed(2)}'),
              if (transaction.discount > 0)
                _buildDetailRow('Discount', '-\$${transaction.discount.toStringAsFixed(2)}'),
              _buildDetailRow(
                'Total',
                '\$${transaction.total.toStringAsFixed(2)}',
                isTotal: true,
              ),
              if (transaction.cashTendered != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  'Cash Tendered',
                  '\$${transaction.cashTendered!.toStringAsFixed(2)}',
                ),
                _buildDetailRow(
                  'Change',
                  '\$${transaction.change!.toStringAsFixed(2)}',
                ),
              ],
              const Divider(height: 24),
              _buildDetailRow('Cashier', transaction.cashierName),
              _buildDetailRow(
                'Time',
                DateFormat('MMM d, y HH:mm:ss').format(transaction.timestamp),
              ),
            ],
          ),
        ),
        actions: [
          if (transaction.status == TransactionStatus.completed) ...[
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showRefundDialog(context, transaction);
              },
              icon: const Icon(Icons.undo),
              label: const Text('Refund'),
            ),
          ],
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Printing receipt...')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('Print Receipt'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showRefundDialog(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Transaction'),
        content: Text(
          'Are you sure you want to refund \$${transaction.total.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refund processed')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Refund'),
          ),
        ],
      ),
    );
  }

  List<Transaction> _filterTransactions(List<Transaction> transactions) {
    if (_searchQuery.isEmpty) return transactions;

    return transactions.where((t) {
      return t.orderId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (t.customerName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          (t.receiptNumber?.contains(_searchQuery) ?? false);
    }).toList();
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Icons.payments;
      case PaymentMethod.card:
        return Icons.credit_card;
      case PaymentMethod.digitalWallet:
        return Icons.phone_android;
      case PaymentMethod.giftCard:
        return Icons.card_giftcard;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.card:
        return Colors.blue;
      case PaymentMethod.digitalWallet:
        return Colors.purple;
      case PaymentMethod.giftCard:
        return Colors.orange;
    }
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.pending:
        return Colors.orange.withOpacity(0.2);
      case TransactionStatus.completed:
        return Colors.green.withOpacity(0.2);
      case TransactionStatus.refunded:
        return Colors.red.withOpacity(0.2);
      case TransactionStatus.voided:
        return Colors.grey.withOpacity(0.2);
    }
  }

  List<Transaction> _getMockTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1',
        orderId: '1001',
        subtotal: 45.00,
        tax: 3.60,
        tip: 9.00,
        discount: 0,
        total: 57.60,
        paymentMethod: PaymentMethod.card,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(minutes: 15)),
        cashierId: '1',
        cashierName: 'John Doe',
        cardLastFour: '4242',
        receiptNumber: '10001',
      ),
      Transaction(
        id: '2',
        orderId: '1002',
        subtotal: 28.50,
        tax: 2.28,
        tip: 0,
        discount: 0,
        total: 30.78,
        paymentMethod: PaymentMethod.cash,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(minutes: 30)),
        cashierId: '1',
        cashierName: 'John Doe',
        cashTendered: 40.00,
        change: 9.22,
        receiptNumber: '10002',
      ),
      Transaction(
        id: '3',
        orderId: '1003',
        subtotal: 62.00,
        tax: 4.96,
        tip: 12.40,
        discount: 0,
        total: 79.36,
        paymentMethod: PaymentMethod.digitalWallet,
        status: TransactionStatus.completed,
        timestamp: now.subtract(const Duration(hours: 1)),
        cashierId: '1',
        cashierName: 'John Doe',
        receiptNumber: '10003',
      ),
      Transaction(
        id: '4',
        orderId: '1004',
        subtotal: 35.00,
        tax: 2.80,
        tip: 0,
        discount: 0,
        total: 37.80,
        paymentMethod: PaymentMethod.card,
        status: TransactionStatus.refunded,
        timestamp: now.subtract(const Duration(hours: 2)),
        cashierId: '1',
        cashierName: 'John Doe',
        cardLastFour: '1234',
        receiptNumber: '10004',
      ),
    ];
  }
}
