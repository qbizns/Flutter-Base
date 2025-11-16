import 'package:flutter/material.dart';
import 'package:plugin_manager/plugin_manager.dart';

class CategorySidebar extends StatelessWidget {
  final String? selectedCategory;
  final ValueChanged<String?> onCategorySelected;

  const CategorySidebar({
    super.key,
    this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [
      (null, 'All Plugins', Icons.apps),
      ('payment', 'Payment Gateways', Icons.credit_card),
      ('accounting', 'Accounting', Icons.account_balance),
      ('ecommerce', 'E-commerce', Icons.shopping_cart),
      ('marketing', 'Marketing', Icons.campaign),
      ('shipping', 'Shipping & Delivery', Icons.local_shipping),
      ('analytics', 'Analytics', Icons.analytics),
      ('loyalty', 'Loyalty Programs', Icons.loyalty),
    ];

    return ListView(
      padding: const EdgeInsets.all(8),
      children: categories.map((category) {
        final (key, name, icon) = category;
        final isSelected = selectedCategory == key;

        return ListTile(
          leading: Icon(icon),
          title: Text(name),
          selected: isSelected,
          onTap: () => onCategorySelected(key),
        );
      }).toList(),
    );
  }
}
