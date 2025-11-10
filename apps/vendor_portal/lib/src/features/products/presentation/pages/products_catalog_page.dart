import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Products Catalog - Vendor products and pricing
class ProductsCatalogPage extends ConsumerWidget {
  const ProductsCatalogPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final products = [
      VendorProduct('PROD001', 'Fresh Salmon Fillet', 'Fresh Foods Suppliers', ProductCategory.food, 24.50, 'kg', 50, true),
      VendorProduct('PROD002', 'Organic Tomatoes', 'Fresh Foods Suppliers', ProductCategory.food, 3.25, 'kg', 100, true),
      VendorProduct('PROD003', 'Premium Coffee Beans', 'Beverage Distributors Inc', ProductCategory.beverage, 18.75, 'kg', 25, true),
      VendorProduct('PROD004', 'Sparkling Water 24-pack', 'Beverage Distributors Inc', ProductCategory.beverage, 12.99, 'case', 0, false),
      VendorProduct('PROD005', 'Commercial Blender', 'Restaurant Equipment Co', ProductCategory.equipment, 425.00, 'unit', 5, true),
      VendorProduct('PROD006', 'Takeout Containers (100pcs)', 'Packaging Solutions', ProductCategory.packaging, 15.50, 'box', 150, true),
      VendorProduct('PROD007', 'Paper Napkins (500pcs)', 'Packaging Solutions', ProductCategory.packaging, 8.25, 'pack', 200, true),
      VendorProduct('PROD008', 'Cleaning Spray', 'Cleaning Services Pro', ProductCategory.cleaning, 6.50, 'bottle', 30, true),
    ];

    final availableCount = products.where((p) => p.available).length;
    final outOfStockCount = products.where((p) => !p.available).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Products Catalog')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.inventory_2, color: theme.colorScheme.onPrimaryContainer, size: 20),
                              const SizedBox(width: 8),
                              Text('Total Products', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${products.length}', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer)),
                          Text('In catalog', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Available', style: TextStyle(color: Colors.green.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$availableCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green.shade700)),
                          Text('In stock', style: TextStyle(fontSize: 12, color: Colors.green.shade700.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.remove_circle, color: Colors.red.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Out of Stock', style: TextStyle(color: Colors.red.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('$outOfStockCount', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                          Text('Need restock', style: TextStyle(fontSize: 12, color: Colors.red.shade700.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(product.category).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getCategoryIcon(product.category), color: _getCategoryColor(product.category), size: 24),
                    ),
                    title: Row(
                      children: [
                        Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        if (!product.available)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('OUT OF STOCK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                          ),
                      ],
                    ),
                    subtitle: Text('${product.vendor} • SKU: ${product.sku} • Stock: ${product.stockQuantity} ${product.unit}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$').format(product.price),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text('per ${product.unit}', style: theme.textTheme.bodySmall),
                      ],
                    ),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.food: return Colors.green;
      case ProductCategory.beverage: return Colors.blue;
      case ProductCategory.equipment: return Colors.orange;
      case ProductCategory.packaging: return Colors.purple;
      case ProductCategory.cleaning: return Colors.indigo;
    }
  }

  IconData _getCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.food: return Icons.restaurant;
      case ProductCategory.beverage: return Icons.local_drink;
      case ProductCategory.equipment: return Icons.kitchen;
      case ProductCategory.packaging: return Icons.inventory_2;
      case ProductCategory.cleaning: return Icons.cleaning_services;
    }
  }
}

class VendorProduct {
  final String sku;
  final String name;
  final String vendor;
  final ProductCategory category;
  final double price;
  final String unit;
  final int stockQuantity;
  final bool available;

  VendorProduct(this.sku, this.name, this.vendor, this.category, this.price, this.unit, this.stockQuantity, this.available);
}

enum ProductCategory { food, beverage, equipment, packaging, cleaning }
