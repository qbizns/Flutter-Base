import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/restaurant_table.dart';
import '../../providers/restaurant_providers.dart';
import 'table_form_dialog.dart';

/// Floor Plan View - Interactive drag-and-drop table layout
class FloorPlanView extends ConsumerStatefulWidget {
  const FloorPlanView({super.key});

  @override
  ConsumerState<FloorPlanView> createState() => _FloorPlanViewState();
}

class _FloorPlanViewState extends ConsumerState<FloorPlanView> {
  String? _selectedSection;
  bool _isEditMode = false;
  final Set<String> _selectedTables = {};

  @override
  Widget build(BuildContext context) {
    final tables = ref.watch(tablesProvider);
    final sections = _getSections(tables);

    final filteredTables = _selectedSection == null
        ? tables
        : tables.where((t) => t.section == _selectedSection).toList();

    return Column(
      children: [
        // Toolbar
        _buildToolbar(sections),

        // Floor Plan
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(OdooSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              border: Border.all(color: OdooColors.border),
            ),
            child: Stack(
              children: [
                // Grid background (optional)
                if (_isEditMode) _buildGrid(),

                // Tables
                ...filteredTables.map((table) => _buildDraggableTable(table)),

                // Legend
                Positioned(
                  top: OdooSpacing.lg,
                  right: OdooSpacing.lg,
                  child: _buildLegend(),
                ),

                // Section label (if filtered)
                if (_selectedSection != null)
                  Positioned(
                    top: OdooSpacing.lg,
                    left: OdooSpacing.lg,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OdooSpacing.lg,
                        vertical: OdooSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: OdooColors.primary.withOpacity(0.1),
                        borderRadius:
                            BorderRadius.circular(OdooSpacing.radiusStandard),
                        border: Border.all(
                          color: OdooColors.primary,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            color: OdooColors.primary,
                            size: OdooIconSizes.md,
                          ),
                          const SizedBox(width: OdooSpacing.sm),
                          Text(
                            _selectedSection!,
                            style: OdooTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: OdooColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildToolbar(List<String> sections) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Row(
        children: [
          // Section filter
          if (sections.isNotEmpty) ...[
            Text(
              'Section:',
              style: OdooTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: OdooSpacing.md),
            DropdownButton<String?>(
              value: _selectedSection,
              hint: const Text('All Sections'),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All Sections'),
                ),
                ...sections.map((section) {
                  return DropdownMenuItem(
                    value: section,
                    child: Text(section),
                  );
                }),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedSection = value;
                });
              },
            ),
          ],

          const Spacer(),

          // Edit mode toggle
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _isEditMode = !_isEditMode;
                if (!_isEditMode) {
                  _selectedTables.clear();
                }
              });
            },
            icon: Icon(_isEditMode ? Icons.check : Icons.edit),
            label: Text(_isEditMode ? 'Done' : 'Edit Layout'),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  _isEditMode ? OdooColors.primary.withOpacity(0.1) : null,
              foregroundColor: _isEditMode ? OdooColors.primary : null,
            ),
          ),

          const SizedBox(width: OdooSpacing.md),

          // Add table button
          FilledButton.icon(
            onPressed: () => _showAddTableDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add Table'),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return CustomPaint(
      painter: GridPainter(),
      child: Container(),
    );
  }

  Widget _buildDraggableTable(RestaurantTable table) {
    final isSelected = _selectedTables.contains(table.id);

    return Positioned(
      left: table.positionX / 100 *
          (MediaQuery.of(context).size.width - 32 - OdooSpacing.lg * 2),
      top: table.positionY / 100 *
          (MediaQuery.of(context).size.height - 200 - OdooSpacing.lg * 2),
      child: _isEditMode
          ? Draggable<RestaurantTable>(
              data: table,
              feedback: Material(
                color: Colors.transparent,
                child: Opacity(
                  opacity: 0.7,
                  child: _buildTableWidget(table, isDragging: true),
                ),
              ),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: _buildTableWidget(table),
              ),
              onDragEnd: (details) {
                _updateTablePosition(table, details.offset);
              },
              child: _buildTableWidget(table, isSelected: isSelected),
            )
          : _buildTableWidget(table),
    );
  }

  Widget _buildTableWidget(
    RestaurantTable table, {
    bool isDragging = false,
    bool isSelected = false,
  }) {
    final statusColor = _getTableStatusColor(table.status);
    final shapeWidget = _getTableShapeWidget(table, statusColor);

    return GestureDetector(
      onTap: _isEditMode
          ? () {
              setState(() {
                if (isSelected) {
                  _selectedTables.remove(table.id);
                } else {
                  _selectedTables.add(table.id);
                }
              });
            }
          : () => _showTableDetails(table),
      onLongPress: _isEditMode ? null : () => _showTableContextMenu(table),
      child: Container(
        width: table.width,
        height: table.height,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? OdooColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        child: Stack(
          children: [
            shapeWidget,

            // Table info overlay
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    table.name,
                    style: OdooTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: OdooSpacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people,
                        size: OdooIconSizes.sm,
                        color: Colors.white,
                      ),
                      const SizedBox(width: OdooSpacing.xs),
                      Text(
                        '${table.capacity}',
                        style: OdooTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit mode selection indicator
            if (_isEditMode && isSelected)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: OdooColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _getTableShapeWidget(RestaurantTable table, Color color) {
    switch (table.shape) {
      case TableShape.square:
        return Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      case TableShape.rectangle:
        return Container(
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      case TableShape.circle:
        return Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
      case TableShape.roundedRectangle:
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
        );
    }
  }

  Widget _buildLegend() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Status',
              style: OdooTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: OdooSpacing.sm),
            _buildLegendItem('Available', OdooColors.success),
            _buildLegendItem('Occupied', OdooColors.danger),
            _buildLegendItem('Reserved', OdooColors.warning),
            _buildLegendItem('Cleaning', OdooColors.gray400),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OdooSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: OdooSpacing.sm),
          Text(
            label,
            style: OdooTypography.bodySmall,
          ),
        ],
      ),
    );
  }

  // Helper methods

  List<String> _getSections(List<RestaurantTable> tables) {
    final sections = tables
        .map((t) => t.section)
        .where((s) => s != null)
        .cast<String>()
        .toSet()
        .toList();
    sections.sort();
    return sections;
  }

  Color _getTableStatusColor(TableStatus status) {
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

  void _updateTablePosition(RestaurantTable table, Offset offset) {
    final containerWidth = MediaQuery.of(context).size.width - 32 - OdooSpacing.lg * 2;
    final containerHeight = MediaQuery.of(context).size.height - 200 - OdooSpacing.lg * 2;

    // Convert pixel position to percentage
    final percentX = (offset.dx / containerWidth * 100).clamp(0, 90);
    final percentY = (offset.dy / containerHeight * 100).clamp(0, 90);

    ref.read(tablesProvider.notifier).updateTablePosition(
          table.id,
          percentX,
          percentY,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${table.name} position updated'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _showAddTableDialog() async {
    final result = await showDialog<RestaurantTable>(
      context: context,
      builder: (context) => const TableFormDialog(),
    );

    if (result != null) {
      ref.read(tablesProvider.notifier).addTable(result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.name} added successfully'),
          backgroundColor: OdooColors.success,
        ),
      );
    }
  }

  void _showTableDetails(RestaurantTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(OdooSpacing.sm),
              decoration: BoxDecoration(
                color: _getTableStatusColor(table.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              ),
              child: Icon(
                Icons.table_restaurant,
                color: _getTableStatusColor(table.status),
              ),
            ),
            const SizedBox(width: OdooSpacing.md),
            Text(table.name),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Capacity', '${table.capacity} seats'),
            _buildDetailRow('Status', _getStatusText(table.status)),
            if (table.section != null)
              _buildDetailRow('Section', table.section!),
            if (table.reservationName != null)
              _buildDetailRow('Reserved for', table.reservationName!),
            if (table.currentOrderId != null)
              _buildDetailRow('Current Order', '#${table.currentOrderId}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showEditTableDialog(table);
            },
            icon: const Icon(Icons.edit),
            label: const Text('Edit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: OdooTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditTableDialog(RestaurantTable table) async {
    final result = await showDialog<RestaurantTable>(
      context: context,
      builder: (context) => TableFormDialog(table: table),
    );

    if (result != null) {
      ref.read(tablesProvider.notifier).updateTable(table.id, result);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result.name} updated successfully'),
          backgroundColor: OdooColors.success,
        ),
      );
    }
  }

  void _showTableContextMenu(RestaurantTable table) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Table'),
              onTap: () {
                Navigator.pop(context);
                _showEditTableDialog(table);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Table'),
              textColor: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteTable(table);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteTable(RestaurantTable table) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Table'),
        content: Text('Are you sure you want to delete ${table.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
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
}

/// Grid painter for edit mode background
class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = OdooColors.border.withOpacity(0.3)
      ..strokeWidth = 0.5;

    const gridSize = 50.0;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
