import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

/// Order Taking Page - Mobile-optimized order entry
///
/// Features:
/// - Product grid with search
/// - Category filtering
/// - Quick add to cart
/// - Cart summary FAB
/// - Modifier selection
/// - Send to kitchen action
class OrderTakingPage extends ConsumerStatefulWidget {
  const OrderTakingPage({
    required this.tableId,
    super.key,
  });

  final String tableId;

  @override
  ConsumerState<OrderTakingPage> createState() => _OrderTakingPageState();
}

class _OrderTakingPageState extends ConsumerState<OrderTakingPage> {
  String? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        title: Text('Table ${widget.tableId}'),
        actions: [
          if (cart.items.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${cart.items.length}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () => _showCartBottomSheet(context),
              tooltip: 'View Cart',
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search menu...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Category chips
          categoriesAsync.when(
            data: (categories) => CategoryChipList(
              categories: categories,
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (categoryId) {
                setState(() {
                  _selectedCategoryId = categoryId;
                });
              },
            ),
            loading: () => const SizedBox(height: 56),
            error: (_, __) => const SizedBox(height: 56),
          ),

          const Divider(height: 1),

          // Products grid
          Expanded(
            child: productsAsync.when(
              data: (products) {
                final filteredProducts = _searchController.text.isEmpty
                    ? products
                    : products
                        .where((p) => p.name
                            .toLowerCase()
                            .contains(_searchController.text.toLowerCase()))
                        .toList();

                if (filteredProducts.isEmpty) {
                  return _buildEmptyState(context);
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () => _addToCart(context, product),
                    );
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
                      size: 64,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error loading products'),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => ref.invalidate(productsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: cart.items.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _sendToKitchen(context),
              icon: const Icon(Icons.send),
              label: Text('Send (${cart.items.length})'),
            )
          : null,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: theme.colorScheme.primary.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search or category',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
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

    // Add to cart
    ref.read(cartNotifierProvider.notifier).addItem(orderItem);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} added to cart'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showCartBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return _CartBottomSheet(
            scrollController: scrollController,
            onSendToKitchen: () {
              Navigator.pop(context);
              _sendToKitchen(context);
            },
          );
        },
      ),
    );
  }

  Future<void> _sendToKitchen(BuildContext context) async {
    final cart = ref.read(cartNotifierProvider);

    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send to Kitchen?'),
        content: Text(
          'Send ${cart.items.length} items to kitchen for Table ${widget.tableId}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    // Create order
    final order = Order(
      id: '',
      orderNumber: '',
      status: OrderStatus.preparing,
      orderType: OrderType.dineIn,
      items: cart.items,
      createdAt: DateTime.now(),
      tableId: widget.tableId,
      subtotal: cart.subtotal,
      taxAmount: cart.taxAmount,
      total: cart.total,
      paymentStatus: PaymentStatus.pending,
    );

    // Submit order
    final result = await ref.read(createOrderUseCaseProvider)(order);

    await result.when(
      success: (createdOrder) {
        if (context.mounted) {
          // Clear cart
          ref.read(cartNotifierProvider.notifier).clear();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order #${createdOrder.orderNumber} sent to kitchen'),
              backgroundColor: Colors.green,
            ),
          );

          // Go back to table selection
          context.go('/');
        }
      },
      failure: (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }
}

/// Cart Bottom Sheet - Shows cart contents
class _CartBottomSheet extends ConsumerWidget {
  const _CartBottomSheet({
    required this.scrollController,
    required this.onSendToKitchen,
  });

  final ScrollController scrollController;
  final VoidCallback onSendToKitchen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cart = ref.watch(cartNotifierProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Text(
            'Order Summary',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Cart items
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final item = cart.items[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Quantity controls
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.add_circle, size: 28),
                              onPressed: () {
                                ref.read(cartNotifierProvider.notifier).updateQuantity(
                                      item.id,
                                      item.quantity + 1,
                                    );
                              },
                            ),
                            Text(
                              '${item.quantity}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, size: 28),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  ref.read(cartNotifierProvider.notifier).updateQuantity(
                                        item.id,
                                        item.quantity - 1,
                                      );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Item details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.productName,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (item.selectedModifiers.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                ...item.selectedModifiers.map(
                                  (mod) => Text(
                                    '+ ${mod.modifierName}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.totalPrice.toStringAsFixed(2)}',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Remove button
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          color: theme.colorScheme.error,
                          onPressed: () {
                            ref.read(cartNotifierProvider.notifier).removeItem(item.id);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const Divider(),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\$${cart.total.toStringAsFixed(2)}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Send button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSendToKitchen,
              icon: const Icon(Icons.send),
              label: const Text('Send to Kitchen'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
