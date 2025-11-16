import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_manager/plugin_manager.dart';

import '../widgets/category_sidebar.dart';
import '../widgets/marketplace_search_bar.dart';
import 'plugin_details_page.dart';

/// Main marketplace page for browsing and discovering plugins
class MarketplacePage extends ConsumerStatefulWidget {
  const MarketplacePage({super.key});

  @override
  ConsumerState<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends ConsumerState<MarketplacePage> {
  String? _selectedCategory;
  String _searchQuery = '';
  bool _showFeaturedOnly = false;
  bool _showVerifiedOnly = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin Marketplace'),
        actions: [
          // Featured Filter
          Tooltip(
            message: 'Show featured plugins only',
            child: FilterChip(
              label: const Text('Featured'),
              selected: _showFeaturedOnly,
              onSelected: (selected) {
                setState(() => _showFeaturedOnly = selected);
              },
              avatar: Icon(
                Icons.star,
                size: 18,
                color: _showFeaturedOnly ? Colors.amber.shade700 : null,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Verified Filter
          Tooltip(
            message: 'Show verified plugins only',
            child: FilterChip(
              label: const Text('Verified'),
              selected: _showVerifiedOnly,
              onSelected: (selected) {
                setState(() => _showVerifiedOnly = selected);
              },
              avatar: Icon(
                Icons.verified,
                size: 18,
                color: _showVerifiedOnly ? Colors.blue : null,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Installed Plugins Button
          IconButton(
            icon: const Icon(Icons.folder_special),
            tooltip: 'My Plugins',
            onPressed: () {
              Navigator.pushNamed(context, '/marketplace/installed');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Category Sidebar
          SizedBox(
            width: 250,
            child: CategorySidebar(
              selectedCategory: _selectedCategory,
              onCategorySelected: (category) {
                setState(() => _selectedCategory = category);
              },
            ),
          ),

          const VerticalDivider(width: 1),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: MarketplaceSearchBar(
                    onSearchChanged: (query) {
                      setState(() => _searchQuery = query);
                    },
                  ),
                ),

                // Plugin Grid
                Expanded(
                  child: _buildPluginGrid(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginGrid() {
    final filters = MarketplaceFilters(
      category: _selectedCategory,
      search: _searchQuery.isEmpty ? null : _searchQuery,
      isFeatured: _showFeaturedOnly ? true : null,
      isVerified: _showVerifiedOnly ? true : null,
    );

    return PluginMarketplaceGrid(
      filters: filters,
      crossAxisCount: _getCrossAxisCount(context),
      onPluginTap: (plugin) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PluginDetailsPage(plugin: plugin),
          ),
        );
      },
      onPluginInstall: (plugin) async {
        await _showInstallDialog(plugin);
      },
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width - 250; // Subtract sidebar
    if (width > 1400) return 4;
    if (width > 1000) return 3;
    if (width > 600) return 2;
    return 1;
  }

  Future<void> _showInstallDialog(MarketplacePlugin plugin) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Install ${plugin.pluginName}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(plugin.shortDescription),
            const SizedBox(height: 16),

            if (plugin.requiredPermissions.isNotEmpty) ...[
              const Text(
                'This plugin requires the following permissions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...plugin.requiredPermissions.map(
                (permission) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(child: Text(permission)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (plugin.pricingModel != 'free') ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _getPricingText(plugin),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Install'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _installPlugin(plugin);
    }
  }

  Future<void> _installPlugin(MarketplacePlugin plugin) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      final service = ref.read(pluginServiceProvider);
      final orgId = ref.read(currentOrganizationIdProvider);

      await service.installPlugin(orgId, plugin.pluginKey);

      // Refresh installed plugins
      ref.invalidate(installedPluginsProvider);

      if (mounted) {
        // Close loading
        Navigator.pop(context);

        // Show success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${plugin.pluginName} installed successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Configure',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/marketplace/installed');
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Close loading
        Navigator.pop(context);

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to install plugin: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getPricingText(MarketplacePlugin plugin) {
    final price = plugin.basePrice.toStringAsFixed(2);

    switch (plugin.pricingModel) {
      case 'monthly':
        return '\$$price per month';
      case 'yearly':
        return '\$$price per year';
      case 'per_transaction':
        return '${plugin.basePrice.toStringAsFixed(1)}% per transaction';
      case 'tier_based':
        return 'Starts at \$$price';
      default:
        return '\$$price';
    }
  }
}
