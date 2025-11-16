import 'package:flutter/material.dart';
import '../models/marketplace_plugin.dart';

/// A card widget displaying plugin information
class PluginCard extends StatelessWidget {
  final MarketplacePlugin plugin;
  final VoidCallback? onTap;
  final VoidCallback? onInstall;
  final bool showInstallButton;

  const PluginCard({
    super.key,
    required this.plugin,
    this.onTap,
    this.onInstall,
    this.showInstallButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plugin Icon
              _buildIcon(context),
              const SizedBox(height: 12),

              // Plugin Name
              Text(
                plugin.pluginName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),

              // Short Description
              Expanded(
                child: Text(
                  plugin.shortDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 12),

              // Badges Row (Verified, Featured)
              _buildBadges(context),
              const SizedBox(height: 8),

              // Rating and Installs
              _buildStatsRow(context),
              const SizedBox(height: 12),

              // Price and Install Button
              _buildActionRow(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    if (plugin.iconUrl != null && plugin.iconUrl!.isNotEmpty) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceVariant,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            plugin.iconUrl!,
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const Icon(Icons.extension, size: 32),
          ),
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surfaceVariant,
      ),
      child: const Icon(Icons.extension, size: 32),
    );
  }

  Widget _buildBadges(BuildContext context) {
    if (!plugin.isVerified && !plugin.isFeatured) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      children: [
        if (plugin.isVerified)
          Chip(
            avatar: Icon(
              Icons.verified,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            label: const Text('Verified', style: TextStyle(fontSize: 11)),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
        if (plugin.isFeatured)
          Chip(
            avatar: Icon(
              Icons.star,
              size: 16,
              color: Colors.amber.shade700,
            ),
            label: const Text('Featured', style: TextStyle(fontSize: 11)),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
          ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        // Rating
        Icon(
          Icons.star,
          color: Colors.amber.shade700,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          plugin.ratingAverage.toStringAsFixed(1),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(width: 4),
        Text(
          '(${plugin.ratingCount})',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const Spacer(),
        // Install Count
        const Icon(Icons.download, size: 16),
        const SizedBox(width: 4),
        Text(
          _formatInstallCount(plugin.installCount),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildActionRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Price
        _buildPriceTag(context),

        // Install/View Button
        if (showInstallButton)
          FilledButton.tonalIcon(
            onPressed: onInstall ?? onTap,
            icon: const Icon(Icons.download, size: 16),
            label: const Text('Install'),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          )
        else
          TextButton(
            onPressed: onTap,
            child: const Text('View Details'),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
            ),
          ),
      ],
    );
  }

  Widget _buildPriceTag(BuildContext context) {
    if (plugin.pricingModel == 'free') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Text(
          'FREE',
          style: TextStyle(
            color: Colors.green.shade700,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      );
    }

    String priceText = '\$${plugin.basePrice.toStringAsFixed(2)}';
    if (plugin.pricingModel == 'monthly') {
      priceText += '/mo';
    } else if (plugin.pricingModel == 'yearly') {
      priceText += '/yr';
    } else if (plugin.pricingModel == 'per_transaction') {
      priceText = '${plugin.basePrice.toStringAsFixed(1)}%';
    }

    return Text(
      priceText,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  String _formatInstallCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }
}
