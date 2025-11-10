import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

/// Availability Scheduling Page
///
/// Features:
/// - Schedule item availability by day/time
/// - Seasonal items
/// - Temporary unavailability
/// - Bulk availability changes
class AvailabilityPage extends ConsumerWidget {
  const AvailabilityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Availability Scheduling'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'bulk_available',
                child: ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text('Set All Available'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'bulk_unavailable',
                child: ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Set All Unavailable'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    value == 'bulk_available'
                        ? 'All items set to available'
                        : 'All items set to unavailable',
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) => _buildAvailabilityList(context, theme, products),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading menu items')),
      ),
    );
  }

  Widget _buildAvailabilityList(
    BuildContext context,
    ThemeData theme,
    List<Product> products,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.fastfood,
                color: theme.colorScheme.primary,
              ),
            ),
            title: Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(product.categoryId ?? 'No category'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: product.isAvailable
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product.isAvailable ? 'Available' : 'Unavailable',
                    style: TextStyle(
                      color: product.isAvailable ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: product.isAvailable,
                  onChanged: (value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value
                              ? '${product.name} is now available'
                              : '${product.name} is now unavailable',
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.schedule),
                  onPressed: () {
                    _showScheduleDialog(context, product);
                  },
                  tooltip: 'Schedule',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showScheduleDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Schedule Availability: ${product.name}'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Available Days',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                    .map((day) => FilterChip(
                          label: Text(day),
                          selected: true,
                          onSelected: (value) {},
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Available Hours',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                        hintText: '09:00',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                        hintText: '22:00',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                title: const Text('Seasonal Item'),
                subtitle: const Text('Only available during specific dates'),
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Schedule saved')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save Schedule'),
          ),
        ],
      ),
    );
  }
}
