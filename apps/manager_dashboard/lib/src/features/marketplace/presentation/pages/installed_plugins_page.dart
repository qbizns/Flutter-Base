import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plugin_manager/plugin_manager.dart';

/// Page showing all installed plugins for the organization
class InstalledPluginsPage extends ConsumerWidget {
  const InstalledPluginsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pluginsAsync = ref.watch(installedPluginsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Plugins'),
        actions: [
          IconButton(
            icon: const Icon(Icons.store),
            tooltip: 'Browse Marketplace',
            onPressed: () {
              Navigator.pushNamed(context, '/marketplace');
            },
          ),
        ],
      ),
      body: pluginsAsync.when(
        data: (plugins) {
          if (plugins.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.extension_off,
                    size: 80,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No plugins installed',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Browse the marketplace to install plugins',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    icon: const Icon(Icons.store),
                    label: const Text('Browse Marketplace'),
                    onPressed: () {
                      Navigator.pushNamed(context, '/marketplace');
                    },
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plugins.length,
            itemBuilder: (context, index) {
              final plugin = plugins[index];

              return PluginListTile(
                plugin: plugin,
                onTap: () {
                  // Navigate to plugin details
                },
                onToggle: (enabled) async {
                  await _togglePlugin(ref, plugin, enabled);
                },
                onConfigure: () async {
                  await _showConfigDialog(context, ref, plugin);
                },
                onUninstall: () async {
                  await _confirmUninstall(context, ref, plugin);
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                onPressed: () => ref.invalidate(installedPluginsProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _togglePlugin(
    WidgetRef ref,
    OrganizationPlugin plugin,
    bool enabled,
  ) async {
    try {
      final service = ref.read(pluginServiceProvider);
      final orgId = ref.read(currentOrganizationIdProvider);

      await service.updatePluginConfig(
        orgId,
        plugin.id,
        plugin.config,
        isEnabled: enabled,
      );

      ref.invalidate(installedPluginsProvider);
    } catch (e) {
      // Error handling done by UI
    }
  }

  Future<void> _showConfigDialog(
    BuildContext context,
    WidgetRef ref,
    OrganizationPlugin plugin,
  ) async {
    // TODO: Implement configuration dialog based on plugin's config schema
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Configure ${plugin.plugin.pluginName}'),
        content: const Text('Configuration UI coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmUninstall(
    BuildContext context,
    WidgetRef ref,
    OrganizationPlugin plugin,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Uninstall ${plugin.plugin.pluginName}?'),
        content: const Text(
          'This will remove the plugin and all its data. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Uninstall'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final service = ref.read(pluginServiceProvider);
        final orgId = ref.read(currentOrganizationIdProvider);

        await service.uninstallPlugin(orgId, plugin.id);
        ref.invalidate(installedPluginsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${plugin.plugin.pluginName} uninstalled'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to uninstall: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
