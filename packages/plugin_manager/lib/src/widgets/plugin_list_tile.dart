import 'package:flutter/material.dart';
import '../models/marketplace_plugin.dart';

/// A list tile widget for installed plugins
class PluginListTile extends StatelessWidget {
  final OrganizationPlugin plugin;
  final VoidCallback? onTap;
  final VoidCallback? onConfigure;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onUninstall;

  const PluginListTile({
    super.key,
    required this.plugin,
    this.onTap,
    this.onConfigure,
    this.onToggle,
    this.onUninstall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final marketplacePlugin = plugin.plugin;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: _buildIcon(context),
        title: Row(
          children: [
            Expanded(
              child: Text(
                marketplacePlugin.pluginName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            _buildStatusChip(context),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(marketplacePlugin.shortDescription),
            const SizedBox(height: 8),
            _buildMetadata(context),
            if (plugin.healthStatus != 'healthy') ...[
              const SizedBox(height: 8),
              _buildHealthWarning(context),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Enable/Disable Switch
            Switch(
              value: plugin.isEnabled,
              onChanged: onToggle,
            ),
            const SizedBox(width: 8),
            // More Options
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'configure':
                    onConfigure?.call();
                    break;
                  case 'uninstall':
                    onUninstall?.call();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'configure',
                  child: Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8),
                      Text('Configure'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'uninstall',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Uninstall', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (plugin.plugin.iconUrl != null && plugin.plugin.iconUrl!.isNotEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            plugin.plugin.iconUrl!,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.extension, size: 28),
          ),
        ),
      );
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: const Icon(Icons.extension, size: 28),
    );
  }

  Widget _buildStatusChip(BuildContext context) {
    Color color;
    String label;

    switch (plugin.status) {
      case 'active':
        color = Colors.green;
        label = 'Active';
        break;
      case 'paused':
        color = Colors.orange;
        label = 'Paused';
        break;
      case 'error':
        color = Colors.red;
        label = 'Error';
        break;
      default:
        color = Colors.grey;
        label = plugin.status;
    }

    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      backgroundColor: color.shade50,
      side: BorderSide(color: color.shade200),
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
    );
  }

  Widget _buildMetadata(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.info_outline,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'v${plugin.plugin.version}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today,
              size: 14,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              'Installed ${_formatDate(plugin.installedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        if (plugin.lastSyncAt != null)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.sync,
                size: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Last sync ${_formatDate(plugin.lastSyncAt!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildHealthWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              plugin.healthMessage ?? 'Plugin is experiencing issues',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
  }
}
