/// Mock API Service
/// Simulates backend responses for offline testing and development
library;

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:pos_core/pos_core.dart';

/// Mock API service for offline testing
///
/// Features:
/// - Simulates network delays
/// - Generates realistic mock data
/// - Supports all POS operations
/// - Can simulate errors for testing
class MockApiService {
  final Random _random = Random();
  final Uuid _uuid = const Uuid();

  // Mock data storage
  final Map<String, Map<String, dynamic>> _products = {};
  final Map<String, Map<String, dynamic>> _categories = {};
  final Map<String, Map<String, dynamic>> _customers = {};
  final Map<String, Map<String, dynamic>> _orders = {};
  final Map<String, Map<String, dynamic>> _sessions = {};

  // Configuration
  final Duration minDelay;
  final Duration maxDelay;
  final double errorRate; // 0.0 to 1.0

  MockApiService({
    this.minDelay = const Duration(milliseconds: 100),
    this.maxDelay = const Duration(milliseconds: 500),
    this.errorRate = 0.0,
  }) {
    _initializeMockData();
  }

  /// Simulate network delay
  Future<void> _simulateDelay() async {
    final delayMs = minDelay.inMilliseconds +
        _random.nextInt(maxDelay.inMilliseconds - minDelay.inMilliseconds);
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  /// Simulate random errors
  void _maybeThrowError() {
    if (_random.nextDouble() < errorRate) {
      throw Exception('Simulated network error');
    }
  }

  // ==================== SESSION MANAGEMENT ====================

  /// Open session
  Future<Map<String, dynamic>> openSession({
    required double openingCash,
    required String registerId,
    Map<String, dynamic>? cashDenominations,
    String? notes,
  }) async {
    await _simulateDelay();
    _maybeThrowError();

    final sessionId = _uuid.v4();
    final now = DateTime.now();

    final session = {
      'id': sessionId,
      'session_number': 'SES-${now.year}${now.month}${now.day}-${_sessions.length + 1}',
      'register_id': registerId,
      'status': 'open',
      'opening_balance': openingCash,
      'current_balance': openingCash,
      'expected_closing_cash': openingCash,
      'cash_denominations': cashDenominations,
      'opened_at': now.toIso8601String(),
      'opened_by': 'mock-user',
      'notes': notes,
    };

    _sessions[sessionId] = session;
    return session;
  }

  /// Close session
  Future<Map<String, dynamic>> closeSession({
    required String sessionId,
    required double actualClosingCash,
    Map<String, dynamic>? cashDenominations,
    String? notes,
  }) async {
    await _simulateDelay();
    _maybeThrowError();

    final session = _sessions[sessionId];
    if (session == null) {
      throw Exception('Session not found');
    }

    final now = DateTime.now();
    final expectedCash = session['expected_closing_cash'] as double;
    final difference = actualClosingCash - expectedCash;

    session['status'] = 'closed';
    session['actual_closing_cash'] = actualClosingCash;
    session['cash_difference'] = difference;
    session['closing_cash_denominations'] = cashDenominations;
    session['closed_at'] = now.toIso8601String();
    session['closing_notes'] = notes;

    return session;
  }

  // ==================== PRODUCT DATA ====================

  /// Get all products
  Future<Map<String, dynamic>> getProducts({
    int limit = 1000,
    int offset = 0,
  }) async {
    await _simulateDelay();
    _maybeThrowError();

    final productsList = _products.values.toList();

    return {
      'items': productsList.skip(offset).take(limit).toList(),
      'total': productsList.length,
      'limit': limit,
      'offset': offset,
    };
  }

  /// Get categories
  Future<Map<String, dynamic>> getCategories({
    int limit = 500,
    int offset = 0,
  }) async {
    await _simulateDelay();
    _maybeThrowError();

    final categoriesList = _categories.values.toList();

    return {
      'items': categoriesList.skip(offset).take(limit).toList(),
      'total': categoriesList.length,
      'limit': limit,
      'offset': offset,
    };
  }

  /// Get customers
  Future<Map<String, dynamic>> getCustomers({
    int limit = 1000,
    int offset = 0,
  }) async {
    await _simulateDelay();
    _maybeThrowError();

    final customersList = _customers.values.toList();

    return {
      'items': customersList.skip(offset).take(limit).toList(),
      'total': customersList.length,
      'limit': limit,
      'offset': offset,
    };
  }

  // ==================== ORDER MANAGEMENT ====================

  /// Create order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    await _simulateDelay();
    _maybeThrowError();

    final orderId = orderData['id'] ?? _uuid.v4();
    final now = DateTime.now();

    final order = {
      ...orderData,
      'id': orderId,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    };

    _orders[orderId] = order;
    return order;
  }

  /// Update order
  Future<Map<String, dynamic>> updateOrder(
    String orderId,
    Map<String, dynamic> updates,
  ) async {
    await _simulateDelay();
    _maybeThrowError();

    final order = _orders[orderId];
    if (order == null) {
      throw Exception('Order not found');
    }

    order.addAll(updates);
    order['updated_at'] = DateTime.now().toIso8601String();

    return order;
  }

  /// Update order status
  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    await _simulateDelay();
    _maybeThrowError();

    final order = _orders[orderId];
    if (order == null) {
      throw Exception('Order not found');
    }

    order['status'] = newStatus;
    order['updated_at'] = DateTime.now().toIso8601String();

    if (newStatus == 'completed') {
      order['completed_at'] = DateTime.now().toIso8601String();
    }

    return order;
  }

  /// Get order by ID
  Future<Map<String, dynamic>> getOrder(String orderId) async {
    await _simulateDelay();
    _maybeThrowError();

    final order = _orders[orderId];
    if (order == null) {
      throw Exception('Order not found');
    }

    return order;
  }

  /// Get all orders
  Future<Map<String, dynamic>> getOrders({
    String? status,
    int limit = 50,
    int offset = 0,
  }) async {
    await _simulateDelay();
    _maybeThrowError();

    var ordersList = _orders.values.toList();

    if (status != null) {
      ordersList = ordersList.where((o) => o['status'] == status).toList();
    }

    // Sort by created_at descending
    ordersList.sort((a, b) {
      final aTime = DateTime.parse(a['created_at'] as String);
      final bTime = DateTime.parse(b['created_at'] as String);
      return bTime.compareTo(aTime);
    });

    return {
      'items': ordersList.skip(offset).take(limit).toList(),
      'total': ordersList.length,
      'limit': limit,
      'offset': offset,
    };
  }

  // ==================== PAYMENT METHODS ====================

  /// Get payment methods
  Future<Map<String, dynamic>> getPaymentMethods() async {
    await _simulateDelay();
    _maybeThrowError();

    return {
      'items': [
        {
          'id': 'pm-cash',
          'name': 'Cash',
          'type': 'cash',
          'icon_name': 'attach_money',
          'is_active': true,
          'requires_authorization': false,
        },
        {
          'id': 'pm-card',
          'name': 'Credit/Debit Card',
          'type': 'card',
          'icon_name': 'credit_card',
          'is_active': true,
          'requires_authorization': true,
        },
        {
          'id': 'pm-mobile',
          'name': 'Mobile Payment',
          'type': 'mobile',
          'icon_name': 'phone_android',
          'is_active': true,
          'requires_authorization': false,
        },
      ],
    };
  }

  /// Get tax rates
  Future<Map<String, dynamic>> getTaxRates() async {
    await _simulateDelay();
    _maybeThrowError();

    return {
      'items': [
        {
          'id': 'tax-1',
          'name': 'Sales Tax',
          'rate': 8.5,
          'type': 'percentage',
          'is_active': true,
          'is_default': true,
        },
      ],
    };
  }

  // ==================== MOCK DATA INITIALIZATION ====================

  void _initializeMockData() {
    _initializeCategories();
    _initializeProducts();
    _initializeCustomers();
  }

  void _initializeCategories() {
    final categories = [
      {'id': 'cat-beverages', 'name': 'Beverages', 'sort_order': 1},
      {'id': 'cat-coffee', 'name': 'Coffee', 'sort_order': 2},
      {'id': 'cat-food', 'name': 'Food', 'sort_order': 3},
      {'id': 'cat-burgers', 'name': 'Burgers', 'sort_order': 4},
      {'id': 'cat-salads', 'name': 'Salads', 'sort_order': 5},
      {'id': 'cat-desserts', 'name': 'Desserts', 'sort_order': 6},
    ];

    for (final cat in categories) {
      _categories[cat['id'] as String] = {
        ...cat,
        'description': '${cat['name']} category',
        'image_url': null,
        'parent_id': null,
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };
    }
  }

  void _initializeProducts() {
    final products = [
      // Beverages
      {'name': 'Coca Cola', 'price': 2.50, 'category': 'cat-beverages', 'sku': 'BEV-001'},
      {'name': 'Orange Juice', 'price': 3.50, 'category': 'cat-beverages', 'sku': 'BEV-002'},
      {'name': 'Water', 'price': 1.50, 'category': 'cat-beverages', 'sku': 'BEV-003'},

      // Coffee
      {'name': 'Espresso', 'price': 2.99, 'category': 'cat-coffee', 'sku': 'COF-001'},
      {'name': 'Cappuccino', 'price': 4.50, 'category': 'cat-coffee', 'sku': 'COF-002'},
      {'name': 'Latte', 'price': 4.99, 'category': 'cat-coffee', 'sku': 'COF-003'},

      // Burgers
      {'name': 'Classic Burger', 'price': 8.99, 'category': 'cat-burgers', 'sku': 'BUR-001'},
      {'name': 'Cheese Burger', 'price': 9.99, 'category': 'cat-burgers', 'sku': 'BUR-002'},
      {'name': 'Bacon Burger', 'price': 10.99, 'category': 'cat-burgers', 'sku': 'BUR-003'},

      // Salads
      {'name': 'Caesar Salad', 'price': 7.99, 'category': 'cat-salads', 'sku': 'SAL-001'},
      {'name': 'Greek Salad', 'price': 8.50, 'category': 'cat-salads', 'sku': 'SAL-002'},

      // Desserts
      {'name': 'Chocolate Cake', 'price': 5.99, 'category': 'cat-desserts', 'sku': 'DES-001'},
      {'name': 'Ice Cream', 'price': 3.99, 'category': 'cat-desserts', 'sku': 'DES-002'},
    ];

    for (final product in products) {
      final id = 'prod-${_uuid.v4().substring(0, 8)}';
      _products[id] = {
        'id': id,
        'sku': product['sku'],
        'name': product['name'],
        'description': '${product['name']} - delicious and fresh',
        'base_price': product['price'],
        'sale_price': null,
        'cost': (product['price'] as double) * 0.4,
        'tax_percent': 8.5,
        'tax_ids': ['tax-1'],
        'category_id': product['category'],
        'category_name': _categories[product['category'] as String]?['name'],
        'image_url': null,
        'thumbnail_url': null,
        'stock_quantity': 100,
        'track_inventory': true,
        'is_active': true,
        'is_featured': false,
        'variants': [],
        'modifiers': [],
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
    }
  }

  void _initializeCustomers() {
    final customers = [
      {'name': 'John Doe', 'email': 'john@example.com', 'phone': '+1234567890'},
      {'name': 'Jane Smith', 'email': 'jane@example.com', 'phone': '+1234567891'},
      {'name': 'Bob Johnson', 'email': 'bob@example.com', 'phone': '+1234567892'},
    ];

    for (final customer in customers) {
      final id = 'cust-${_uuid.v4().substring(0, 8)}';
      _customers[id] = {
        'id': id,
        'name': customer['name'],
        'email': customer['email'],
        'phone': customer['phone'],
        'loyalty_points': _random.nextDouble() * 500,
        'loyalty_tier': ['bronze', 'silver', 'gold'][_random.nextInt(3)],
        'created_at': DateTime.now().toIso8601String(),
      };
    }
  }

  // ==================== UTILITY METHODS ====================

  /// Reset all mock data
  void reset() {
    _products.clear();
    _categories.clear();
    _customers.clear();
    _orders.clear();
    _sessions.clear();
    _initializeMockData();
  }

  /// Get statistics
  Map<String, int> getStats() {
    return {
      'products': _products.length,
      'categories': _categories.length,
      'customers': _customers.length,
      'orders': _orders.length,
      'sessions': _sessions.length,
    };
  }
}
