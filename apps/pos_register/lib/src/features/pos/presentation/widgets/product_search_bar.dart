/// Product Search Bar Widget
/// Vodo-style search bar for products with barcode scanning support
library;

import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Product search bar following Odoo POS patterns
class ProductSearchBar extends StatefulWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onBarcodeScan;
  final String? initialQuery;
  final int? resultCount;

  const ProductSearchBar({
    super.key,
    required this.onSearchChanged,
    this.onBarcodeScan,
    this.initialQuery,
    this.resultCount,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClear() {
    _controller.clear();
    widget.onSearchChanged('');
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: VodoDimensions.paddingMd,
      decoration: const BoxDecoration(
        color: VodoColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(
            color: VodoColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Search input
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: VodoColors.backgroundSecondary,
                borderRadius: VodoDimensions.borderRadiusMd,
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? VodoColors.primary
                      : VodoColors.border,
                  width: _focusNode.hasFocus ? 2 : 1,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                decoration: InputDecoration(
                  hintText: 'Search products by name, SKU, or barcode...',
                  hintStyle: VodoTextStyles.bodyMedium.copyWith(
                    color: VodoColors.textTertiary,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: _focusNode.hasFocus
                        ? VodoColors.primary
                        : VodoColors.textSecondary,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Result count (Odoo-style)
                            if (widget.resultCount != null) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: VodoColors.primary.withOpacity(0.1),
                                  borderRadius: VodoDimensions.borderRadiusSm,
                                ),
                                child: Text(
                                  '${widget.resultCount}',
                                  style: VodoTextStyles.labelSmall.copyWith(
                                    color: VodoColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            // Clear button
                            IconButton(
                              icon: const Icon(
                                Icons.clear,
                                size: 20,
                              ),
                              onPressed: _handleClear,
                              color: VodoColors.textSecondary,
                              tooltip: 'Clear search',
                            ),
                          ],
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: VodoTextStyles.bodyMedium,
                onChanged: (value) {
                  setState(() {}); // Update to show/hide clear button
                  widget.onSearchChanged(value);
                },
              ),
            ),
          ),

          // Barcode scanner button (Odoo-style)
          if (widget.onBarcodeScan != null) ...[
            const SizedBox(width: VodoDimensions.spacingMd),
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: VodoColors.accent,
                borderRadius: VodoDimensions.borderRadiusMd,
                boxShadow: [
                  BoxShadow(
                    color: VodoColors.accent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.qr_code_scanner,
                  color: VodoColors.textOnPrimary,
                ),
                onPressed: widget.onBarcodeScan,
                tooltip: 'Scan barcode',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Quick filters bar (Odoo-style category filters)
class ProductQuickFilters extends StatelessWidget {
  final List<String> filters;
  final String? selectedFilter;
  final ValueChanged<String?> onFilterSelected;

  const ProductQuickFilters({
    super.key,
    required this.filters,
    this.selectedFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: VodoDimensions.spacingMd),
      decoration: const BoxDecoration(
        color: VodoColors.backgroundPrimary,
        border: Border(
          bottom: BorderSide(
            color: VodoColors.border,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" filter
          _buildFilterChip(
            label: 'All Products',
            isSelected: selectedFilter == null,
            onTap: () => onFilterSelected(null),
          ),
          const SizedBox(width: VodoDimensions.spacingSm),

          // Individual filters
          ...filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: VodoDimensions.spacingSm),
              child: _buildFilterChip(
                label: filter,
                isSelected: selectedFilter == filter,
                onTap: () => onFilterSelected(filter),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: VodoColors.backgroundSecondary,
      selectedColor: VodoColors.primary,
      labelStyle: VodoTextStyles.labelMedium.copyWith(
        color: isSelected ? VodoColors.textOnPrimary : VodoColors.textPrimary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
        side: BorderSide(
          color: isSelected ? VodoColors.primary : VodoColors.border,
          width: isSelected ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
    );
  }
}

/// Product grid header with search and filters
class ProductGridHeader extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;
  final VoidCallback? onBarcodeScan;
  final List<String>? quickFilters;
  final String? selectedFilter;
  final ValueChanged<String?>? onFilterSelected;
  final String? searchQuery;
  final int? resultCount;

  const ProductGridHeader({
    super.key,
    required this.onSearchChanged,
    this.onBarcodeScan,
    this.quickFilters,
    this.selectedFilter,
    this.onFilterSelected,
    this.searchQuery,
    this.resultCount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        ProductSearchBar(
          onSearchChanged: onSearchChanged,
          onBarcodeScan: onBarcodeScan,
          initialQuery: searchQuery,
          resultCount: resultCount,
        ),

        // Quick filters (if provided)
        if (quickFilters != null &&
            quickFilters!.isNotEmpty &&
            onFilterSelected != null)
          ProductQuickFilters(
            filters: quickFilters!,
            selectedFilter: selectedFilter,
            onFilterSelected: onFilterSelected!,
          ),
      ],
    );
  }
}
