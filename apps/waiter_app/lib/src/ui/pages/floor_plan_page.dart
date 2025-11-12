/// Floor Plan Page
/// Main view showing restaurant floor with table layout
/// Following Odoo POS floor plan patterns
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/waiter_models.dart';
import '../../data/providers.dart';
import '../widgets/table_card.dart';

/// Floor Plan Page
/// Grid view of all tables on selected floor
class FloorPlanPage extends ConsumerStatefulWidget {
  const FloorPlanPage({super.key});

  @override
  ConsumerState<FloorPlanPage> createState() => _FloorPlanPageState();
}

class _FloorPlanPageState extends ConsumerState<FloorPlanPage> {
  TableStatus? _filterStatus;
  bool _showOnlyMyTables = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch providers
    final floorsAsync = ref.watch(floorsProvider);
    final selectedFloor = ref.watch(selectedFloorProvider);
    final currentWaiter = ref.watch(currentWaiterProvider);
    final isConnected = ref.watch(isConnectedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Floor Plan'),
            if (currentWaiter != null)
              Text(
                currentWaiter.name,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
          ],
        ),
        actions: [
          // Connection status indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isConnected
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isConnected ? Icons.cloud_done : Icons.cloud_off,
                      size: 16,
                      color: isConnected ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isConnected ? 'Live' : 'Offline',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isConnected ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Active orders badge
          IconButton(
            icon: const Badge(
              label: Text('3'),
              child: Icon(Icons.receipt_long),
            ),
            onPressed: () {
              context.push('/orders');
            },
            tooltip: 'Active Orders',
          ),

          // Settings/Profile
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              // TODO: Show waiter profile/settings
            },
          ),
        ],
      ),
      body: floorsAsync.when(
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
                color: colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load floors',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(floorsProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (floors) {
          if (floors.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.table_restaurant,
                    size: 64,
                    color: colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No floors configured',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact your manager to set up restaurant floors',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Get tables with filters applied
          final tables = _getFilteredTables(
            selectedFloor?.tables ?? [],
            currentWaiter?.id,
          );

          return Column(
            children: [
              // Floor selector and filters
              _buildFloorSelector(floors, selectedFloor),
              _buildFilters(),

              // Table grid
              Expanded(
                child: tables.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.filter_alt_off,
                              size: 64,
                              color: colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tables match filters',
                              style: theme.textTheme.titleLarge,
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: tables.length,
                        itemBuilder: (context, index) {
                          final table = tables[index];
                          return TableCard(
                            table: table,
                            onTap: () => _handleTableTap(context, table),
                          );
                        },
                      ),
              ),

              // Table status legend
              _buildStatusLegend(),
            ],
          );
        },
      ),
    );
  }

  /// Build floor selector chips
  Widget _buildFloorSelector(
    List<RestaurantFloor> floors,
    RestaurantFloor? selectedFloor,
  ) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: floors.length,
        itemBuilder: (context, index) {
          final floor = floors[index];
          final isSelected = floor.id == selectedFloor?.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(floor.name),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(selectedFloorProvider.notifier).state = floor;
                }
              },
              avatar: isSelected
                  ? const Icon(Icons.check_circle, size: 18)
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Build filter chips
  Widget _buildFilters() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        children: [
          // My tables filter
          FilterChip(
            label: const Text('My Tables'),
            selected: _showOnlyMyTables,
            onSelected: (selected) {
              setState(() {
                _showOnlyMyTables = selected;
              });
            },
            avatar: _showOnlyMyTables
                ? const Icon(Icons.check, size: 18)
                : const Icon(Icons.person, size: 18),
          ),

          // Status filters
          ...TableStatus.values.map((status) {
            final isSelected = _filterStatus == status;
            return FilterChip(
              label: Text(_getStatusText(status)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _filterStatus = selected ? status : null;
                });
              },
              backgroundColor: _getStatusColor(status).withOpacity(0.1),
              selectedColor: _getStatusColor(status).withOpacity(0.3),
            );
          }),
        ],
      ),
    );
  }

  /// Build status legend
  Widget _buildStatusLegend() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: TableStatus.values.map((status) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _getStatusColor(status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusText(status),
                style: theme.textTheme.labelSmall,
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Get filtered tables
  List<RestaurantTable> _getFilteredTables(
    List<RestaurantTable> tables,
    String? waiterId,
  ) {
    var filtered = tables;

    // Filter by status
    if (_filterStatus != null) {
      filtered = filtered.where((t) => t.status == _filterStatus).toList();
    }

    // Filter by assigned waiter
    if (_showOnlyMyTables && waiterId != null) {
      filtered =
          filtered.where((t) => t.assignedWaiterId == waiterId).toList();
    }

    return filtered;
  }

  /// Handle table tap
  void _handleTableTap(BuildContext context, RestaurantTable table) {
    // Show table actions bottom sheet
    showModalBottomSheet(
      context: context,
      builder: (context) => _TableActionsSheet(table: table),
    );
  }

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return Colors.green;
      case TableStatus.occupied:
        return Colors.blue;
      case TableStatus.reserved:
        return Colors.orange;
      case TableStatus.needsCleaning:
        return Colors.red;
      case TableStatus.outOfService:
        return Colors.grey;
    }
  }

  String _getStatusText(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return 'Available';
      case TableStatus.occupied:
        return 'Occupied';
      case TableStatus.reserved:
        return 'Reserved';
      case TableStatus.needsCleaning:
        return 'Cleaning';
      case TableStatus.outOfService:
        return 'Out of Service';
    }
  }
}

/// Table Actions Bottom Sheet
class _TableActionsSheet extends ConsumerWidget {
  final RestaurantTable table;

  const _TableActionsSheet({required this.table});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentWaiter = ref.watch(currentWaiterProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.table_restaurant,
                color: table.displayColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      table.name,
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      '${table.seats} seats',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: table.displayColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  table.status.name.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: table.displayColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),

          // Actions based on table status
          if (table.isAvailable) ...[
            _ActionButton(
              icon: Icons.people,
              label: 'Open Table',
              onPressed: () {
                Navigator.pop(context);
                // TODO: Show guest count dialog, then open table
                _openTable(context, ref, table, currentWaiter);
              },
            ),
          ],

          if (table.isOccupied) ...[
            _ActionButton(
              icon: Icons.add_shopping_cart,
              label: 'Take Order',
              onPressed: () {
                Navigator.pop(context);
                context.push('/table/${table.id}/order');
              },
            ),
            _ActionButton(
              icon: Icons.visibility,
              label: 'View Current Order',
              onPressed: () {
                Navigator.pop(context);
                context.push('/table/${table.id}/current-order');
              },
            ),
            _ActionButton(
              icon: Icons.receipt,
              label: 'Request Bill',
              onPressed: () {
                Navigator.pop(context);
                _requestBill(context, ref, table);
              },
            ),
            _ActionButton(
              icon: Icons.transfer_within_a_station,
              label: 'Transfer Table',
              onPressed: () {
                Navigator.pop(context);
                // TODO: Show waiter selector dialog
              },
            ),
            _ActionButton(
              icon: Icons.edit,
              label: 'Change Guest Count',
              onPressed: () {
                Navigator.pop(context);
                // TODO: Show guest count dialog
              },
            ),
          ],

          if (table.status == TableStatus.needsCleaning) ...[
            _ActionButton(
              icon: Icons.cleaning_services,
              label: 'Mark as Clean',
              onPressed: () {
                Navigator.pop(context);
                _cleanTable(context, ref, table);
              },
            ),
          ],

          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _openTable(
    BuildContext context,
    WidgetRef ref,
    RestaurantTable table,
    Waiter? waiter,
  ) async {
    if (waiter == null) return;

    final service = ref.read(tableServiceProvider);
    final result = await service.openTable(
      tableId: table.id,
      waiterId: waiter.id,
      waiterName: waiter.name,
      guestCount: 2, // TODO: Get from dialog
    );

    if (context.mounted) {
      result.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${table.name} opened')),
          );
          ref.invalidate(floorsProvider);
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open table: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  Future<void> _cleanTable(
    BuildContext context,
    WidgetRef ref,
    RestaurantTable table,
  ) async {
    final service = ref.read(tableServiceProvider);
    final result = await service.cleanTable(table.id);

    if (context.mounted) {
      result.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${table.name} marked as clean')),
          );
          ref.invalidate(floorsProvider);
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clean table: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  Future<void> _requestBill(
    BuildContext context,
    WidgetRef ref,
    RestaurantTable table,
  ) async {
    final service = ref.read(tableServiceProvider);
    final result = await service.requestBill(table.id);

    if (context.mounted) {
      result.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bill requested')),
          );
          context.push('/table/${table.id}/checkout');
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to request bill: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }
}

/// Action button widget
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}
