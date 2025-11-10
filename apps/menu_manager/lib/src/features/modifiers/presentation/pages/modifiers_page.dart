import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/modifier.dart';

/// Modifiers Management Page
///
/// Features:
/// - View all modifiers/add-ons
/// - Create/edit/delete modifiers
/// - Modifier types (add-on, removal, choice)
/// - Pricing for modifiers
/// - Group modifiers
class ModifiersPage extends ConsumerWidget {
  const ModifiersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final modifiers = _getMockModifiers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifiers & Add-ons'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistics
          _buildStatistics(theme, modifiers),

          const SizedBox(height: 24),

          // Modifiers list
          ...modifiers.map((modifier) => _buildModifierCard(
                context,
                theme,
                modifier,
              )),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showModifierDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Modifier'),
      ),
    );
  }

  Widget _buildStatistics(ThemeData theme, List<Modifier> modifiers) {
    final addons = modifiers.where((m) => m.type == ModifierType.addon).length;
    final choices = modifiers.where((m) => m.type == ModifierType.choice).length;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '${modifiers.length}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Total Modifiers'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '$addons',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Add-ons'),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '$choices',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Choices'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModifierCard(
    BuildContext context,
    ThemeData theme,
    Modifier modifier,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Icon(
          _getModifierIcon(modifier.type),
          color: _getModifierColor(modifier.type),
        ),
        title: Text(
          modifier.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(modifier.type.label),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (modifier.price > 0)
              Chip(
                label: Text('+\$${modifier.price.toStringAsFixed(2)}'),
                backgroundColor: Colors.green.withOpacity(0.2),
              ),
            const SizedBox(width: 8),
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Delete'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  _showModifierDialog(context, modifier: modifier);
                } else if (value == 'delete') {
                  _showDeleteDialog(context, modifier);
                }
              },
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (modifier.description != null) ...[
                  Text(
                    modifier.description!,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                ],
                if (modifier.options != null) ...[
                  Text(
                    'Options:',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: modifier.options!.map((option) {
                      return Chip(label: Text(option));
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showModifierDialog(BuildContext context, {Modifier? modifier}) {
    final isEdit = modifier != null;
    final nameController = TextEditingController(text: modifier?.name);
    final descriptionController = TextEditingController(
      text: modifier?.description,
    );
    final priceController = TextEditingController(
      text: modifier?.price.toString() ?? '0.00',
    );
    ModifierType selectedType = modifier?.type ?? ModifierType.addon;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit Modifier' : 'Add Modifier'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Modifier Name *',
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ModifierType>(
                          value: selectedType,
                          decoration: const InputDecoration(
                            labelText: 'Type *',
                            border: OutlineInputBorder(),
                          ),
                          items: ModifierType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.label),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: priceController,
                          decoration: const InputDecoration(
                            labelText: 'Additional Price',
                            prefixText: '\$',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (selectedType == ModifierType.choice) ...[
                    const Text(
                      'Options (comma-separated)',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    const TextField(
                      decoration: InputDecoration(
                        hintText: 'Small, Medium, Large',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Modifier updated' : 'Modifier created'),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Modifier modifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Modifier'),
        content: Text('Are you sure you want to delete "${modifier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${modifier.name} deleted')),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getModifierIcon(ModifierType type) {
    switch (type) {
      case ModifierType.addon:
        return Icons.add_circle;
      case ModifierType.removal:
        return Icons.remove_circle;
      case ModifierType.choice:
        return Icons.radio_button_checked;
      case ModifierType.quantity:
        return Icons.numbers;
    }
  }

  Color _getModifierColor(ModifierType type) {
    switch (type) {
      case ModifierType.addon:
        return Colors.green;
      case ModifierType.removal:
        return Colors.red;
      case ModifierType.choice:
        return Colors.blue;
      case ModifierType.quantity:
        return Colors.orange;
    }
  }

  List<Modifier> _getMockModifiers() {
    return const [
      Modifier(
        id: '1',
        name: 'Extra Cheese',
        description: 'Additional cheese topping',
        price: 1.50,
        type: ModifierType.addon,
      ),
      Modifier(
        id: '2',
        name: 'No Onions',
        description: 'Remove onions from the dish',
        price: 0.00,
        type: ModifierType.removal,
      ),
      Modifier(
        id: '3',
        name: 'Size',
        description: 'Choose your size',
        price: 0.00,
        type: ModifierType.choice,
        options: ['Small', 'Medium', 'Large', 'Extra Large'],
      ),
      Modifier(
        id: '4',
        name: 'Spice Level',
        description: 'How spicy would you like it?',
        price: 0.00,
        type: ModifierType.choice,
        options: ['Mild', 'Medium', 'Hot', 'Extra Hot'],
      ),
      Modifier(
        id: '5',
        name: 'Extra Bacon',
        description: 'Add crispy bacon strips',
        price: 2.00,
        type: ModifierType.addon,
      ),
      Modifier(
        id: '6',
        name: 'Avocado',
        description: 'Fresh avocado slices',
        price: 2.50,
        type: ModifierType.addon,
      ),
    ];
  }
}
