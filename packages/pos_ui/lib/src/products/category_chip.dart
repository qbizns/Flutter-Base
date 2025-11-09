import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Chip widget for displaying and selecting categories.
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    required this.category,
    this.selected = false,
    this.onTap,
    super.key,
  });

  final Category category;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(category.name),
      selected: selected,
      onSelected: (_) => onTap?.call(),
      avatar: category.iconName != null
          ? Icon(
              _getIconData(category.iconName!),
              size: 18,
            )
          : null,
      backgroundColor: category.color != null ? _parseColor(category.color!) : null,
      selectedColor:
          category.color != null ? _parseColor(category.color!) : theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: selected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: selected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  IconData _getIconData(String iconName) {
    // Map common icon names to IconData
    switch (iconName.toLowerCase()) {
      case 'pizza':
        return Icons.local_pizza;
      case 'salad':
        return Icons.eco;
      case 'burger':
        return Icons.lunch_dining;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.category;
    }
  }
}

/// Horizontal scrollable list of category chips.
class CategoryChipList extends StatelessWidget {
  const CategoryChipList({
    required this.categories,
    this.selectedCategoryId,
    this.onCategoryTap,
    this.showAllOption = true,
    super.key,
  });

  final List<Category> categories;
  final String? selectedCategoryId;
  final void Function(Category?)? onCategoryTap;
  final bool showAllOption;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (showAllOption) ...[
            FilterChip(
              label: const Text('All'),
              selected: selectedCategoryId == null,
              onSelected: (_) => onCategoryTap?.call(null),
              avatar: const Icon(Icons.grid_view, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          ...categories.map(
            (category) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                category: category,
                selected: category.id == selectedCategoryId,
                onTap: () => onCategoryTap?.call(category),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
