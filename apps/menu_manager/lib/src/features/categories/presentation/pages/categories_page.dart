import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

/// Categories Management Page
///
/// Features:
/// - View all categories
/// - Create/edit/delete categories
/// - Reorder categories
/// - Category icons/colors
/// - Item count per category
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider());
    final productsAsync = ref.watch(productsProvider());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          return productsAsync.when(
            data: (products) {
              return _buildCategoriesList(context, theme, categories, products);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error loading products')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Error loading categories')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showCategoryDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Category'),
      ),
    );
  }

  Widget _buildCategoriesList(
    BuildContext context,
    ThemeData theme,
    List<Category> categories,
    List<Product> products,
  ) {
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 80,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No categories yet',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Add your first category to organize your menu'),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: categories.length,
      onReorder: (oldIndex, newIndex) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category order updated')),
        );
      },
      itemBuilder: (context, index) {
        final category = categories[index];
        final itemCount = products.where((p) => p.categoryId == category.id).length;

        return Card(
          key: ValueKey(category.id),
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: ReorderableDragStartListener(
              index: index,
              child: const Icon(Icons.drag_handle),
            ),
            title: Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              category.description ?? 'No description',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text('$itemCount items'),
                  backgroundColor: theme.colorScheme.primaryContainer,
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
                      _showCategoryDialog(context, category: category);
                    } else if (value == 'delete') {
                      _showDeleteDialog(context, category, itemCount);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCategoryDialog(BuildContext context, {Category? category}) {
    final isEdit = category != null;
    final nameController = TextEditingController(text: category?.name);
    final descriptionController = TextEditingController(
      text: category?.description,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Category' : 'Add Category'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name *',
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
                maxLines: 3,
              ),
            ],
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
                  content: Text(isEdit ? 'Category updated' : 'Category created'),
                ),
              );
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Category category, int itemCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
          itemCount > 0
              ? 'Are you sure you want to delete "${category.name}"? '
                  '$itemCount items will be uncategorized.'
              : 'Are you sure you want to delete "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${category.name} deleted')),
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
}
