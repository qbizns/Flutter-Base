import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/restaurant_table.dart';
import '../../providers/restaurant_providers.dart';
import 'table_form_dialog.dart';

/// Tables List View - Manage tables in a list format
class TablesListView extends ConsumerStatefulWidget {
  const TablesListView({super.key});

  @override
  ConsumerState<TablesListView> createState() => _TablesListViewState();
}

class _TablesListViewState extends ConsumerState<TablesListView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedSection;
  TableStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tablesProvider);
    final filteredTables = _filterTables(tables);

    return Column(
      children: [
        // Toolbar
        _buildToolbar(filteredTables.length),

        // Search and Filters
        Container(
          padding: const EdgeInsets.all(OdooSpacing.lg),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: OdooSpacing.md),
              _buildFilters(tables),
            ],
          ),
        ),

        // Tables Table
        Expanded(
          child: filteredTables.isEmpty
              ? _buildEmptyState()
              : _buildTablesTable(filteredTables),
        ),
      ],
    );
  }

  Widget _buildToolbar(int count) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Row(
        children: [
          Text(
            '$count tables found',
            style: OdooTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _showAddTableDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Table'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search by table name or section...',
        prefixIcon: Icon(
          Icons.search,
          color: OdooColors.textSecondary,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildFilters(List<RestaurantTable> tables) {
    final sections = tables
        .map((t) => t.section)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList()
      ..sort();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Section filter
          if (sections.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () => _showSectionFilter(sections),
              icon: const Icon(Icons.location_on),
              label: Text(
                _selectedSection ?? 'All Sections',
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    _selectedSection != null ? OdooColors.primary.withOpacity(0.1) : null,
              ),
            ),
            const SizedBox(width: OdooSpacing.md),
          ],

          // Status filter
          OutlinedButton.icon(
            onPressed: _showStatusFilter,
            icon: const Icon(Icons.info_outline),
            label: Text(
              _selectedStatus != null
                  ? _getStatusText(_selectedStatus!)
                  : 'All Statuses',
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  _selectedStatus != null ? OdooColors.primary.withOpacity(0.1) : null,
            ),
          ),

          // Clear filters
          if (_selectedSection != null || _selectedStatus != null) ...[
            const SizedBox(width: OdooSpacing.md),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedSection = null;
                  _selectedStatus = null;
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              style: TextButton.styleFrom(
                foregroundColor: OdooColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTablesTable(List<RestaurantTable> tables) {
    return Card(
      margin: const EdgeInsets.all(OdooSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.md),
        child: DataTable2(
          columnSpacing: OdooSpacing.lg,
          horizontalMargin: OdooSpacing.lg,
          minWidth: 800,
          headingRowColor: WidgetStateProperty.all(OdooColors.gray50),
          headingTextStyle: OdooTypography.tableHeader.copyWith(
            color: OdooColors.textPrimary,
          ),
          dataTextStyle: OdooTypography.tableCell,
          columns: const [
            DataColumn2(
              label: Text('TABLE NAME'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('CAPACITY'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('SECTION'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('SHAPE'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('STATUS'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('ACTIONS'),
              size: ColumnSize.M,
              numeric: true,
            ),
          ],
          rows: tables.map((table) => _buildTableRow(table)).toList(),
        ),
      ),
    );
  }

  DataRow2 _buildTableRow(RestaurantTable table) {
    return DataRow2(
      cells: [
        // Table Name
        DataCell(
          Row(
            children: [
              _buildTableShapeIcon(table.shape),
              const SizedBox(width: OdooSpacing.sm),
              Text(
                table.name,
                style: OdooTypography.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Capacity
        DataCell(
          Row(
            children: [
              Icon(
                Icons.people,
                size: OdooIconSizes.sm,
                color: OdooColors.textSecondary,
              ),
              const SizedBox(width: OdooSpacing.xs),
              Text('${table.capacity}'),
            ],
          ),
        ),

        // Section
        DataCell(
          Text(table.section ?? '-'),
        ),

        // Shape
        DataCell(
          Text(_getShapeName(table.shape)),
        ),

        // Status
        DataCell(
          _buildStatusBadge(table.status),
        ),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showEditTableDialog(table),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                iconSize: OdooIconSizes.md,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(OdooSpacing.sm),
              ),
              const SizedBox(width: OdooSpacing.xs),
              IconButton(
                onPressed: () => _confirmDeleteTable(table),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                iconSize: OdooIconSizes.md,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(OdooSpacing.sm),
                color: OdooColors.danger,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTableShapeIcon(TableShape shape) {
    IconData icon;
    switch (shape) {
      case TableShape.square:
        icon = Icons.crop_square;
        break;
      case TableShape.rectangle:
        icon = Icons.rectangle_outlined;
        break;
      case TableShape.circle:
        icon = Icons.circle_outlined;
        break;
      case TableShape.roundedRectangle:
        icon = Icons.rounded_corner;
        break;
    }

    return Icon(
      icon,
      size: OdooIconSizes.md,
      color: OdooColors.primary,
    );
  }

  Widget _buildStatusBadge(TableStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.sm,
        vertical: OdooSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
      ),
      child: Text(
        _getStatusText(status),
        style: OdooTypography.labelSmall.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant,
            size: 80,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.lg),
          Text(
            _searchQuery.isNotEmpty || _selectedSection != null || _selectedStatus != null
                ? 'No tables found'
                : 'No tables yet',
            style: OdooTypography.titleLarge.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            _searchQuery.isNotEmpty || _selectedSection != null || _selectedStatus != null
                ? 'Try adjusting your search or filters'
                : 'Create your first table to get started',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          if (_searchQuery.isEmpty &&
              _selectedSection == null &&
              _selectedStatus == null) ...[
            const SizedBox(height: OdooSpacing.xl),
            FilledButton.icon(
              onPressed: _showAddTableDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Table'),
            ),
          ],
        ],
      ),
    );
  }

  // Filter and Search Logic

  List<RestaurantTable> _filterTables(List<RestaurantTable> tables) {
    return tables.where((table) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = table.name.toLowerCase().contains(_searchQuery);
        final matchesSection =
            table.section?.toLowerCase().contains(_searchQuery) ?? false;

        if (!matchesName && !matchesSection) {
          return false;
        }
      }

      // Section filter
      if (_selectedSection != null && table.section != _selectedSection) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && table.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  // Dialog Actions

  Future<void> _showSectionFilter(List<String> sections) async {
    final selected = await showDialog<String?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Section'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('All Sections'),
          ),
          ...sections.map((section) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, section),
              child: Text(section),
            );
          }),
        ],
      ),
    );

    setState(() {
      _selectedSection = selected;
    });
  }

  Future<void> _showStatusFilter() async {
    final selected = await showDialog<TableStatus?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Status'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('All Statuses'),
          ),
          ...TableStatus.values.map((status) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, status),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: OdooSpacing.sm),
                    Text(_getStatusText(status)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );

    setState(() {
      _selectedStatus = selected;
    });
  }

  Future<void> _showAddTableDialog() async {
    final result = await showDialog<RestaurantTable>(
      context: context,
      builder: (context) => const TableFormDialog(),
    );

    if (result != null) {
      ref.read(tablesProvider.notifier).addTable(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} added successfully'),
            backgroundColor: OdooColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showEditTableDialog(RestaurantTable table) async {
    final result = await showDialog<RestaurantTable>(
      context: context,
      builder: (context) => TableFormDialog(table: table),
    );

    if (result != null) {
      ref.read(tablesProvider.notifier).updateTable(table.id, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.name} updated successfully'),
            backgroundColor: OdooColors.success,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteTable(RestaurantTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: OdooColors.danger,
            ),
            const SizedBox(width: OdooSpacing.md),
            const Text('Delete Table'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete ${table.name}?',
              style: OdooTypography.bodyLarge,
            ),
            const SizedBox(height: OdooSpacing.lg),
            Container(
              padding: const EdgeInsets.all(OdooSpacing.md),
              decoration: BoxDecoration(
                color: OdooColors.dangerLight,
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                border: Border.all(
                  color: OdooColors.danger,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.table_restaurant,
                    color: OdooColors.danger,
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        table.name,
                        style: OdooTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.danger,
                        ),
                      ),
                      Text(
                        '${table.capacity} seats • ${table.section ?? "No section"}',
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.danger,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: OdooSpacing.lg),
            Text(
              'This action cannot be undone.',
              style: OdooTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: OdooColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: OdooColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(tablesProvider.notifier).deleteTable(table.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${table.name} deleted'),
            backgroundColor: OdooColors.danger,
          ),
        );
      }
    }
  }

  // Helper Methods

  Color _getStatusColor(TableStatus status) {
    switch (status) {
      case TableStatus.available:
        return OdooColors.success;
      case TableStatus.occupied:
        return OdooColors.danger;
      case TableStatus.reserved:
        return OdooColors.warning;
      case TableStatus.cleaning:
        return OdooColors.gray400;
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
      case TableStatus.cleaning:
        return 'Cleaning';
    }
  }

  String _getShapeName(TableShape shape) {
    switch (shape) {
      case TableShape.square:
        return 'Square';
      case TableShape.rectangle:
        return 'Rectangle';
      case TableShape.circle:
        return 'Circle';
      case TableShape.roundedRectangle:
        return 'Rounded';
    }
  }
}
