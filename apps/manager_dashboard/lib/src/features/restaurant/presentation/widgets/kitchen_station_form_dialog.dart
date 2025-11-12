import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/restaurant_table.dart';

/// Kitchen Station Form Dialog - Add or edit kitchen stations
class KitchenStationFormDialog extends StatefulWidget {
  const KitchenStationFormDialog({this.station, super.key});

  final KitchenStation? station;

  @override
  State<KitchenStationFormDialog> createState() =>
      _KitchenStationFormDialogState();
}

class _KitchenStationFormDialogState extends State<KitchenStationFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();

  late Color _selectedColor;
  late List<String> _categories;

  bool get isEditing => widget.station != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _nameController.text = widget.station!.name;
      _descriptionController.text = widget.station!.description;
      _selectedColor = widget.station!.color;
      _categories = List.from(widget.station!.categories);
    } else {
      _selectedColor = OdooColors.primary;
      _categories = [];
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
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

                      // Station Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Station Name *',
                          hintText: 'e.g., Grill Station',
                          prefixIcon: Icon(Icons.kitchen),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a station name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'What does this station handle?',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: OdooSpacing.xl),

                      // Color Selection
                      Text(
                        'Station Color',
                        style: OdooTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.md),
                      _buildColorPicker(),
                      const SizedBox(height: OdooSpacing.xl),

                      // Categories
                      Text(
                        'Product Categories',
                        style: OdooTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.sm),
                      Text(
                        'Add categories that this station will handle',
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.md),

                      // Category input
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                hintText: 'Enter category name',
                                prefixIcon: Icon(Icons.category),
                              ),
                              onSubmitted: (_) => _addCategory(),
                            ),
                          ),
                          const SizedBox(width: OdooSpacing.md),
                          IconButton(
                            onPressed: _addCategory,
                            icon: const Icon(Icons.add_circle),
                            tooltip: 'Add Category',
                            color: OdooColors.primary,
                            iconSize: OdooIconSizes.xl,
                          ),
                        ],
                      ),
                      const SizedBox(height: OdooSpacing.md),

                      // Categories chips
                      if (_categories.isNotEmpty) ...[
                        Wrap(
                          spacing: OdooSpacing.sm,
                          runSpacing: OdooSpacing.sm,
                          children: _categories.map((category) {
                            return Chip(
                              label: Text(category),
                              backgroundColor:
                                  _selectedColor.withOpacity(0.1),
                              deleteIcon: Icon(
                                Icons.close,
                                size: OdooIconSizes.sm,
                              ),
                              onDeleted: () {
                                setState(() {
                                  _categories.remove(category);
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(OdooSpacing.lg),
                          decoration: BoxDecoration(
                            color: OdooColors.gray100,
                            borderRadius: BorderRadius.circular(
                              OdooSpacing.radiusStandard,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: OdooColors.textSecondary,
                              ),
                              const SizedBox(width: OdooSpacing.md),
                              Expanded(
                                child: Text(
                                  'No categories added yet. Add at least one category.',
                                  style: OdooTypography.bodySmall.copyWith(
                                    color: OdooColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
              color: _selectedColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Icon(
              Icons.kitchen,
              color: _selectedColor,
              size: OdooIconSizes.lg,
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Station' : 'Add Kitchen Station',
                  style: OdooTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: OdooColors.textPrimary,
                  ),
                ),
                Text(
                  isEditing
                      ? 'Update station configuration'
                      : 'Create a new kitchen station',
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

  Widget _buildColorPicker() {
    final predefinedColors = [
      OdooColors.danger,
      OdooColors.success,
      OdooColors.warning,
      OdooColors.secondary,
      OdooColors.primary,
      OdooColors.info,
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF795548), // Brown
      const Color(0xFF607D8B), // Blue Grey
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Predefined colors
        Wrap(
          spacing: OdooSpacing.md,
          runSpacing: OdooSpacing.md,
          children: predefinedColors.map((color) {
            final isSelected = _selectedColor == color;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedColor = color;
                });
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius:
                      BorderRadius.circular(OdooSpacing.radiusStandard),
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: color.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: OdooIconSizes.lg,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: OdooSpacing.md),

        // Custom color picker button
        OutlinedButton.icon(
          onPressed: _showCustomColorPicker,
          icon: const Icon(Icons.palette),
          label: const Text('Custom Color'),
        ),
      ],
    );
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
            onPressed: _saveStation,
            icon: const Icon(Icons.check),
            label: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _addCategory() {
    final category = _categoryController.text.trim();
    if (category.isNotEmpty && !_categories.contains(category)) {
      setState(() {
        _categories.add(category);
        _categoryController.clear();
      });
    }
  }

  Future<void> _showCustomColorPicker() async {
    Color? pickedColor = _selectedColor;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              pickedColor = color;
            },
            pickerAreaHeightPercent: 0.8,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _selectedColor = pickedColor!;
              });
              Navigator.of(context).pop();
            },
            child: const Text('Select'),
          ),
        ],
      ),
    );
  }

  void _saveStation() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add at least one category'),
          backgroundColor: OdooColors.warning,
        ),
      );
      return;
    }

    final station = KitchenStation(
      id: isEditing ? widget.station!.id : DateTime.now().toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      color: _selectedColor,
      categories: _categories,
      isActive: isEditing ? widget.station!.isActive : true,
      orderPosition: isEditing ? widget.station!.orderPosition : 0,
    );

    Navigator.of(context).pop(station);
  }
}
