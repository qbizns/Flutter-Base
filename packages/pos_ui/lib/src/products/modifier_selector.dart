import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

/// Bottom sheet for selecting product modifiers.
class ModifierSelector extends StatefulWidget {
  const ModifierSelector({
    required this.product,
    this.initialSelections = const [],
    super.key,
  });

  final Product product;
  final List<SelectedModifier> initialSelections;

  @override
  State<ModifierSelector> createState() => _ModifierSelectorState();

  /// Show modifier selector as bottom sheet.
  static Future<List<SelectedModifier>?> show(
    BuildContext context, {
    required Product product,
    List<SelectedModifier> initialSelections = const [],
  }) {
    return showModalBottomSheet<List<SelectedModifier>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => ModifierSelector(
        product: product,
        initialSelections: initialSelections,
      ),
    );
  }
}

class _ModifierSelectorState extends State<ModifierSelector> {
  late Map<String, List<String>> _selections;
  late List<SelectedModifier> _selectedModifiers;

  @override
  void initState() {
    super.initState();
    _selections = {};
    _selectedModifiers = List.from(widget.initialSelections);

    // Initialize selections from initial modifiers
    for (final modifier in widget.initialSelections) {
      for (final group in widget.product.modifierGroups) {
        if (group.modifiers.any((m) => m.id == modifier.modifierId)) {
          _selections[group.id] ??= [];
          _selections[group.id]!.add(modifier.modifierId);
        }
      }
    }

    // Set default selections for required groups
    for (final group in widget.product.modifierGroups) {
      if (group.isRequired && !_selections.containsKey(group.id)) {
        final defaultModifier = group.modifiers.firstWhere(
          (m) => m.isDefault,
          orElse: () => group.modifiers.first,
        );
        _selections[group.id] = [defaultModifier.id];
        _selectedModifiers.add(SelectedModifier(
          modifierId: defaultModifier.id,
          modifierName: defaultModifier.name,
          price: defaultModifier.price,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: theme.textTheme.titleLarge,
                        ),
                        Text(
                          'Customize your order',
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

            // Modifier Groups
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: widget.product.modifierGroups.length,
                itemBuilder: (context, index) {
                  final group = widget.product.modifierGroups[index];
                  return _buildModifierGroup(group);
                },
              ),
            ),

            // Footer with Add Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor),
                ),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _canConfirm() ? _confirm : null,
                    child: const Text('Add to Order'),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModifierGroup(ModifierGroup group) {
    final theme = Theme.of(context);
    final selections = _selections[group.id] ?? [];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    group.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (group.isRequired)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Required',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _getGroupDescription(group),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),
            ...group.modifiers.map((modifier) {
              final isSelected = selections.contains(modifier.id);
              return _buildModifierTile(group, modifier, isSelected);
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildModifierTile(
    ModifierGroup group,
    Modifier modifier,
    bool isSelected,
  ) {
    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) => _toggleModifier(group, modifier, value ?? false),
      title: Text(modifier.name),
      subtitle: modifier.price > 0
          ? Text('+\$${modifier.price.toStringAsFixed(2)}')
          : null,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  String _getGroupDescription(ModifierGroup group) {
    if (group.selectionType == ModifierSelectionType.single) {
      return 'Select one option';
    } else {
      if (group.maxSelection != null) {
        return 'Select up to ${group.maxSelection} options';
      }
      return 'Select multiple options';
    }
  }

  void _toggleModifier(ModifierGroup group, Modifier modifier, bool selected) {
    setState(() {
      _selections[group.id] ??= [];
      final selections = _selections[group.id]!;

      if (selected) {
        // Handle single selection groups
        if (group.selectionType == ModifierSelectionType.single) {
          // Remove previous selections for this group
          final previousSelections = List<String>.from(selections);
          selections.clear();

          // Remove previous modifiers from selectedModifiers
          _selectedModifiers.removeWhere((sm) {
            return previousSelections.contains(sm.modifierId);
          });
        }

        // Check max selection
        if (group.maxSelection != null && selections.length >= group.maxSelection!) {
          return;
        }

        selections.add(modifier.id);
        _selectedModifiers.add(SelectedModifier(
          modifierId: modifier.id,
          modifierName: modifier.name,
          price: modifier.price,
        ));
      } else {
        selections.remove(modifier.id);
        _selectedModifiers.removeWhere((sm) => sm.modifierId == modifier.id);
      }
    });
  }

  bool _canConfirm() {
    // Check all required groups have valid selections
    for (final group in widget.product.modifierGroups) {
      final selections = _selections[group.id] ?? [];
      if (!group.isValidSelection(selections)) {
        return false;
      }
    }
    return true;
  }

  void _confirm() {
    Navigator.pop(context, _selectedModifiers);
  }
}
