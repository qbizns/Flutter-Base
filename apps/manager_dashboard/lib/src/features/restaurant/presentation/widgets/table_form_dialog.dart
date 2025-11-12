import 'package:flutter/material.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/restaurant_table.dart';

/// Table Form Dialog - Add or edit restaurant tables
class TableFormDialog extends StatefulWidget {
  const TableFormDialog({this.table, super.key});

  final RestaurantTable? table;

  @override
  State<TableFormDialog> createState() => _TableFormDialogState();
}

class _TableFormDialogState extends State<TableFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _sectionController = TextEditingController();
  final _notesController = TextEditingController();

  late TableStatus _selectedStatus;
  late TableShape _selectedShape;

  bool get isEditing => widget.table != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _nameController.text = widget.table!.name;
      _capacityController.text = widget.table!.capacity.toString();
      _sectionController.text = widget.table!.section ?? '';
      _notesController.text = widget.table!.notes ?? '';
      _selectedStatus = widget.table!.status;
      _selectedShape = widget.table!.shape;
    } else {
      _selectedStatus = TableStatus.available;
      _selectedShape = TableShape.square;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _sectionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OdooSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      Text(
                        'Basic Information',
                        style: OdooTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.md),

                      // Table Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Table Name *',
                          hintText: 'e.g., Table 1',
                          prefixIcon: Icon(Icons.table_restaurant),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a table name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Capacity
                      TextFormField(
                        controller: _capacityController,
                        decoration: const InputDecoration(
                          labelText: 'Capacity (seats) *',
                          hintText: 'Number of seats',
                          prefixIcon: Icon(Icons.people),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter capacity';
                          }
                          final capacity = int.tryParse(value);
                          if (capacity == null || capacity <= 0) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Section
                      TextFormField(
                        controller: _sectionController,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          hintText: 'e.g., Main Hall, Patio, VIP',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.xl),

                      // Appearance
                      Text(
                        'Appearance',
                        style: OdooTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.md),

                      // Shape selection
                      Text(
                        'Table Shape',
                        style: OdooTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.sm),
                      _buildShapeSelector(),
                      const SizedBox(height: OdooSpacing.xl),

                      // Status
                      Text(
                        'Status',
                        style: OdooTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.md),

                      DropdownButtonFormField<TableStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Table Status',
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        items: TableStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
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
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Additional information...',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: OdooColors.gray50,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(OdooSpacing.md),
            decoration: BoxDecoration(
              color: OdooColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Icon(
              Icons.table_restaurant,
              color: OdooColors.primary,
              size: OdooIconSizes.lg,
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Table' : 'Add New Table',
                  style: OdooTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: OdooColors.textPrimary,
                  ),
                ),
                Text(
                  isEditing
                      ? 'Update table information'
                      : 'Create a new table for your restaurant',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildShapeSelector() {
    return Wrap(
      spacing: OdooSpacing.md,
      runSpacing: OdooSpacing.md,
      children: TableShape.values.map((shape) {
        final isSelected = _selectedShape == shape;
        return InkWell(
          onTap: () {
            setState(() {
              _selectedShape = shape;
            });
          },
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: isSelected
                  ? OdooColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? OdooColors.primary : OdooColors.border,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShapePreview(shape, isSelected),
                const SizedBox(height: OdooSpacing.sm),
                Text(
                  _getShapeName(shape),
                  style: OdooTypography.bodySmall.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : null,
                    color: isSelected ? OdooColors.primary : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildShapePreview(TableShape shape, bool isSelected) {
    final color = isSelected ? OdooColors.primary : OdooColors.gray400;

    switch (shape) {
      case TableShape.square:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
          ),
        );
      case TableShape.rectangle:
        return Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
          ),
        );
      case TableShape.circle:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
        );
      case TableShape.roundedRectangle:
        return Container(
          width: 50,
          height: 30,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
        );
    }
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: OdooColors.gray50,
        border: Border(
          top: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: OdooSpacing.md),
          FilledButton.icon(
            onPressed: _saveTable,
            icon: const Icon(Icons.check),
            label: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _saveTable() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final table = RestaurantTable(
      id: isEditing ? widget.table!.id : DateTime.now().toString(),
      name: _nameController.text.trim(),
      capacity: int.parse(_capacityController.text),
      status: _selectedStatus,
      shape: _selectedShape,
      section: _sectionController.text.trim().isEmpty
          ? null
          : _sectionController.text.trim(),
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      // Keep existing position and size if editing
      positionX: isEditing ? widget.table!.positionX : 10,
      positionY: isEditing ? widget.table!.positionY : 10,
      width: isEditing ? widget.table!.width : 100,
      height: isEditing ? widget.table!.height : 100,
      // Keep existing reservation/order data if editing
      currentOrderId: isEditing ? widget.table!.currentOrderId : null,
      reservationTime: isEditing ? widget.table!.reservationTime : null,
      reservationName: isEditing ? widget.table!.reservationName : null,
    );

    Navigator.of(context).pop(table);
  }

  // Helper methods

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
