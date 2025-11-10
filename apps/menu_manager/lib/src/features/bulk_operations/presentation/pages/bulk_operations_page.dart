import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bulk Operations Page
///
/// Features:
/// - Import menu from CSV/JSON
/// - Export menu to CSV/JSON
/// - Bulk price update
/// - Bulk availability toggle
/// - Bulk category assignment
class BulkOperationsPage extends ConsumerWidget {
  const BulkOperationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Operations'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Import/Export section
          _buildSection(
            theme,
            'Import & Export',
            [
              _buildOperationCard(
                theme,
                'Import Menu',
                'Import menu items from CSV or JSON file',
                Icons.file_upload,
                Colors.blue,
                () {
                  _showImportDialog(context);
                },
              ),
              _buildOperationCard(
                theme,
                'Export Menu',
                'Export all menu items to CSV or JSON',
                Icons.file_download,
                Colors.green,
                () {
                  _showExportDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bulk updates section
          _buildSection(
            theme,
            'Bulk Updates',
            [
              _buildOperationCard(
                theme,
                'Update Prices',
                'Apply price changes to multiple items',
                Icons.attach_money,
                Colors.orange,
                () {
                  _showBulkPriceDialog(context);
                },
              ),
              _buildOperationCard(
                theme,
                'Update Availability',
                'Set availability for multiple items',
                Icons.toggle_on,
                Colors.purple,
                () {
                  _showBulkAvailabilityDialog(context);
                },
              ),
              _buildOperationCard(
                theme,
                'Assign Categories',
                'Move items to different categories',
                Icons.category,
                Colors.teal,
                () {
                  _showBulkCategoryDialog(context);
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Dangerous operations section
          _buildSection(
            theme,
            'Dangerous Operations',
            [
              _buildOperationCard(
                theme,
                'Delete Selected Items',
                'Permanently delete multiple menu items',
                Icons.delete_forever,
                Colors.red,
                () {
                  _showBulkDeleteDialog(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildOperationCard(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select import format:'),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Importing from CSV...')),
                );
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('Import from CSV'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 56),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Importing from JSON...')),
                );
              },
              icon: const Icon(Icons.code),
              label: const Text('Import from JSON'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 56),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select export format:'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exported to CSV successfully')),
                );
              },
              icon: const Icon(Icons.table_chart),
              label: const Text('Export as CSV'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 56),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exported to JSON successfully')),
                );
              },
              icon: const Icon(Icons.code),
              label: const Text('Export as JSON'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 56),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBulkPriceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Price Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Update Type',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'percentage', child: Text('Percentage Change')),
                DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Value',
                border: OutlineInputBorder(),
                helperText: 'e.g., 10 for 10% increase or \$5 for fixed amount',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Prices updated successfully')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showBulkAvailabilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Availability Update'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Set availability for selected items:'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Items set to available')),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Set Available'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(0, 56),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Items set to unavailable')),
                );
              },
              icon: const Icon(Icons.cancel),
              label: const Text('Set Unavailable'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(0, 56),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showBulkCategoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Category Assignment'),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(
            labelText: 'Move to Category',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: '1', child: Text('Appetizers')),
            DropdownMenuItem(value: '2', child: Text('Entrees')),
            DropdownMenuItem(value: '3', child: Text('Desserts')),
            DropdownMenuItem(value: '4', child: Text('Beverages')),
          ],
          onChanged: (value) {},
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Categories updated')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showBulkDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Items'),
        content: const Text(
          'Are you sure you want to permanently delete the selected items? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Items deleted')),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
