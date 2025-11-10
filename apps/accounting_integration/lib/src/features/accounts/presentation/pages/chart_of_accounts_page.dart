import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chart of Accounts - Map POS accounts to accounting system
class ChartOfAccountsPage extends ConsumerWidget {
  const ChartOfAccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Mock account mappings
    final accountMappings = [
      AccountMapping('Sales Revenue', '4000', AccountCategory.revenue, 'Revenue:Sales', MappingStatus.mapped, AccountingProvider.quickbooks),
      AccountMapping('Cost of Goods Sold', '5000', AccountCategory.expense, 'Cost of Goods Sold', MappingStatus.mapped, AccountingProvider.quickbooks),
      AccountMapping('Payment Processing Fees', '6100', AccountCategory.expense, 'Expenses:Banking:Merchant Fees', MappingStatus.mapped, AccountingProvider.quickbooks),
      AccountMapping('Cash Register', '1010', AccountCategory.asset, 'Assets:Current Assets:Cash', MappingStatus.mapped, AccountingProvider.xero),
      AccountMapping('Accounts Receivable', '1200', AccountCategory.asset, 'Assets:Current Assets:AR', MappingStatus.mapped, AccountingProvider.xero),
      AccountMapping('Inventory', '1300', AccountCategory.asset, 'Assets:Current Assets:Inventory', MappingStatus.mapped, AccountingProvider.quickbooks),
      AccountMapping('Sales Tax Payable', '2100', AccountCategory.liability, 'Liabilities:Current Liabilities:Sales Tax', MappingStatus.mapped, AccountingProvider.quickbooks),
      AccountMapping('Gift Card Liability', '2150', AccountCategory.liability, null, MappingStatus.unmapped, null),
      AccountMapping('Staff Wages', '6200', AccountCategory.expense, 'Expenses:Payroll:Wages', MappingStatus.mapped, AccountingProvider.quickbooks),
      AccountMapping('Rent Expense', '6300', AccountCategory.expense, 'Expenses:Rent', MappingStatus.mapped, AccountingProvider.quickbooks),
      AccountMapping('Utilities', '6400', AccountCategory.expense, null, MappingStatus.unmapped, null),
      AccountMapping('Marketing', '6500', AccountCategory.expense, 'Expenses:Marketing', MappingStatus.mapped, AccountingProvider.xero),
    ];

    final mappedCount = accountMappings.where((a) => a.status == MappingStatus.mapped).length;
    final unmappedCount = accountMappings.where((a) => a.status == MappingStatus.unmapped).length;
    final revenueAccounts = accountMappings.where((a) => a.category == AccountCategory.revenue).length;
    final expenseAccounts = accountMappings.where((a) => a.category == AccountCategory.expense).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Chart of Accounts')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
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
                        Row(
                          children: [
                            Icon(Icons.link, color: theme.colorScheme.onPrimaryContainer, size: 20),
                            const SizedBox(width: 8),
                            Text('Mapped', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$mappedCount/${accountMappings.length}',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                        ),
                        Text('Accounts', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Unmapped', style: TextStyle(color: Colors.orange.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$unmappedCount',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                        ),
                        Text('Needs mapping', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
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
                            Icon(Icons.trending_up, color: Colors.green.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Revenue', style: TextStyle(color: Colors.green.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$revenueAccounts',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                        ),
                        Text('Accounts', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
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
                            Icon(Icons.trending_down, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text('Expenses', style: TextStyle(color: Colors.red.shade700)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$expenseAccounts',
                          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                        ),
                        Text('Accounts', style: TextStyle(fontSize: 12, color: Colors.red.shade700.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Account categories
          ..._buildAccountSection(theme, 'Revenue Accounts', AccountCategory.revenue, accountMappings),
          const SizedBox(height: 16),
          ..._buildAccountSection(theme, 'Asset Accounts', AccountCategory.asset, accountMappings),
          const SizedBox(height: 16),
          ..._buildAccountSection(theme, 'Liability Accounts', AccountCategory.liability, accountMappings),
          const SizedBox(height: 16),
          ..._buildAccountSection(theme, 'Expense Accounts', AccountCategory.expense, accountMappings),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Add Mapping'),
      ),
    );
  }

  List<Widget> _buildAccountSection(ThemeData theme, String title, AccountCategory category, List<AccountMapping> allMappings) {
    final categoryMappings = allMappings.where((a) => a.category == category).toList();

    return [
      Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      ...categoryMappings.map((mapping) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _getCategoryColor(mapping.category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(_getCategoryIcon(mapping.category), color: _getCategoryColor(mapping.category), size: 20),
          ),
          title: Row(
            children: [
              Text(mapping.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(mapping.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  mapping.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(mapping.status),
                  ),
                ),
              ),
            ],
          ),
          subtitle: Text('Account #${mapping.accountCode} • ${mapping.category.name.toUpperCase()}'),
          trailing: mapping.status == MappingStatus.mapped
              ? Icon(Icons.check_circle, color: Colors.green.shade700)
              : Icon(Icons.warning, color: Colors.orange.shade700),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Account Name', mapping.name),
                  _buildInfoRow('Account Code', mapping.accountCode),
                  _buildInfoRow('Category', mapping.category.name.toUpperCase()),
                  _buildInfoRow('Status', mapping.status.name.toUpperCase()),
                  if (mapping.externalAccount != null) ...[
                    const Divider(height: 24),
                    _buildInfoRow('Provider', mapping.provider!.name.toUpperCase()),
                    _buildInfoRow('External Account', mapping.externalAccount!),
                  ] else ...[
                    const Divider(height: 24),
                    Text('Not mapped', style: TextStyle(color: Colors.orange.shade700, fontWeight: FontWeight.w600)),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      if (mapping.status == MappingStatus.mapped) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Edit Mapping'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.link_off, size: 18),
                            label: const Text('Unmap'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ),
                      ] else ...[
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.link, size: 18),
                            label: const Text('Map Account'),
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
    ];
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

  Color _getCategoryColor(AccountCategory category) {
    switch (category) {
      case AccountCategory.asset: return Colors.blue;
      case AccountCategory.liability: return Colors.red;
      case AccountCategory.revenue: return Colors.green;
      case AccountCategory.expense: return Colors.orange;
    }
  }

  IconData _getCategoryIcon(AccountCategory category) {
    switch (category) {
      case AccountCategory.asset: return Icons.account_balance_wallet;
      case AccountCategory.liability: return Icons.credit_card;
      case AccountCategory.revenue: return Icons.trending_up;
      case AccountCategory.expense: return Icons.trending_down;
    }
  }

  Color _getStatusColor(MappingStatus status) {
    switch (status) {
      case MappingStatus.mapped: return Colors.green;
      case MappingStatus.unmapped: return Colors.orange;
    }
  }
}

// Models
class AccountMapping {
  final String name;
  final String accountCode;
  final AccountCategory category;
  final String? externalAccount;
  final MappingStatus status;
  final AccountingProvider? provider;

  AccountMapping(this.name, this.accountCode, this.category, this.externalAccount, this.status, this.provider);
}

enum AccountCategory { asset, liability, revenue, expense }
enum MappingStatus { mapped, unmapped }
enum AccountingProvider { quickbooks, xero, sage }
