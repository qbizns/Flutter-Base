import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Refunds Page - Manage refunds and chargebacks
class RefundsPage extends ConsumerStatefulWidget {
  const RefundsPage({super.key});

  @override
  ConsumerState<RefundsPage> createState() => _RefundsPageState();
}

class _RefundsPageState extends ConsumerState<RefundsPage> with SingleTickerProviderStateMixin {
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

    final refunds = [
      Refund('REF001', 'TXN1234', 125.50, RefundReason.customerRequest, RefundStatus.completed, PaymentProvider.stripe, DateTime.now().subtract(const Duration(hours: 2)), 'John Smith', 'Customer changed mind'),
      Refund('REF002', 'TXN1235', 89.99, RefundReason.duplicate, RefundStatus.pending, PaymentProvider.square, DateTime.now().subtract(const Duration(minutes: 30)), 'Emma Johnson', 'Accidental duplicate charge'),
      Refund('REF003', 'TXN1236', 245.00, RefundReason.fraudulent, RefundStatus.processing, PaymentProvider.stripe, DateTime.now().subtract(const Duration(hours: 5)), 'Michael Brown', 'Fraudulent transaction reported'),
      Refund('REF004', 'TXN1237', 56.75, RefundReason.productIssue, RefundStatus.failed, PaymentProvider.square, DateTime.now().subtract(const Duration(days: 1)), 'Sarah Davis', 'Wrong order delivered'),
    ];

    final chargebacks = [
      Chargeback('CB001', 'TXN1238', 450.00, ChargebackReason.unauthorized, ChargebackStatus.underReview, PaymentProvider.stripe, DateTime.now().subtract(const Duration(days: 2)), DateTime.now().add(const Duration(days: 5)), 'David Wilson', 'Customer claims unauthorized charge'),
      Chargeback('CB002', 'TXN1239', 320.50, ChargebackReason.productNotReceived, ChargebackStatus.won, PaymentProvider.square, DateTime.now().subtract(const Duration(days: 10)), DateTime.now().subtract(const Duration(days: 3)), 'Lisa Anderson', 'Delivery confirmed with signature'),
      Chargeback('CB003', 'TXN1240', 185.25, ChargebackReason.productUnacceptable, ChargebackStatus.lost, PaymentProvider.stripe, DateTime.now().subtract(const Duration(days: 15)), DateTime.now().subtract(const Duration(days: 8)), 'Robert Taylor', 'Product quality dispute'),
    ];

    final refundStats = {
      'total': refunds.length,
      'completed': refunds.where((r) => r.status == RefundStatus.completed).length,
      'pending': refunds.where((r) => r.status == RefundStatus.pending || r.status == RefundStatus.processing).length,
      'failed': refunds.where((r) => r.status == RefundStatus.failed).length,
      'amount': refunds.where((r) => r.status == RefundStatus.completed).fold<double>(0, (sum, r) => sum + r.amount),
    };

    final chargebackStats = {
      'total': chargebacks.length,
      'underReview': chargebacks.where((c) => c.status == ChargebackStatus.underReview).length,
      'won': chargebacks.where((c) => c.status == ChargebackStatus.won).length,
      'lost': chargebacks.where((c) => c.status == ChargebackStatus.lost).length,
      'amount': chargebacks.where((c) => c.status == ChargebackStatus.lost).fold<double>(0, (sum, c) => sum + c.amount),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Refunds & Chargebacks'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Refunds', icon: Icon(Icons.keyboard_return)),
            Tab(text: 'Chargebacks', icon: Icon(Icons.warning)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Refunds tab
          _buildRefundsTab(theme, refunds, refundStats),

          // Chargebacks tab
          _buildChargebacksTab(theme, chargebacks, chargebackStats),
        ],
      ),
    );
  }

  Widget _buildRefundsTab(ThemeData theme, List<Refund> refunds, Map<String, dynamic> stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats cards
        Row(
          children: [
            Expanded(
              child: Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: theme.colorScheme.onPrimaryContainer, size: 20),
                          const SizedBox(width: 8),
                          Text('Completed', style: TextStyle(color: theme.colorScheme.onPrimaryContainer, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['completed']}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(stats['amount']),
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7)),
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.hourglass_empty, color: theme.colorScheme.onSecondaryContainer, size: 20),
                          const SizedBox(width: 8),
                          Text('Pending', style: TextStyle(color: theme.colorScheme.onSecondaryContainer, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['pending']}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                      ),
                      Text(
                        'Processing',
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7)),
                      ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.error, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text('Failed', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['failed']}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                      ),
                      Text(
                        'Needs review',
                        style: TextStyle(fontSize: 11, color: Colors.red.shade700.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Refunds list
        Text('Recent Refunds', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...refunds.map((refund) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getRefundStatusColor(refund.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.keyboard_return, color: _getRefundStatusColor(refund.status)),
            ),
            title: Row(
              children: [
                Text(refund.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getRefundStatusColor(refund.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    refund.status.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getRefundStatusColor(refund.status)),
                  ),
                ),
              ],
            ),
            subtitle: Text('${refund.customerName} • ${DateFormat('MMM dd, yyyy h:mm a').format(refund.date)}'),
            trailing: Text(
              NumberFormat.currency(symbol: '\$').format(refund.amount),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Refund ID', refund.id),
                    _buildDetailRow('Transaction ID', refund.transactionId),
                    _buildDetailRow('Customer', refund.customerName),
                    _buildDetailRow('Amount', NumberFormat.currency(symbol: '\$').format(refund.amount)),
                    _buildDetailRow('Reason', _getReasonLabel(refund.reason)),
                    _buildDetailRow('Provider', refund.provider.name.toUpperCase()),
                    _buildDetailRow('Date', DateFormat('MMM dd, yyyy h:mm a').format(refund.date)),
                    _buildDetailRow('Status', refund.status.name.toUpperCase()),
                    if (refund.notes.isNotEmpty) ...[
                      const Divider(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notes', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(refund.notes, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.receipt, size: 18),
                            label: const Text('View Transaction'),
                          ),
                        ),
                        if (refund.status == RefundStatus.failed) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Retry'),
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
        )),
      ],
    );
  }

  Widget _buildChargebacksTab(ThemeData theme, List<Chargeback> chargebacks, Map<String, dynamic> stats) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Stats cards
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.orange.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.gavel, color: Colors.orange.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text('Under Review', style: TextStyle(color: Colors.orange.shade700, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['underReview']}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                      ),
                      Text(
                        'In progress',
                        style: TextStyle(fontSize: 11, color: Colors.orange.shade700.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text('Won', style: TextStyle(color: Colors.green.shade700, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['won']}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                      ),
                      Text(
                        'Resolved',
                        style: TextStyle(fontSize: 11, color: Colors.green.shade700.withOpacity(0.7)),
                      ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.money_off, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Text('Lost', style: TextStyle(color: Colors.red.shade700, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${stats['lost']}',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                      ),
                      Text(
                        NumberFormat.currency(symbol: '\$').format(stats['amount']),
                        style: TextStyle(fontSize: 11, color: Colors.red.shade700.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Chargebacks list
        Text('Chargebacks', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...chargebacks.map((chargeback) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getChargebackStatusColor(chargeback.status).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning, color: _getChargebackStatusColor(chargeback.status)),
            ),
            title: Row(
              children: [
                Text(chargeback.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getChargebackStatusColor(chargeback.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    chargeback.status.name.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getChargebackStatusColor(chargeback.status)),
                  ),
                ),
              ],
            ),
            subtitle: Text('${chargeback.customerName} • ${_getChargebackReasonLabel(chargeback.reason)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat.currency(symbol: '\$').format(chargeback.amount),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                if (chargeback.status == ChargebackStatus.underReview)
                  Text(
                    'Due: ${DateFormat('MMM dd').format(chargeback.dueDate)}',
                    style: const TextStyle(fontSize: 10, color: Colors.orange),
                  ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Chargeback ID', chargeback.id),
                    _buildDetailRow('Transaction ID', chargeback.transactionId),
                    _buildDetailRow('Customer', chargeback.customerName),
                    _buildDetailRow('Amount', NumberFormat.currency(symbol: '\$').format(chargeback.amount)),
                    _buildDetailRow('Reason', _getChargebackReasonLabel(chargeback.reason)),
                    _buildDetailRow('Provider', chargeback.provider.name.toUpperCase()),
                    _buildDetailRow('Filed', DateFormat('MMM dd, yyyy').format(chargeback.date)),
                    if (chargeback.status == ChargebackStatus.underReview)
                      _buildDetailRow('Due Date', DateFormat('MMM dd, yyyy').format(chargeback.dueDate)),
                    _buildDetailRow('Status', chargeback.status.name.toUpperCase()),
                    if (chargeback.notes.isNotEmpty) ...[
                      const Divider(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Notes', style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(chargeback.notes, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.receipt, size: 18),
                            label: const Text('View Transaction'),
                          ),
                        ),
                        if (chargeback.status == ChargebackStatus.underReview) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: const Text('Upload Evidence'),
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
        )),
      ],
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

  Color _getRefundStatusColor(RefundStatus status) {
    switch (status) {
      case RefundStatus.completed: return Colors.green;
      case RefundStatus.pending: return Colors.orange;
      case RefundStatus.processing: return Colors.blue;
      case RefundStatus.failed: return Colors.red;
    }
  }

  Color _getChargebackStatusColor(ChargebackStatus status) {
    switch (status) {
      case ChargebackStatus.underReview: return Colors.orange;
      case ChargebackStatus.won: return Colors.green;
      case ChargebackStatus.lost: return Colors.red;
    }
  }

  String _getReasonLabel(RefundReason reason) {
    switch (reason) {
      case RefundReason.customerRequest: return 'Customer Request';
      case RefundReason.fraudulent: return 'Fraudulent';
      case RefundReason.duplicate: return 'Duplicate';
      case RefundReason.productIssue: return 'Product Issue';
    }
  }

  String _getChargebackReasonLabel(ChargebackReason reason) {
    switch (reason) {
      case ChargebackReason.unauthorized: return 'Unauthorized';
      case ChargebackReason.productNotReceived: return 'Product Not Received';
      case ChargebackReason.productUnacceptable: return 'Product Unacceptable';
    }
  }
}

// Models
class Refund {
  final String id;
  final String transactionId;
  final double amount;
  final RefundReason reason;
  final RefundStatus status;
  final PaymentProvider provider;
  final DateTime date;
  final String customerName;
  final String notes;

  Refund(this.id, this.transactionId, this.amount, this.reason, this.status, this.provider, this.date, this.customerName, this.notes);
}

class Chargeback {
  final String id;
  final String transactionId;
  final double amount;
  final ChargebackReason reason;
  final ChargebackStatus status;
  final PaymentProvider provider;
  final DateTime date;
  final DateTime dueDate;
  final String customerName;
  final String notes;

  Chargeback(this.id, this.transactionId, this.amount, this.reason, this.status, this.provider, this.date, this.dueDate, this.customerName, this.notes);
}

enum RefundStatus { completed, pending, processing, failed }
enum RefundReason { customerRequest, fraudulent, duplicate, productIssue }
enum ChargebackStatus { underReview, won, lost }
enum ChargebackReason { unauthorized, productNotReceived, productUnacceptable }
enum PaymentProvider { stripe, square }
