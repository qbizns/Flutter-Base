import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Invoices - Track supplier invoices and payments
class InvoicesPage extends ConsumerStatefulWidget {
  const InvoicesPage({super.key});

  @override
  ConsumerState<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends ConsumerState<InvoicesPage> {
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final invoices = [
      Invoice('INV-2024-089', 'Fresh Foods Suppliers', 'PO-2024-001', DateTime.now().subtract(const Duration(days: 5)), DateTime.now().add(const Duration(days: 25)), 4520.50, InvoiceStatus.unpaid),
      Invoice('INV-2024-090', 'Beverage Distributors Inc', 'PO-2024-002', DateTime.now().subtract(const Duration(days: 2)), DateTime.now().add(const Duration(days: 58)), 3240.75, InvoiceStatus.unpaid),
      Invoice('INV-2024-088', 'Restaurant Equipment Co', 'PO-2024-003', DateTime.now().subtract(const Duration(days: 12)), DateTime.now().subtract(const Duration(days: 2)), 12890.00, InvoiceStatus.paid),
      Invoice('INV-2024-091', 'Office Supplies Direct', 'PO-2024-005', DateTime.now().subtract(const Duration(days: 1)), DateTime.now().add(const Duration(days: 29)), 680.50, InvoiceStatus.unpaid),
      Invoice('INV-2024-087', 'Fresh Foods Suppliers', 'PO-2023-348', DateTime.now().subtract(const Duration(days: 45)), DateTime.now().subtract(const Duration(days: 15)), 2850.25, InvoiceStatus.overdue),
    ];

    final filteredInvoices = invoices.where((inv) {
      if (_selectedStatus != 'All' && inv.status.name != _selectedStatus.toLowerCase()) return false;
      return true;
    }).toList();

    final unpaidCount = invoices.where((i) => i.status == InvoiceStatus.unpaid).length;
    final overdueCount = invoices.where((i) => i.status == InvoiceStatus.overdue).length;
    final unpaidAmount = invoices.where((i) => i.status == InvoiceStatus.unpaid || i.status == InvoiceStatus.overdue).fold<double>(0, (sum, i) => sum + i.amount);
    final paidAmount = invoices.where((i) => i.status == InvoiceStatus.paid).fold<double>(0, (sum, i) => sum + i.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Supplier Invoices')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.pending_actions, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Unpaid', style: TextStyle(color: Colors.orange.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$unpaidCount', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange.shade700)),
                          Text(NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(unpaidAmount), style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Overdue', style: TextStyle(color: Colors.red.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$overdueCount', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                          Text('Action required', style: TextStyle(fontSize: 12, color: Colors.red.shade700.withOpacity(0.7))),
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
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Paid', style: TextStyle(color: Colors.green.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(paidAmount), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          Text('This month', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: ['All', 'Unpaid', 'Paid', 'Overdue']
                  .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedStatus = value!),
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredInvoices.length,
              itemBuilder: (context, index) {
                final invoice = filteredInvoices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getStatusColor(invoice.status).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.receipt_long, color: _getStatusColor(invoice.status), size: 20),
                    ),
                    title: Row(
                      children: [
                        Text(invoice.id, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(invoice.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            invoice.status.name.toUpperCase(),
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getStatusColor(invoice.status)),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('${invoice.vendor} • Due: ${DateFormat('MMM dd, yyyy').format(invoice.dueDate)}'),
                    trailing: Text(
                      NumberFormat.currency(symbol: '\$').format(invoice.amount),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow('Invoice Number', invoice.id),
                            _buildInfoRow('Vendor', invoice.vendor),
                            _buildInfoRow('PO Reference', invoice.poRef),
                            _buildInfoRow('Amount', NumberFormat.currency(symbol: '\$').format(invoice.amount)),
                            _buildInfoRow('Invoice Date', DateFormat('MMM dd, yyyy').format(invoice.invoiceDate)),
                            _buildInfoRow('Due Date', DateFormat('MMM dd, yyyy').format(invoice.dueDate)),
                            _buildInfoRow('Status', invoice.status.name.toUpperCase()),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                if (invoice.status == InvoiceStatus.unpaid || invoice.status == InvoiceStatus.overdue) ...[
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: () {},
                                      icon: const Icon(Icons.payment, size: 18),
                                      label: const Text('Pay Now'),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.download, size: 18),
                                    label: const Text('Download'),
                                  ),
                                ),
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

  Color _getStatusColor(InvoiceStatus status) {
    switch (status) {
      case InvoiceStatus.unpaid: return Colors.orange;
      case InvoiceStatus.paid: return Colors.green;
      case InvoiceStatus.overdue: return Colors.red;
    }
  }
}

class Invoice {
  final String id;
  final String vendor;
  final String poRef;
  final DateTime invoiceDate;
  final DateTime dueDate;
  final double amount;
  final InvoiceStatus status;

  Invoice(this.id, this.vendor, this.poRef, this.invoiceDate, this.dueDate, this.amount, this.status);
}

enum InvoiceStatus { unpaid, paid, overdue }
