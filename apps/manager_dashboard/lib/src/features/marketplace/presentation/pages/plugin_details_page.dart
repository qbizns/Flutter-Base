import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_manager/plugin_manager.dart';

/// Detailed view of a single plugin
class PluginDetailsPage extends ConsumerStatefulWidget {
  final MarketplacePlugin plugin;

  const PluginDetailsPage({
    super.key,
    required this.plugin,
  });

  @override
  ConsumerState<PluginDetailsPage> createState() => _PluginDetailsPageState();
}

class _PluginDetailsPageState extends ConsumerState<PluginDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final plugin = widget.plugin;

    return Scaffold(
      appBar: AppBar(
        title: Text(plugin.pluginName),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(context, plugin),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Reviews'),
                Tab(text: 'Support'),
              ],
            ),
            const SizedBox(height: 24),

            // Tab Views
            SizedBox(
              height: 600,
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(plugin),
                  _buildReviewsTab(plugin),
                  _buildSupportTab(plugin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MarketplacePlugin plugin) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        if (plugin.iconUrl != null)
          Image.network(
            plugin.iconUrl!,
            width: 100,
            height: 100,
            errorBuilder: (_, __, ___) => const Icon(Icons.extension, size: 100),
          )
        else
          const Icon(Icons.extension, size: 100),

        const SizedBox(width: 32),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plugin.pluginName,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                plugin.shortDescription,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),

              // Badges and Stats
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildStatChip(
                    context,
                    Icons.star,
                    '${plugin.ratingAverage.toStringAsFixed(1)} (${plugin.ratingCount} reviews)',
                    Colors.amber.shade700,
                  ),
                  _buildStatChip(
                    context,
                    Icons.download,
                    '${plugin.installCount} installs',
                    Colors.blue,
                  ),
                  if (plugin.isVerified)
                    Chip(
                      avatar: const Icon(Icons.verified, size: 16),
                      label: const Text('Verified'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  if (plugin.isFeatured)
                    Chip(
                      avatar: Icon(Icons.star, size: 16, color: Colors.amber.shade700),
                      label: const Text('Featured'),
                      backgroundColor: Colors.amber.shade50,
                    ),
                ],
              ),
            ],
          ),
        ),

        // Install Button
        Column(
          children: [
            SizedBox(
              width: 200,
              height: 50,
              child: FilledButton.icon(
                icon: const Icon(Icons.download),
                label: Text(_getInstallButtonText(plugin)),
                onPressed: () => _installPlugin(plugin),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Version ${plugin.version}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
    );
  }

  Widget _buildOverviewTab(MarketplacePlugin plugin) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description
          if (plugin.longDescription != null) ...[
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text(plugin.longDescription!),
            const SizedBox(height: 24),
          ],

          // Features
          if (plugin.features.isNotEmpty) ...[
            Text(
              'Features',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...plugin.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(feature)),
                    ],
                  ),
                )),
            const SizedBox(height: 24),
          ],

          // Required Permissions
          if (plugin.requiredPermissions.isNotEmpty) ...[
            Text(
              'Required Permissions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ...plugin.requiredPermissions.map((permission) => ListTile(
                  leading: const Icon(Icons.lock_outline, color: Colors.orange),
                  title: Text(permission),
                  dense: true,
                )),
            const SizedBox(height: 24),
          ],

          // Developer Info
          if (plugin.developerName != null) ...[
            Text(
              'Developer',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(plugin.developerName!),
              subtitle: plugin.supportEmail != null ? Text(plugin.supportEmail!) : null,
              dense: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewsTab(MarketplacePlugin plugin) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.rate_review, size: 64),
          SizedBox(height: 16),
          Text('Reviews coming soon...'),
        ],
      ),
    );
  }

  Widget _buildSupportTab(MarketplacePlugin plugin) {
    return ListView(
      children: [
        if (plugin.documentationUrl != null)
          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Documentation'),
            subtitle: Text(plugin.documentationUrl!),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open URL
            },
          ),
        if (plugin.supportEmail != null)
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email Support'),
            subtitle: Text(plugin.supportEmail!),
            trailing: const Icon(Icons.open_in_new),
            onTap: () {
              // Open email
            },
          ),
      ],
    );
  }

  String _getInstallButtonText(MarketplacePlugin plugin) {
    if (plugin.pricingModel == 'free') {
      return 'Install Free';
    }

    final price = plugin.basePrice.toStringAsFixed(2);
    if (plugin.pricingModel == 'monthly') {
      return 'Install - \$$price/mo';
    } else if (plugin.pricingModel == 'yearly') {
      return 'Install - \$$price/yr';
    }

    return 'Install - \$$price';
  }

  Future<void> _installPlugin(MarketplacePlugin plugin) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final service = ref.read(pluginServiceProvider);
      final orgId = ref.read(currentOrganizationIdProvider);

      await service.installPlugin(orgId, plugin.pluginKey);

      ref.invalidate(installedPluginsProvider);

      if (mounted) {
        Navigator.pop(context); // Close loading
        Navigator.pop(context); // Go back

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.pluginName} installed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to install: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
