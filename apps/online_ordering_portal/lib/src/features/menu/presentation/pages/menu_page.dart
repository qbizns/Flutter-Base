import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Menu Page
///
/// Main menu browsing interface for online ordering.
/// Features:
/// - Category-based navigation
/// - Search functionality
/// - Item cards with images and pricing
/// - Quick add to cart
/// - Dietary filters (vegetarian, vegan, gluten-free)
class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final Set<String> _selectedFilters = {};

  // Mock menu data
  final List<MenuItem> _menuItems = [
    MenuItem(
      id: '1',
      name: 'Classic Burger',
      description: 'Angus beef patty, lettuce, tomato, onion, pickles, special sauce',
      price: 12.99,
      category: 'Burgers',
      imageUrl: 'https://via.placeholder.com/300x200',
      dietaryTags: [''],
      isPopular: true,
      prepTime: 15,
    ),
    MenuItem(
      id: '2',
      name: 'Margherita Pizza',
      description: 'Fresh mozzarella, tomato sauce, basil, extra virgin olive oil',
      price: 14.99,
      category: 'Pizza',
      imageUrl: 'https://via.placeholder.com/300x200',
      dietaryTags: ['vegetarian'],
      isPopular: true,
      prepTime: 20,
    ),
    MenuItem(
      id: '3',
      name: 'Caesar Salad',
      description: 'Romaine lettuce, parmesan, croutons, Caesar dressing',
      price: 9.99,
      category: 'Salads',
      imageUrl: 'https://via.placeholder.com/300x200',
      dietaryTags: ['vegetarian'],
      isPopular: false,
      prepTime: 10,
    ),
    MenuItem(
      id: '4',
      name: 'Grilled Salmon',
      description: 'Atlantic salmon, roasted vegetables, lemon butter sauce',
      price: 24.99,
      category: 'Seafood',
      imageUrl: 'https://via.placeholder.com/300x200',
      dietaryTags: ['gluten-free'],
      isPopular: true,
      prepTime: 25,
    ),
    MenuItem(
      id: '5',
      name: 'Veggie Bowl',
      description: 'Quinoa, roasted vegetables, avocado, tahini dressing',
      price: 11.99,
      category: 'Salads',
      imageUrl: 'https://via.placeholder.com/300x200',
      dietaryTags: ['vegan', 'gluten-free'],
      isPopular: false,
      prepTime: 12,
    ),
    MenuItem(
      id: '6',
      name: 'Pepperoni Pizza',
      description: 'Mozzarella, pepperoni, tomato sauce',
      price: 16.99,
      category: 'Pizza',
      imageUrl: 'https://via.placeholder.com/300x200',
      dietaryTags: [''],
      isPopular: true,
      prepTime: 20,
    ),
    MenuItem(
      id: '7',
      name: 'Chocolate Lava Cake',
      description: 'Warm chocolate cake with molten center, vanilla ice cream',
      price: 7.99,
      category: 'Desserts',
      imageUrl: 'https://via.placeholder.com/300x200',
      dietaryTags: ['vegetarian'],
      isPopular: true,
      prepTime: 8,
    ),
    MenuItem(
      id: '8',
      name: 'Iced Latte',
      description: 'Espresso, cold milk, ice',
      price: 4.99,
      category: 'Beverages',
      imageUrl: 'https://via.placeholder.com/300x200',
      dietaryTags: ['vegetarian'],
      isPopular: false,
      prepTime: 5,
    ),
  ];

  List<String> get _categories {
    final categories = _menuItems.map((item) => item.category).toSet().toList();
    categories.sort();
    return ['All', ...categories];
  }

  List<MenuItem> get _filteredItems {
    var items = _menuItems;

    // Category filter
    if (_selectedCategory != 'All') {
      items = items.where((item) => item.category == _selectedCategory).toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      items = items.where((item) {
        return item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Dietary filters
    if (_selectedFilters.isNotEmpty) {
      items = items.where((item) {
        return _selectedFilters.every((filter) => item.dietaryTags.contains(filter));
      }).toList();
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isWideScreen = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with search
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primaryContainer,
                    ],
                  ),
                ),
              ),
              title: const Text('Order Online'),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Search menu items...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Categories
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = category == _selectedCategory;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedCategory = category);
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Dietary filters
          SliverToBoxAdapter(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _buildDietaryFilter('vegetarian', '🥬 Vegetarian'),
                  _buildDietaryFilter('vegan', '🌱 Vegan'),
                  _buildDietaryFilter('gluten-free', '🌾 Gluten-Free'),
                ],
              ),
            ),
          ),

          // Menu items grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isWideScreen ? 3 : (MediaQuery.of(context).size.width > 600 ? 2 : 1),
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _filteredItems[index];
                  return _buildMenuItemCard(theme, item);
                },
                childCount: _filteredItems.length,
              ),
            ),
          ),

          // Empty state
          if (_filteredItems.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items found',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your filters',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDietaryFilter(String filter, String label) {
    final isSelected = _selectedFilters.contains(filter);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            if (selected) {
              _selectedFilters.add(filter);
            } else {
              _selectedFilters.remove(filter);
            }
          });
        },
      ),
    );
  }

  Widget _buildMenuItemCard(ThemeData theme, MenuItem item) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _showItemDetails(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: theme.colorScheme.surfaceVariant,
                    child: Icon(
                      Icons.restaurant,
                      size: 48,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                    ),
                  ),
                ),
                if (item.isPopular)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            'Popular',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Description
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Prep time
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.prepTime} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Price and add button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          NumberFormat.currency(symbol: '\$').format(item.price),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        FilledButton.icon(
                          onPressed: () => _addToCart(item),
                          icon: const Icon(Icons.add_shopping_cart, size: 18),
                          label: const Text('Add'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
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

  void _showItemDetails(MenuItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.3),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Name and price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    NumberFormat.currency(symbol: '\$').format(item.price),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Description
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),

              // Dietary tags
              if (item.dietaryTags.isNotEmpty && item.dietaryTags.first.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: item.dietaryTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              const SizedBox(height: 24),

              // Add to cart button
              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _addToCart(item);
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(MenuItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.name} added to cart'),
        action: SnackBarAction(
          label: 'View Cart',
          onPressed: () {
            // Navigate to cart
          },
        ),
      ),
    );
  }
}

// Models
class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String category;
  final String imageUrl;
  final List<String> dietaryTags;
  final bool isPopular;
  final int prepTime;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.imageUrl,
    required this.dietaryTags,
    required this.isPopular,
    required this.prepTime,
  });
}
