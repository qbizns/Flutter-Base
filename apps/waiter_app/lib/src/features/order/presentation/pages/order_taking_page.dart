import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';
import 'package:pos_ui/pos_ui.dart';

import '../../data/services/waiter_offline_order_service.dart';
import '../../data/providers/tables_realtime_provider.dart';

/// Order Taking Page - Mobile-optimized order entry
///
/// Features:
/// - Product grid with search
/// - Category filtering
/// - Quick add to cart with modifiers
/// - Cart summary with quantity adjustments
/// - Special instructions per item
/// - Order notes for kitchen
/// - Offline-first order creation
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
  final TextEditingController _orderNotesController = TextEditingController();
  final List<OrderItem> _cartItems = [];
  int? _guestCount;

  @override
  void dispose() {
    _searchController.dispose();
    _orderNotesController.dispose();
    super.dispose();
  }

  double get _cartSubtotal {
    return _cartItems.fold(0.0, (sum, item) {
      final itemTotal = item.price * item.quantity;
      final modifiersTotal = item.modifiers?.fold(0.0, (sum, mod) {
            return sum + (mod.price * item.quantity);
          }) ??
          0.0;
      return sum + itemTotal + modifiersTotal;
    });
  }

  double get _cartTax => _cartSubtotal * 0.1; // 10% tax
  double get _cartTotal => _cartSubtotal + _cartTax;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tableState = ref.watch(tablesRealtimeProvider);
    final table = tableState.tables[widget.tableId];
    final syncStatusAsync = ref.watch(waiterSyncStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table ${table?.table.name ?? widget.tableId}'),
            syncStatusAsync.when(
              data: (status) {
                if (status == SyncStatus.syncing) {
                  return Text(
                    'Syncing...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          if (_cartItems.isNotEmpty)
            IconButton(
              icon: Badge(
                label: Text('${_cartItems.length}'),
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

          // Category chips (TODO: Re-enable when products provider is available)
          // categoriesAsync.when(
          //   data: (categories) => CategoryChipList(
          //     categories: categories,
          //     selectedCategoryId: _selectedCategoryId,
          //     onCategorySelected: (categoryId) {
          //       setState(() {
          //         _selectedCategoryId = categoryId;
          //       });
          //     },
          //   ),
          //   loading: () => const SizedBox(height: 56),
          //   error: (_, __) => const SizedBox(height: 56),
          // ),

          const Divider(height: 1),

          // Products grid (TODO: Re-enable when products provider is available)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Menu Integration Pending',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Product catalog will be available once backend is integrated',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Demo: Add test item button
                  FilledButton.icon(
                    onPressed: () => _addDemoItem(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Demo Item'),
                  ),
                ],
              ),
            ),
          ),
          // Original products grid (commented out for now)
          /*
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
          */
        ],
      ),
      floatingActionButton: _cartItems.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _sendToKitchen(context),
              icon: const Icon(Icons.send),
              label: Text('Send (${_cartItems.length})'),
            )
          : null,
    );
  }

  /// Add demo item to cart for testing
  void _addDemoItem() {
    final demoItem = OrderItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productId: 'demo-product',
      name: 'Demo Burger',
      price: 12.99,
      quantity: 1,
      modifiers: [],
      specialInstructions: '',
    );

    setState(() {
      _cartItems.add(demoItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo item added to cart'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
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

  // TODO: Re-enable when products are integrated
  // Future<void> _addToCart(BuildContext context, Product product) async {
  //   List<ProductModifier>? selectedModifiers;
  //   String? specialInstructions;
  //
  //   // Show modifier selector if product has modifiers
  //   if (product.modifiers.isNotEmpty) {
  //     final result = await _showModifierDialog(context, product);
  //     if (result == null) return; // User cancelled
  //     selectedModifiers = result.$1;
  //     specialInstructions = result.$2;
  //   }
  //
  //   // Create order item
  //   final orderItem = OrderItem(
  //     id: DateTime.now().millisecondsSinceEpoch.toString(),
  //     productId: product.id,
  //     name: product.name,
  //     price: product.price,
  //     quantity: 1,
  //     modifiers: selectedModifiers ?? [],
  //     specialInstructions: specialInstructions ?? '',
  //   );
  //
  //   setState(() {
  //     _cartItems.add(orderItem);
  //   });
  //
  //   if (context.mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text('${product.name} added to cart'),
  //         duration: const Duration(seconds: 1),
  //         behavior: SnackBarBehavior.floating,
  //       ),
  //     );
  //   }
  // }

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
            cartItems: _cartItems,
            orderNotesController: _orderNotesController,
            subtotal: _cartSubtotal,
            tax: _cartTax,
            total: _cartTotal,
            onUpdateQuantity: (itemId, quantity) {
              setState(() {
                final item = _cartItems.firstWhere((i) => i.id == itemId);
                final index = _cartItems.indexOf(item);
                _cartItems[index] = item.copyWith(quantity: quantity);
              });
            },
            onRemoveItem: (itemId) {
              setState(() {
                _cartItems.removeWhere((i) => i.id == itemId);
              });
            },
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
    if (_cartItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    // Show guest count dialog if not set
    if (_guestCount == null) {
      final count = await _showGuestCountDialog(context);
      if (count == null || !context.mounted) return;
      _guestCount = count;
    }

    // Show confirmation dialog with order summary
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send to Kitchen?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table ${widget.tableId}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Guests: $_guestCount'),
            Text('Items: ${_cartItems.length}'),
            Text('Total: \$${_cartTotal.toStringAsFixed(2)}'),
            if (_orderNotesController.text.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Notes: ${_orderNotesController.text}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ],
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

    try {
      final tableState = ref.read(tablesRealtimeProvider);
      final table = tableState.tables[widget.tableId];
      final offlineService = ref.read(waiterOfflineOrderServiceProvider);

      // Create order using offline service (optimistic update)
      final order = await offlineService.createOrder(
        tableId: widget.tableId,
        tableName: table?.table.name ?? widget.tableId,
        items: _cartItems,
        notes: _orderNotesController.text.isEmpty
            ? null
            : _orderNotesController.text,
        guestCount: _guestCount,
      );

      // Send to kitchen
      await offlineService.sendToKitchen(order.id);

      // Update table status
      final tablesNotifier = ref.read(tablesRealtimeProvider.notifier);
      await tablesNotifier.updateTableStatus(
        tableId: widget.tableId,
        status: 'occupied',
        guestCount: _guestCount,
      );

      if (context.mounted) {
        // Clear cart
        setState(() {
          _cartItems.clear();
          _orderNotesController.clear();
          _guestCount = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order sent to kitchen (${order.id})'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () {
                context.go('/orders/active');
              },
            ),
          ),
        );

        // Go back to floor plan
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Show guest count dialog
  Future<int?> _showGuestCountDialog(BuildContext context) async {
    int selectedCount = 2;

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Number of Guests'),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$selectedCount',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    iconSize: 40,
                    onPressed: selectedCount > 1
                        ? () => setState(() => selectedCount--)
                        : null,
                  ),
                  const SizedBox(width: 32),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    iconSize: 40,
                    onPressed: () => setState(() => selectedCount++),
                  ),
                ],
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
            onPressed: () => Navigator.pop(context, selectedCount),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

/// Cart Bottom Sheet - Shows cart contents with order notes
class _CartBottomSheet extends StatelessWidget {
  const _CartBottomSheet({
    required this.scrollController,
    required this.cartItems,
    required this.orderNotesController,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onSendToKitchen,
  });

  final ScrollController scrollController;
  final List<OrderItem> cartItems;
  final TextEditingController orderNotesController;
  final double subtotal;
  final double tax;
  final double total;
  final Function(String itemId, int quantity) onUpdateQuantity;
  final Function(String itemId) onRemoveItem;
  final VoidCallback onSendToKitchen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            child: ListView(
              controller: scrollController,
              children: [
                // Items list
                ...cartItems.map((item) => Card(
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
                                    onUpdateQuantity(item.id, item.quantity + 1);
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
                                      onUpdateQuantity(item.id, item.quantity - 1);
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
                                    item.name,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (item.modifiers != null &&
                                      item.modifiers!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    ...item.modifiers!.map(
                                      (mod) => Text(
                                        '+ ${mod.name}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color:
                                              theme.colorScheme.onSurface.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                  ],
                                  if (item.specialInstructions.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Note: ${item.specialInstructions}',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.secondary,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${(item.price * item.quantity).toStringAsFixed(2)}',
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
                              onPressed: () => onRemoveItem(item.id),
                            ),
                          ],
                        ),
                      ),
                    )),

                const SizedBox(height: 16),

                // Order notes
                TextField(
                  controller: orderNotesController,
                  decoration: InputDecoration(
                    labelText: 'Order Notes (optional)',
                    hintText: 'Special requests, allergies, etc.',
                    prefixIcon: const Icon(Icons.note),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                ),
              ],
            ),
          ),

          const Divider(),

          // Totals
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Subtotal', style: theme.textTheme.bodyLarge),
                  Text(
                    '\$${subtotal.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Tax (10%)', style: theme.textTheme.bodyLarge),
                  Text(
                    '\$${tax.toStringAsFixed(2)}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
              const Divider(height: 16),
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
                    '\$${total.toStringAsFixed(2)}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
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
