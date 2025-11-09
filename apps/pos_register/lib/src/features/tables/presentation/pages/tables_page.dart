import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart' as pos;
import 'package:pos_ui/pos_ui.dart';

/// Tables management page showing floor layout and table status
class TablesPage extends ConsumerStatefulWidget {
  const TablesPage({super.key});

  @override
  ConsumerState<TablesPage> createState() => _TablesPageState();
}

class _TablesPageState extends ConsumerState<TablesPage> {
  String? _selectedZoneId;
  pos.TableStatus? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    final zonesAsync = ref.watch(pos.zonesProvider());
    final tablesAsync = ref.watch(pos.tablesProvider(
      zoneId: _selectedZoneId,
      status: _selectedStatus,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tables'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(pos.tablesProvider);
              ref.invalidate(pos.zonesProvider);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone Selector
          zonesAsync.when(
            data: (zones) => ZoneSelector(
              zones: zones,
              selectedZoneId: _selectedZoneId,
              onZoneTap: (zone) {
                setState(() => _selectedZoneId = zone?.id);
              },
            ),
            loading: () => const SizedBox(height: 48),
            error: (_, __) => const SizedBox(height: 48),
          ),

          // Status Filter
          TableStatusFilter(
            selectedStatus: _selectedStatus,
            onStatusTap: (status) {
              setState(() => _selectedStatus = status);
            },
          ),

          // Tables Grid
          Expanded(
            child: tablesAsync.when(
              data: (tables) => TableGrid(
                tables: tables,
                onTableTap: (table) => _showTableDetails(table),
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading tables: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTableDetails(pos.Table table) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _TableDetailsSheet(table: table),
    );
  }
}

class _TableDetailsSheet extends ConsumerWidget {
  const _TableDetailsSheet({required this.table});

  final pos.Table table;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        table.name,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${table.capacity} seats • ${table.zoneName ?? "No zone"}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          const Divider(),

          // Content
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                // Status
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Status'),
                  trailing: _buildStatusChip(theme, table.status),
                ),

                // Assigned Staff
                if (table.assignedTo != null)
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text('Assigned To'),
                    trailing: Text(table.assignedTo!),
                  ),

                // Current Order
                if (table.currentOrderId != null)
                  ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: const Text('Current Order'),
                    trailing: Text('#${table.currentOrderId}'),
                  ),

                const Divider(height: 32),

                // Actions
                const Text(
                  'Actions',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                if (table.status == pos.TableStatus.available) ...[
                  FilledButton.icon(
                    onPressed: () => _markAsOccupied(context, ref),
                    icon: const Icon(Icons.event_seat),
                    label: const Text('Mark as Occupied'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _markAsReserved(context, ref),
                    icon: const Icon(Icons.bookmark_outline),
                    label: const Text('Mark as Reserved'),
                  ),
                ],

                if (table.status == pos.TableStatus.occupied) ...[
                  FilledButton.icon(
                    onPressed: () => _clearTable(context, ref),
                    icon: const Icon(Icons.cleaning_services),
                    label: const Text('Clear Table'),
                  ),
                ],

                if (table.status == pos.TableStatus.cleaning) ...[
                  FilledButton.icon(
                    onPressed: () => _markAsAvailable(context, ref),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark as Available'),
                  ),
                ],

                if (table.status != pos.TableStatus.blocked) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _blockTable(context, ref),
                    icon: const Icon(Icons.block),
                    label: const Text('Block Table'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                    ),
                  ),
                ],

                if (table.status == pos.TableStatus.blocked) ...[
                  FilledButton.icon(
                    onPressed: () => _markAsAvailable(context, ref),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Unblock Table'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ThemeData theme, pos.TableStatus status) {
    Color color;
    switch (status) {
      case pos.TableStatus.available:
        color = Colors.green;
        break;
      case pos.TableStatus.occupied:
        color = Colors.red;
        break;
      case pos.TableStatus.reserved:
        color = Colors.orange;
        break;
      case pos.TableStatus.cleaning:
        color = Colors.blue;
        break;
      case pos.TableStatus.blocked:
        color = theme.colorScheme.outline;
        break;
    }

    return Chip(
      label: Text(
        status.name[0].toUpperCase() + status.name.substring(1),
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }

  Future<void> _updateTableStatus(
    BuildContext context,
    WidgetRef ref,
    pos.TableStatus newStatus,
  ) async {
    try {
      final result = await ref.read(pos.updateTableStatusUseCaseProvider)(
        table.id,
        newStatus,
      );

      await result.when(
        success: (_) {
          ref.invalidate(pos.tablesProvider);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Table status updated')),
            );
          }
        },
        failure: (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _markAsOccupied(BuildContext context, WidgetRef ref) {
    _updateTableStatus(context, ref, pos.TableStatus.occupied);
  }

  void _markAsReserved(BuildContext context, WidgetRef ref) {
    _updateTableStatus(context, ref, pos.TableStatus.reserved);
  }

  void _markAsAvailable(BuildContext context, WidgetRef ref) {
    _updateTableStatus(context, ref, pos.TableStatus.available);
  }

  void _blockTable(BuildContext context, WidgetRef ref) {
    _updateTableStatus(context, ref, pos.TableStatus.blocked);
  }

  Future<void> _clearTable(BuildContext context, WidgetRef ref) async {
    try {
      final result = await ref.read(pos.clearTableUseCaseProvider)(table.id);

      await result.when(
        success: (_) {
          ref.invalidate(pos.tablesProvider);
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Table cleared')),
            );
          }
        },
        failure: (error) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${error.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
