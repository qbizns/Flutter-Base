import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

import '../../../session/presentation/widgets/session_status_bar.dart';
import '../../../session/presentation/widgets/session_guard.dart';
import '../../../sync/presentation/widgets/sync_status_indicator.dart';
import '../widgets/vodo_product_grid.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/vodo_cart_panel.dart';
import '../widgets/dialogs/customer_select_dialog.dart';
import '../widgets/dialogs/order_notes_dialog.dart';
import '../widgets/dialogs/discount_dialog.dart';

/// Main POS screen with product grid and cart
class MainPosPage extends ConsumerStatefulWidget {
  const MainPosPage({super.key});

  @override
  ConsumerState<MainPosPage> createState() => _MainPosPageState();
}

class _MainPosPageState extends ConsumerState<MainPosPage> {
  String? _selectedCategoryId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider());
    final productsAsync = ref.watch(productsProvider(
      categoryId: _selectedCategoryId,
    ));
    final cart = ref.watch(cartNotifierProvider);

    // Filter products by search query
    final filteredProducts = productsAsync.when(
      data: (products) {
        if (_searchQuery.isEmpty) return products;
        final query = _searchQuery.toLowerCase();
        return products.where((product) {
          return product.name.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query) ||
              (product.barcode?.toLowerCase().contains(query) ?? false);
        }).toList();
      },
      loading: () => <Product>[],
      error: (_, __) => <Product>[],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS Register'),
        actions: [
          // Sync status indicator
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(child: SyncStatusIndicator()),
          ),
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
      body: SessionGuard(
        requireOpenSession: true,
        child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          return Row(
            children: [
              // Products Section
              Expanded(
                flex: isDesktop ? 2 : 1,
                child: Column(
                  children: [
                    // Session Status Bar (Odoo-style)
                    const SessionStatusBar(),

                    // Product Search Bar (Vodo-style)
                    ProductSearchBar(
                      onSearchChanged: (query) {
                        setState(() => _searchQuery = query);
                      },
                      onBarcodeScan: _handleBarcodeScan,
                      resultCount: _searchQuery.isNotEmpty ? filteredProducts.length : null,
                      initialQuery: _searchQuery,
                    ),

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

                    // Products Grid (Vodo-style)
                    Expanded(
                      child: productsAsync.when(
                        data: (_) => ResponsiveVodoProductGrid(
                          products: filteredProducts,
                          onProductTap: (product) => _addToCart(product),
                          showStock: true,
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

              // Cart Panel (Desktop only) - Vodo-style
              if (isDesktop)
                SizedBox(
                  width: 400,
                  child: VodoCartPanel(
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
                    onCheckout: () => context.push('/payment'),
                    onClear: () {
                      ref.read(cartNotifierProvider.notifier).clear();
                    },
                    onCustomerSelect: () => _showCustomerSelect(context),
                    onNotesAdd: () => _showNotesDialog(context),
                    onDiscountApply: () => _showDiscountDialog(context),
                  ),
                ),
            ],
          );
        },
        ),
      ),
      floatingActionButton: cart.isNotEmpty &&
              MediaQuery.of(context).size.width < 900
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/payment'),
              icon: const Icon(Icons.payment),
              label: Text('Pay - \$${cart.total.toStringAsFixed(2)}'),
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
        builder: (context, scrollController) => VodoCartPanel(
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
          onCustomerSelect: () => _showCustomerSelect(context),
          onNotesAdd: () => _showNotesDialog(context),
          onDiscountApply: () => _showDiscountDialog(context),
        ),
      ),
    );
  }

  void _handleBarcodeScan() {
    // TODO: Implement barcode scanning with Device Bridge (Day 4-5)
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barcode scanning will be implemented in Day 4-5'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _showCustomerSelect(BuildContext context) async {
    final customer = await CustomerSelectDialog.show(context);
    if (customer != null && mounted) {
      ref.read(cartNotifierProvider.notifier).setCustomer(
            customer.id,
            customer.name,
          );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Customer: ${customer.name}'),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _showNotesDialog(BuildContext context) async {
    final cart = ref.read(cartNotifierProvider);
    final notes = await OrderNotesDialog.show(
      context,
      initialNotes: cart.notes,
    );
    if (notes != null && mounted) {
      ref.read(cartNotifierProvider.notifier).setNotes(notes);
      if (notes.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order notes added'),
            duration: Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _showDiscountDialog(BuildContext context) async {
    final cart = ref.read(cartNotifierProvider);
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add items to cart first'),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final discountResult = await DiscountDialog.show(
      context,
      orderTotal: cart.subtotal,
    );
    if (discountResult != null && mounted) {
      if (discountResult.type == DiscountType.percentage) {
        ref.read(cartNotifierProvider.notifier).applyDiscount(
              percent: discountResult.value,
            );
      } else {
        ref.read(cartNotifierProvider.notifier).applyDiscount(
              amount: discountResult.value,
            );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Discount applied: ${discountResult.type == DiscountType.percentage ? '${discountResult.value}%' : '\$${discountResult.value.toStringAsFixed(2)}'}',
          ),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
