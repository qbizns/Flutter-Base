import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Payment Providers Page - Manage payment provider integrations
class ProvidersPage extends ConsumerWidget {
  const ProvidersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final providers = [
      PaymentProviderConfig(
        id: 'stripe',
        name: 'Stripe',
        icon: Icons.credit_card,
        color: Colors.purple,
        status: ProviderStatus.connected,
        apiKeySet: true,
        webhookConfigured: true,
        transactionCount: 1842,
        volume: 45890.25,
        fees: 1376.71,
        lastSync: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      PaymentProviderConfig(
        id: 'square',
        name: 'Square',
        icon: Icons.square,
        color: Colors.black,
        status: ProviderStatus.connected,
        apiKeySet: true,
        webhookConfigured: true,
        transactionCount: 956,
        volume: 28450.75,
        fees: 853.52,
        lastSync: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
      PaymentProviderConfig(
        id: 'paypal',
        name: 'PayPal',
        icon: Icons.payment,
        color: Colors.blue,
        status: ProviderStatus.disconnected,
        apiKeySet: false,
        webhookConfigured: false,
        transactionCount: 0,
        volume: 0,
        fees: 0,
        lastSync: null,
      ),
      PaymentProviderConfig(
        id: 'clover',
        name: 'Clover',
        icon: Icons.point_of_sale,
        color: Colors.green,
        status: ProviderStatus.error,
        apiKeySet: true,
        webhookConfigured: false,
        transactionCount: 245,
        volume: 8920.50,
        fees: 267.62,
        lastSync: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    final connectedProviders = providers.where((p) => p.status == ProviderStatus.connected).length;
    final totalVolume = providers.fold<double>(0, (sum, p) => sum + p.volume);
    final totalFees = providers.fold<double>(0, (sum, p) => sum + p.fees);

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Providers')),
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
                        Text('Connected', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                        const SizedBox(height: 8),
                        Text(
                          '$connectedProviders/${providers.length}',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                        ),
                        Text('Providers', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
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
                        Text('Total Volume', style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(totalVolume),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                        ),
                        Text('This month', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: theme.colorScheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Fees', style: TextStyle(color: theme.colorScheme.onTertiaryContainer)),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat.currency(symbol: '\$').format(totalFees),
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.onTertiaryContainer),
                        ),
                        Text('${((totalFees / totalVolume) * 100).toStringAsFixed(2)}% rate', style: TextStyle(fontSize: 12, color: theme.colorScheme.onTertiaryContainer.withOpacity(0.7))),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Providers list
          Text('Payment Providers', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...providers.map((provider) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: provider.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(provider.icon, color: provider.color, size: 28),
              ),
              title: Row(
                children: [
                  Text(provider.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(provider.status).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      provider.status.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(provider.status),
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: provider.status == ProviderStatus.connected
                  ? Text('${NumberFormat.compact().format(provider.transactionCount)} transactions • ${NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(provider.volume)} volume')
                  : Text(provider.status == ProviderStatus.error ? 'Connection error - check configuration' : 'Not configured'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Configuration status
                      _buildConfigRow(
                        'API Credentials',
                        provider.apiKeySet ? 'Configured' : 'Not Set',
                        provider.apiKeySet ? Icons.check_circle : Icons.cancel,
                        provider.apiKeySet ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      _buildConfigRow(
                        'Webhook',
                        provider.webhookConfigured ? 'Active' : 'Not Configured',
                        provider.webhookConfigured ? Icons.check_circle : Icons.cancel,
                        provider.webhookConfigured ? Colors.green : Colors.orange,
                      ),

                      if (provider.status == ProviderStatus.connected) ...[
                        const Divider(height: 24),

                        // Stats
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Transactions', style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4),
                                  Text(
                                    NumberFormat.decimalPattern().format(provider.transactionCount),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Volume', style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4),
                                  Text(
                                    NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(provider.volume),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Fees', style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 4),
                                  Text(
                                    NumberFormat.currency(symbol: '\$').format(provider.fees),
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),
                        if (provider.lastSync != null)
                          Text(
                            'Last synced ${_formatRelativeTime(provider.lastSync!)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                      ],

                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        children: [
                          if (provider.status == ProviderStatus.disconnected) ...[
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.link, size: 18),
                                label: const Text('Connect'),
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.settings, size: 18),
                                label: const Text('Configure'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.sync, size: 18),
                                label: const Text('Sync Now'),
                              ),
                            ),
                          ],
                          if (provider.status != ProviderStatus.disconnected) ...[
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('Disconnect'),
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
      ),
    );
  }

  Widget _buildConfigRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const Spacer(),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Color _getStatusColor(ProviderStatus status) {
    switch (status) {
      case ProviderStatus.connected: return Colors.green;
      case ProviderStatus.disconnected: return Colors.grey;
      case ProviderStatus.error: return Colors.red;
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}

class PaymentProviderConfig {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final ProviderStatus status;
  final bool apiKeySet;
  final bool webhookConfigured;
  final int transactionCount;
  final double volume;
  final double fees;
  final DateTime? lastSync;

  PaymentProviderConfig({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.status,
    required this.apiKeySet,
    required this.webhookConfigured,
    required this.transactionCount,
    required this.volume,
    required this.fees,
    this.lastSync,
  });
}

enum ProviderStatus { connected, disconnected, error }
