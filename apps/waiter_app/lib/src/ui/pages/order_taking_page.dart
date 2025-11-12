/// Order Taking Page
/// Interface for adding items to table orders
/// Following Odoo POS order entry patterns
library;

import 'package:device_bridge_client/device_bridge_client.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_core/pos_core.dart';

import '../../data/models/waiter_models.dart';
import '../../data/providers.dart';

// Hardware providers
final deviceBridgeClientProvider = Provider<DeviceBridgeClient>((ref) {
  final config = ref.watch(configProvider);
  final deviceBridgeUrl = config.metadata['deviceBridgeUrl'] as String? ??
      'http://localhost:8080';

  return DeviceBridgeClient(
    baseUrl: deviceBridgeUrl,
    timeout: const Duration(seconds: 30),
    debug: config.environment == Environment.development,
  );
});

final kitchenPrinterIdProvider = Provider<String?>((ref) {
  final config = ref.watch(configProvider);
  return config.metadata['kitchenPrinterId'] as String?;
});

/// Order Taking Page
/// Shows product catalog and order cart
class OrderTakingPage extends ConsumerStatefulWidget {
  final String tableId;

  const OrderTakingPage({
    super.key,
    required this.tableId,
  });

  @override
  ConsumerState<OrderTakingPage> createState() => _OrderTakingPageState();
}

class _OrderTakingPageState extends ConsumerState<OrderTakingPage> {
  TableOrder? _currentOrder;
  String? _selectedCategoryId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() => _isLoading = true);

    final service = ref.read(tableServiceProvider);
    final result = await service.getOrderForTable(widget.tableId);

    result.when(
      success: (order) {
        if (order == null) {
          // Create new order
          _createOrder();
        } else {
          setState(() {
            _currentOrder = order;
            _isLoading = false;
          });
        }
      },
      failure: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load order: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
      },
    );
  }

  Future<void> _createOrder() async {
    final service = ref.read(tableServiceProvider);
    final waiter = ref.read(currentWaiterProvider);

    if (waiter == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No waiter logged in')),
        );
      }
      return;
    }

    // Get table info
    final tableResult = await service.getTable(widget.tableId);

    tableResult.when(
      success: (table) async {
        final orderResult = await service.createOrder(
          tableId: table.id,
          tableName: table.name,
          waiterId: waiter.id,
          waiterName: waiter.name,
          guestCount: table.guestCount,
        );

        orderResult.when(
          success: (order) {
            setState(() {
              _currentOrder = order;
              _isLoading = false;
            });
          },
          failure: (failure) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to create order: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
              setState(() => _isLoading = false);
            }
          },
        );
      },
      failure: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load table: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isLoading = false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch products from pos_core
    final productsAsync = ref.watch(productsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    if (_isLoading || _currentOrder == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentOrder!.tableName),
            Text(
              'Order #${_currentOrder!.orderNumber}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          // Order status badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStatusColor(_currentOrder!.status).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentOrder!.status.name.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: _getStatusColor(_currentOrder!.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Product catalog (left side)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Category selector
                categoriesAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (categories) => _buildCategorySelector(categories),
                ),

                // Product grid
                Expanded(
                  child: productsAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (error, stack) => Center(
                      child: Text('Error: $error'),
                    ),
                    data: (products) {
                      final filteredProducts = _selectedCategoryId != null
                          ? products
                              .where((p) => p.categoryId == _selectedCategoryId)
                              .toList()
                          : products;

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return _ProductCard(
                            product: product,
                            onTap: () => _addProductToOrder(product),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Order cart (right side)
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                left: BorderSide(
                  color: colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: _buildOrderCart(),
          ),
        ],
      ),
    );
  }

  /// Build category selector
  Widget _buildCategorySelector(List<ProductCategory> categories) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            // "All" category
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text('All'),
                selected: _selectedCategoryId == null,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategoryId = null;
                  });
                },
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = _selectedCategoryId == category.id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategoryId = selected ? category.id : null;
                });
              },
            ),
          );
        },
      ),
    );
  }

  /// Build order cart
  Widget _buildOrderCart() {
    final theme = Theme.of(context);
    final order = _currentOrder!;

    return Column(
      children: [
        // Cart header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Order Items (${order.items.length})',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (order.items.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    // TODO: Clear all items
                  },
                  tooltip: 'Clear all',
                ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Cart items
        Expanded(
          child: order.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: theme.colorScheme.onSurface.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No items yet',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap products to add them',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: order.items.length,
                  itemBuilder: (context, index) {
                    final item = order.items[index];
                    return _OrderItemTile(
                      item: item,
                      onQuantityChanged: (newQty) =>
                          _updateItemQuantity(item, newQty),
                      onRemove: () => _removeItem(item),
                    );
                  },
                ),
        ),

        // Order summary
        const Divider(height: 1),
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _SummaryRow(
                label: 'Subtotal',
                value: '\$${order.subtotal.toStringAsFixed(2)}',
              ),
              _SummaryRow(
                label: 'Tax (10%)',
                value: '\$${order.tax.toStringAsFixed(2)}',
              ),
              const Divider(),
              _SummaryRow(
                label: 'Total',
                value: '\$${order.total.toStringAsFixed(2)}',
                isTotal: true,
              ),
              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: order.items.isEmpty ? null : _saveOrder,
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: order.items.isEmpty ? null : _sendToKitchen,
                      icon: const Icon(Icons.send),
                      label: const Text('Send to Kitchen'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Add product to order
  Future<void> _addProductToOrder(Product product) async {
    final service = ref.read(tableServiceProvider);

    final result = await service.addItemToOrder(
      orderId: _currentOrder!.id,
      productId: product.id,
      productName: product.name,
      quantity: 1,
      unitPrice: product.price,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
    );

    result.when(
      success: (updatedOrder) {
        setState(() {
          _currentOrder = updatedOrder;
        });
      },
      failure: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add item: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  /// Update item quantity
  Future<void> _updateItemQuantity(TableOrderItem item, int newQuantity) async {
    if (newQuantity <= 0) {
      _removeItem(item);
      return;
    }

    final service = ref.read(tableServiceProvider);

    final result = await service.updateItemQuantity(
      orderId: _currentOrder!.id,
      itemId: item.id,
      newQuantity: newQuantity,
    );

    result.when(
      success: (updatedOrder) {
        setState(() {
          _currentOrder = updatedOrder;
        });
      },
      failure: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update quantity: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  /// Remove item from order
  Future<void> _removeItem(TableOrderItem item) async {
    final service = ref.read(tableServiceProvider);

    final result = await service.removeItemFromOrder(
      orderId: _currentOrder!.id,
      itemId: item.id,
    );

    result.when(
      success: (updatedOrder) {
        setState(() {
          _currentOrder = updatedOrder;
        });
      },
      failure: (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove item: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  /// Save order (without sending to kitchen)
  Future<void> _saveOrder() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Order saved')),
      );
      context.pop();
    }
  }

  /// Send order to kitchen
  Future<void> _sendToKitchen() async {
    final service = ref.read(tableServiceProvider);

    final result = await service.sendToKitchen(_currentOrder!.id);

    if (mounted) {
      result.when(
        success: (_) {
          // Print kitchen ticket (non-blocking)
          _printKitchenOrder();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order sent to kitchen')),
          );
          context.pop();
        },
        failure: (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to send order: ${failure.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  /// Print kitchen order ticket
  Future<void> _printKitchenOrder() async {
    try {
      final kitchenPrinterId = ref.read(kitchenPrinterIdProvider);
      if (kitchenPrinterId == null) {
        debugPrint('[OrderTaking] Kitchen printer not configured');
        return;
      }

      final deviceBridge = ref.read(deviceBridgeClientProvider);
      final printer = deviceBridge.printer(kitchenPrinterId);
      final waiter = ref.read(currentWaiterProvider);

      // Build kitchen ticket
      await printer.printReceipt(
        (b) => b
          ..text(
            'KITCHEN ORDER',
            alignment: TextAlignment.center,
            size: TextSize.extraLarge,
            bold: true,
          )
          ..lineFeed(lines: 1)
          ..divider(char: '=')
          ..text(
            'Order #${_currentOrder!.orderNumber}',
            size: TextSize.large,
            bold: true,
          )
          ..text(DateTime.now().toString().substring(0, 19))
          ..text('Table: ${_currentOrder!.tableName}', bold: true)
          ..text('Waiter: ${waiter?.name ?? "Unknown"}')
          ..when(
            _currentOrder!.guestCount != null,
            (b) => b..text('Guests: ${_currentOrder!.guestCount}'),
          )
          ..divider(char: '=')
          ..lineFeed(lines: 2)
          // Order items
          ..addAll(_currentOrder!.items.map((item) => [
                b
                  ..text(
                    '${item.quantity}x ${item.productName}',
                    size: TextSize.large,
                    bold: true,
                  )
                  ..when(
                    item.notes?.isNotEmpty == true,
                    (b) => b..text('   Notes: ${item.notes!.join(", ")}', bold: true),
                  )
                  ..lineFeed(lines: 1),
              ]).expand((x) => x))
          ..lineFeed(lines: 2)
          ..divider(char: '=')
          ..text(
            'Total Items: ${_currentOrder!.items.fold<int>(0, (sum, item) => sum + item.quantity)}',
            size: TextSize.large,
            bold: true,
          )
          ..lineFeed(lines: 3)
          ..cut(),
        options: PrintOptions(copies: 1, autoCut: true),
      );

      debugPrint('[OrderTaking] Kitchen ticket printed');
    } catch (e) {
      debugPrint('[OrderTaking] Kitchen print failed: $e');
      // Don't show error to user - printing is optional
    }
  }

  Color _getStatusColor(TableOrderStatus status) {
    switch (status) {
      case TableOrderStatus.draft:
        return Colors.grey;
      case TableOrderStatus.sent:
        return Colors.blue;
      case TableOrderStatus.preparing:
        return Colors.orange;
      case TableOrderStatus.ready:
        return Colors.green;
      case TableOrderStatus.served:
        return Colors.teal;
      case TableOrderStatus.paid:
        return Colors.purple;
      case TableOrderStatus.cancelled:
        return Colors.red;
    }
  }
}

/// Product card widget
class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product image placeholder
            Expanded(
              child: Container(
                color: theme.colorScheme.primaryContainer,
                child: Icon(
                  Icons.restaurant,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),

            // Product info
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Order item tile
class _OrderItemTile extends StatelessWidget {
  final TableOrderItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _OrderItemTile({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      title: Text(item.productName),
      subtitle: Text('\$${item.unitPrice.toStringAsFixed(2)} each'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Quantity controls
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: () => onQuantityChanged(item.quantity - 1),
            iconSize: 20,
          ),
          SizedBox(
            width: 30,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onQuantityChanged(item.quantity + 1),
            iconSize: 20,
          ),
          const SizedBox(width: 8),

          // Line total
          SizedBox(
            width: 70,
            child: Text(
              '\$${item.lineTotal.toStringAsFixed(2)}',
              textAlign: TextAlign.right,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Remove button
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onRemove,
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}

/// Summary row widget
class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.bodyLarge,
          ),
          Text(
            value,
            style: isTotal
                ? theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  )
                : theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
