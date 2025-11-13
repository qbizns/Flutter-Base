import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/odoo_colors.dart';
import '../theme/odoo_typography.dart';

/// Search entity type
enum SearchEntityType {
  product,
  order,
  table,
  staff,
}

/// Search result item
class SearchResult {
  final String id;
  final SearchEntityType type;
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  const SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}

/// Search Overlay Widget
///
/// A fullscreen overlay for searching across Products, Orders, Tables, and Staff
class SearchOverlay extends StatefulWidget {
  const SearchOverlay({super.key});

  @override
  State<SearchOverlay> createState() => _SearchOverlayState();

  /// Show the search overlay
  static Future<void> show(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: const SearchOverlay(),
          );
        },
      ),
    );
  }
}

class _SearchOverlayState extends State<SearchOverlay> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  List<SearchResult> _results = [];
  List<String> _recentSearches = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _loadRecentSearches();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _loadRecentSearches() {
    // TODO: Load from SharedPreferences or local storage
    setState(() {
      _recentSearches = [
        'Classic Burger',
        'Order #1234',
        'Table 5',
        'John Smith',
      ];
    });
  }

  void _saveRecentSearch(String query) {
    // TODO: Save to SharedPreferences or local storage
    setState(() {
      _recentSearches.remove(query);
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches = _recentSearches.take(10).toList();
      }
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // TODO: Replace with real API search
    final mockResults = _getMockResults(query);

    setState(() {
      _results = mockResults;
      _isSearching = false;
    });
  }

  List<SearchResult> _getMockResults(String query) {
    final lowerQuery = query.toLowerCase();
    final results = <SearchResult>[];

    // Mock Products
    if ('classic burger'.contains(lowerQuery)) {
      results.add(const SearchResult(
        id: 'p1',
        type: SearchEntityType.product,
        title: 'Classic Burger',
        subtitle: 'Main Course - \$12.99',
        icon: Icons.restaurant,
        route: '/products',
      ));
    }
    if ('french fries'.contains(lowerQuery) || 'fries'.contains(lowerQuery)) {
      results.add(const SearchResult(
        id: 'p2',
        type: SearchEntityType.product,
        title: 'French Fries',
        subtitle: 'Side Dish - \$4.99',
        icon: Icons.restaurant,
        route: '/products',
      ));
    }
    if ('cola'.contains(lowerQuery) || 'drink'.contains(lowerQuery)) {
      results.add(const SearchResult(
        id: 'p3',
        type: SearchEntityType.product,
        title: 'Cola',
        subtitle: 'Beverage - \$2.99',
        icon: Icons.local_drink,
        route: '/products',
      ));
    }

    // Mock Orders
    if ('1234'.contains(query) || 'order'.contains(lowerQuery)) {
      results.add(const SearchResult(
        id: 'o1',
        type: SearchEntityType.order,
        title: 'Order #1234',
        subtitle: 'Table 5 - \$45.50 - In Progress',
        icon: Icons.receipt_long,
        route: '/sales',
      ));
    }
    if ('1233'.contains(query) || 'order'.contains(lowerQuery)) {
      results.add(const SearchResult(
        id: 'o2',
        type: SearchEntityType.order,
        title: 'Order #1233',
        subtitle: 'Table 3 - \$32.00 - Completed',
        icon: Icons.receipt_long,
        route: '/sales',
      ));
    }

    // Mock Tables
    if ('table 5'.contains(lowerQuery) || '5'.contains(query)) {
      results.add(const SearchResult(
        id: 't1',
        type: SearchEntityType.table,
        title: 'Table 5',
        subtitle: 'Occupied - Order #1234',
        icon: Icons.table_restaurant,
        route: '/restaurant',
      ));
    }
    if ('table 3'.contains(lowerQuery) || '3'.contains(query)) {
      results.add(const SearchResult(
        id: 't2',
        type: SearchEntityType.table,
        title: 'Table 3',
        subtitle: 'Available',
        icon: Icons.table_restaurant,
        route: '/restaurant',
      ));
    }

    // Mock Staff
    if ('john smith'.contains(lowerQuery) || 'john'.contains(lowerQuery)) {
      results.add(const SearchResult(
        id: 's1',
        type: SearchEntityType.staff,
        title: 'John Smith',
        subtitle: 'Admin - Active',
        icon: Icons.person,
        route: '/staff',
      ));
    }
    if ('sarah johnson'.contains(lowerQuery) || 'sarah'.contains(lowerQuery)) {
      results.add(const SearchResult(
        id: 's2',
        type: SearchEntityType.staff,
        title: 'Sarah Johnson',
        subtitle: 'Manager - Active',
        icon: Icons.person,
        route: '/staff',
      ));
    }

    return results;
  }

  void _selectResult(SearchResult result) {
    _saveRecentSearch(result.title);
    context.go(result.route);
    Navigator.of(context).pop();
  }

  void _selectRecentSearch(String query) {
    _searchController.text = query;
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Backdrop
            Container(
              color: Colors.black54,
            ),

            // Search box
            Align(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () {}, // Prevent closing when clicking inside
                child: Container(
                  margin: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 80,
                    left: OdooSpacing.xl,
                    right: OdooSpacing.xl,
                  ),
                  constraints: const BoxConstraints(maxWidth: 600),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(OdooSpacing.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Search input
                      Padding(
                        padding: const EdgeInsets.all(OdooSpacing.md),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search,
                              color: OdooColors.textSecondary,
                            ),
                            const SizedBox(width: OdooSpacing.md),
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                focusNode: _focusNode,
                                decoration: const InputDecoration(
                                  hintText: 'Search products, orders, tables, staff...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(
                                    color: OdooColors.textSecondary,
                                  ),
                                ),
                                onChanged: _performSearch,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: OdooColors.textSecondary,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  _performSearch('');
                                },
                              ),
                          ],
                        ),
                      ),

                      // Results or recent searches
                      if (_searchController.text.isEmpty && _recentSearches.isNotEmpty)
                        _buildRecentSearches()
                      else if (_isSearching)
                        _buildLoading()
                      else if (_results.isNotEmpty)
                        _buildResults()
                      else if (_searchController.text.isNotEmpty)
                        _buildNoResults(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          Padding(
            padding: const EdgeInsets.all(OdooSpacing.md),
            child: Text(
              'Recent Searches',
              style: OdooTypography.labelSmall.copyWith(
                color: OdooColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...(_recentSearches.map((search) => ListTile(
                leading: const Icon(
                  Icons.history,
                  color: OdooColors.textSecondary,
                ),
                title: Text(search),
                onTap: () => _selectRecentSearch(search),
              ))),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.all(OdooSpacing.xl),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildResults() {
    // Group results by type
    final groupedResults = <SearchEntityType, List<SearchResult>>{};
    for (final result in _results) {
      groupedResults.putIfAbsent(result.type, () => []).add(result);
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        children: [
          for (final entry in groupedResults.entries) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                OdooSpacing.md,
                OdooSpacing.md,
                OdooSpacing.md,
                OdooSpacing.sm,
              ),
              child: Text(
                _getEntityTypeLabel(entry.key),
                style: OdooTypography.labelSmall.copyWith(
                  color: OdooColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ...(entry.value.map((result) => ListTile(
                  leading: Icon(
                    result.icon,
                    color: OdooColors.secondary,
                  ),
                  title: Text(result.title),
                  subtitle: Text(result.subtitle),
                  onTap: () => _selectResult(result),
                ))),
          ],
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Padding(
      padding: const EdgeInsets.all(OdooSpacing.xl),
      child: Column(
        children: [
          const Icon(
            Icons.search_off,
            size: 48,
            color: OdooColors.textSecondary,
          ),
          const SizedBox(height: OdooSpacing.md),
          Text(
            'No results found',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _getEntityTypeLabel(SearchEntityType type) {
    switch (type) {
      case SearchEntityType.product:
        return 'Products';
      case SearchEntityType.order:
        return 'Orders';
      case SearchEntityType.table:
        return 'Tables';
      case SearchEntityType.staff:
        return 'Staff';
    }
  }
}
