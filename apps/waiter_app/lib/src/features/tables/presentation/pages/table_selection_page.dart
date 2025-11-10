import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

/// Table Selection Page - Main screen for waiters to select tables
///
/// Features:
/// - Visual table grid with status indicators
/// - Zone filtering
/// - Quick table info
/// - Navigate to order taking or active orders
class TableSelectionPage extends ConsumerStatefulWidget {
  const TableSelectionPage({super.key});

  @override
  ConsumerState<TableSelectionPage> createState() => _TableSelectionPageState();
}

class _TableSelectionPageState extends ConsumerState<TableSelectionPage> {
  String? _selectedZoneId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tablesAsync = ref.watch(tablesProvider(zoneId: _selectedZoneId));
    final zonesAsync = ref.watch(zonesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(tablesProvider);
              ref.invalidate(zonesProvider);
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.receipt_long),
            onPressed: () => context.go('/orders'),
            tooltip: 'All Orders',
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone selector
          zonesAsync.when(
            data: (zones) => ZoneSelector(
              zones: zones,
              selectedZoneId: _selectedZoneId,
              onZoneSelected: (zoneId) {
                setState(() {
                  _selectedZoneId = zoneId;
                });
              },
            ),
            loading: () => const SizedBox(height: 56),
            error: (_, __) => const SizedBox(height: 56),
          ),

          const Divider(height: 1),

          // Tables grid
          Expanded(
            child: tablesAsync.when(
              data: (tables) {
                if (tables.isEmpty) {
                  return _buildEmptyState(context);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(tablesProvider);
                  },
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      return _buildTableCard(context, table);
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading tables',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(tablesProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/orders'),
        icon: const Icon(Icons.list_alt),
        label: const Text('My Orders'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant_outlined,
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No Tables',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedZoneId == null
                ? 'No tables available'
                : 'No tables in this zone',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableCard(BuildContext context, Table table) {
    final theme = Theme.of(context);

    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (table.status) {
      case TableStatus.available:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Available';
        break;
      case TableStatus.occupied:
        statusColor = Colors.orange;
        statusIcon = Icons.people;
        statusText = 'Occupied';
        break;
      case TableStatus.reserved:
        statusColor = Colors.blue;
        statusIcon = Icons.bookmark;
        statusText = 'Reserved';
        break;
      case TableStatus.cleaning:
        statusColor = Colors.grey;
        statusIcon = Icons.cleaning_services;
        statusText = 'Cleaning';
        break;
      case TableStatus.blocked:
        statusColor = Colors.red;
        statusIcon = Icons.block;
        statusText = 'Blocked';
        break;
    }

    return Card(
      elevation: table.status == TableStatus.occupied ? 4 : 2,
      child: InkWell(
        onTap: () => _handleTableTap(context, table),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Table number
              Text(
                'Table ${table.number}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Capacity
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${table.capacity} seats',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Status chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 16, color: statusColor),
                    const SizedBox(width: 6),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTableTap(BuildContext context, Table table) {
    switch (table.status) {
      case TableStatus.available:
      case TableStatus.reserved:
        // Start new order
        context.go('/table/${table.id}/order');
        break;
      case TableStatus.occupied:
        // Show active order or add to existing
        _showTableOptions(context, table);
        break;
      case TableStatus.cleaning:
      case TableStatus.blocked:
        // Show info dialog
        _showTableInfo(context, table);
        break;
    }
  }

  void _showTableOptions(BuildContext context, Table table) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: const Text('View Current Order'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to current order
                context.go('/table/${table.id}/current-order');
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle),
              title: const Text('Add More Items'),
              onTap: () {
                Navigator.pop(context);
                context.go('/table/${table.id}/order');
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Request Bill'),
              onTap: () {
                Navigator.pop(context);
                context.go('/table/${table.id}/checkout');
              },
            ),
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: const Text('Transfer Table'),
              onTap: () {
                Navigator.pop(context);
                _showTableTransfer(context, table);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showTableInfo(BuildContext context, Table table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Table ${table.number}'),
        content: Text(
          table.status == TableStatus.cleaning
              ? 'This table is currently being cleaned.'
              : 'This table is blocked and unavailable.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTableTransfer(BuildContext context, Table fromTable) {
    // TODO: Implement table transfer dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Table transfer feature coming soon')),
    );
  }
}
