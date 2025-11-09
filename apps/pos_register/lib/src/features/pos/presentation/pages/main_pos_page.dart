import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

/// Main POS screen with product grid and cart
class MainPosPage extends ConsumerStatefulWidget {
  const MainPosPage({super.key});

  @override
  ConsumerState<MainPosPage> createState() => _MainPosPageState();
}

class _MainPosPageState extends ConsumerState<MainPosPage> {
  String? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider());
    final productsAsync = ref.watch(productsProvider(
      categoryId: _selectedCategoryId,
    ));
    final cart = ref.watch(cartNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Register'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${cart.itemsCount}'),
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () {
                // Cart is already visible on desktop, this is for mobile
                if (MediaQuery.of(context).size.width < 900) {
                  _showCartBottomSheet(context);
                }
              },
            ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return Row(
            children: [
              // Products Section
              Expanded(
                flex: isDesktop ? 2 : 1,
                child: Column(
                  children: [
                    // Categories
                    categoriesAsync.when(
                      data: (categories) => CategoryChipList(
                        categories: categories,
                        selectedCategoryId: _selectedCategoryId,
                        onCategoryTap: (category) {
                          setState(() {
                            _selectedCategoryId = category?.id;
                          });
                        },
                      ),
                      loading: () => const SizedBox(height: 48),
                      error: (_, __) => const SizedBox(height: 48),
                    ),

                    // Products Grid
                    Expanded(
                      child: productsAsync.when(
                        data: (products) => ProductGrid(
                          products: products,
                          onProductTap: (product) => _addToCart(product),
                        ),
                        loading: () => const Center(
                          child: CircularProgressIndicator(),
                        ),
                        error: (error, _) => Center(
                          child: Text('Error: $error'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Cart Panel (Desktop only)
              if (isDesktop)
                SizedBox(
                  width: 400,
                  child: CartPanel(
                    cart: cart,
                    onItemQuantityChanged: (item, quantity) {
                      ref.read(cartNotifierProvider.notifier).updateItemQuantity(
                            item.id,
                            quantity,
                          );
                    },
                    onItemRemoved: (item) {
                      ref.read(cartNotifierProvider.notifier).removeItem(item.id);
                    },
                    onCheckout: () => context.push('/checkout'),
                    onClear: () {
                      ref.read(cartNotifierProvider.notifier).clear();
                    },
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: cart.isNotEmpty &&
              MediaQuery.of(context).size.width < 900
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/checkout'),
              icon: const Icon(Icons.shopping_cart_checkout),
              label: Text('Checkout - \$${cart.total.toStringAsFixed(2)}'),
            )
          : null,
    );
  }

  Future<void> _addToCart(Product product) async {
    // If product has modifiers, show selector
    List<SelectedModifier>? selectedModifiers;
    if (product.allowModifiers && product.modifierGroups.isNotEmpty) {
      selectedModifiers = await ModifierSelector.show(
        context,
        product: product,
      );

      if (selectedModifiers == null) {
        return; // User cancelled
      }
    }

    // Create order item
    final orderItem = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: product.id,
      productName: product.name,
      basePrice: product.price,
      quantity: 1,
      productSku: product.sku,
      productImageUrl: product.imageUrl,
      categoryId: product.categoryId,
      selectedModifiers: selectedModifiers ?? [],
      taxPercent: 8.5, // TODO: Get from settings
    );

    // Add to cart
    ref.read(cartNotifierProvider.notifier).addItem(orderItem);

    // Show confirmation
    if (mounted) {
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
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => CartPanel(
          cart: ref.read(cartNotifierProvider),
          onItemQuantityChanged: (item, quantity) {
            ref.read(cartNotifierProvider.notifier).updateItemQuantity(
                  item.id,
                  quantity,
                );
          },
          onItemRemoved: (item) {
            ref.read(cartNotifierProvider.notifier).removeItem(item.id);
          },
          onCheckout: () {
            Navigator.pop(context);
            context.push('/checkout');
          },
          onClear: () {
            ref.read(cartNotifierProvider.notifier).clear();
          },
        ),
      ),
    );
  }
}
