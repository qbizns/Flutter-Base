import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

/// Menu Page - Product browsing for kiosk
///
/// Features:
/// - Large product cards with images
/// - Category navigation
/// - Add to cart with visual feedback
/// - Cart summary always visible
/// - Large touch targets for accessibility
class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsProvider(
      categoryId: _selectedCategoryId,
    ));
    final categoriesAsync = ref.watch(categoriesProvider);
    final cart = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Items'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 32),
          onPressed: () => _confirmGoBack(context),
          tooltip: 'Go Back',
        ),
        actions: [
          // Cart button (always visible)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton.icon(
              onPressed: cart.items.isEmpty ? null : () => context.go('/cart'),
              icon: Badge(
                label: Text('${cart.items.length}'),
                isLabelVisible: cart.items.isNotEmpty,
                child: const Icon(Icons.shopping_cart, size: 28),
              ),
              label: Text(
                cart.items.isEmpty
                    ? 'Cart Empty'
                    : '\$${cart.total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge,
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category selector
          categoriesAsync.when(
            data: (categories) => Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // All categories chip
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: const Text(
                          'All Items',
                          style: TextStyle(fontSize: 18),
                        ),
                        selected: _selectedCategoryId == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryId = null;
                            });
                          }
                        },
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                      ),
                    ),
                    // Category chips
                    ...categories.map((category) => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: FilterChip(
                            label: Text(
                              category.name,
                              style: const TextStyle(fontSize: 18),
                            ),
                            selected: _selectedCategoryId == category.id,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedCategoryId = category.id;
                                });
                              }
                            },
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
            loading: () => const SizedBox(height: 80),
            error: (_, __) => const SizedBox(height: 80),
          ),

          const Divider(height: 1),

          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyState(context);
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(24),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 24,
                    mainAxisSpacing: 24,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildKioskProductCard(context, product);
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 80,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Unable to load menu',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(productsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_outlined,
            size: 120,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            'No items in this category',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Try selecting a different category',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKioskProductCard(BuildContext context, Product product) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _addToCart(context, product),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image placeholder
            Expanded(
              flex: 3,
              child: Container(
                color: theme.colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.restaurant,
                  size: 80,
                  color: theme.colorScheme.primary.withOpacity(0.5),
                ),
              ),
            ),

            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Name
                    Text(
                      product.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Description
                    if (product.description?.isNotEmpty ?? false)
                      Text(
                        product.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                    // Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        Icon(
                          Icons.add_circle,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(BuildContext context, Product product) async {
    List<SelectedModifier>? selectedModifiers;

    // Show modifier selector if product has modifiers
    if (product.allowModifiers && product.modifierGroups.isNotEmpty) {
      selectedModifiers = await ModifierSelector.show(
        context,
        product: product,
      );
      if (selectedModifiers == null) return; // User cancelled
    }

    // Create order item
    final orderItem = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: product.id,
      productName: product.name,
      basePrice: product.price,
      quantity: 1,
      selectedModifiers: selectedModifiers ?? [],
      taxPercent: 8.5,
    );

    // Add to cart with animation
    ref.read(cartNotifierProvider.notifier).addItem(orderItem);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                '${product.name} added to cart',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmGoBack(BuildContext context) async {
    final cart = ref.read(cartNotifierProvider);

    if (cart.items.isEmpty) {
      context.go('/');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: const Text(
          'Are you sure you want to go back? Your cart will be cleared.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.all(20),
            ),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              textStyle: const TextStyle(fontSize: 18),
              padding: const EdgeInsets.all(20),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(cartNotifierProvider.notifier).clear();
      context.go('/');
    }
  }
}
