/// Session Data Loader Service
/// Loads all master data when session opens (Odoo pattern)
library;

import 'package:pos_core/pos_core.dart';

/// Service that loads all required master data at session open
/// Following Odoo POS pattern: load everything upfront for offline operation
class SessionDataLoader {
  final ApiClient _apiClient;
  final AppContext _appContext;

  SessionDataLoader({
    required ApiClient apiClient,
    required AppContext appContext,
  })  : _apiClient = apiClient,
        _appContext = appContext;

  /// Load all master data for POS session (Odoo pattern)
  /// This includes: products, categories, customers, payment methods, taxes
  Future<SessionDataLoadResult> loadSessionData({
    required String sessionId,
    bool forceRefresh = false,
  }) async {
    final startTime = DateTime.now();
    final errors = <String>[];

    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      // Load data in parallel for performance
      final results = await Future.wait([
        _loadProducts(orgId, forceRefresh).catchError((e) {
          errors.add('Products: ${e.toString()}');
          return <Map<String, dynamic>>[];
        }),
        _loadCategories(orgId, forceRefresh).catchError((e) {
          errors.add('Categories: ${e.toString()}');
          return <Map<String, dynamic>>[];
        }),
        _loadCustomers(orgId, forceRefresh).catchError((e) {
          errors.add('Customers: ${e.toString()}');
          return <Map<String, dynamic>>[];
        }),
        _loadPaymentMethods(orgId, forceRefresh).catchError((e) {
          errors.add('Payment Methods: ${e.toString()}');
          return <Map<String, dynamic>>[];
        }),
        _loadTaxRates(orgId, forceRefresh).catchError((e) {
          errors.add('Tax Rates: ${e.toString()}');
          return <Map<String, dynamic>>[];
        }),
      ]);

      final duration = DateTime.now().difference(startTime);

      return SessionDataLoadResult(
        success: errors.isEmpty,
        sessionId: sessionId,
        productsCount: results[0].length,
        categoriesCount: results[1].length,
        customersCount: results[2].length,
        paymentMethodsCount: results[3].length,
        taxRatesCount: results[4].length,
        loadDuration: duration,
        errors: errors,
      );
    } catch (e) {
      return SessionDataLoadResult(
        success: false,
        sessionId: sessionId,
        productsCount: 0,
        categoriesCount: 0,
        customersCount: 0,
        paymentMethodsCount: 0,
        taxRatesCount: 0,
        loadDuration: DateTime.now().difference(startTime),
        errors: ['Critical error: ${e.toString()}', ...errors],
      );
    }
  }

  /// Load products with variants and modifiers
  Future<List<Map<String, dynamic>>> _loadProducts(
    String orgId,
    bool forceRefresh,
  ) async {
    try {
      final response = await _apiClient.get(
        '/organizations/$orgId/products',
        queryParameters: {
          'include': 'variants,modifiers,categories',
          'status': 'active',
          'limit': 1000, // Odoo typically loads all products
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('items')) {
          return List<Map<String, dynamic>>.from(data['items']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }

      return [];
    } catch (e) {
      throw AppException('Failed to load products: $e');
    }
  }

  /// Load product categories
  Future<List<Map<String, dynamic>>> _loadCategories(
    String orgId,
    bool forceRefresh,
  ) async {
    try {
      final response = await _apiClient.get(
        '/organizations/$orgId/categories',
        queryParameters: {
          'status': 'active',
          'limit': 500,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('items')) {
          return List<Map<String, dynamic>>.from(data['items']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }

      return [];
    } catch (e) {
      throw AppException('Failed to load categories: $e');
    }
  }

  /// Load customers
  Future<List<Map<String, dynamic>>> _loadCustomers(
    String orgId,
    bool forceRefresh,
  ) async {
    try {
      final response = await _apiClient.get(
        '/organizations/$orgId/customers',
        queryParameters: {
          'status': 'active',
          'limit': 1000,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('items')) {
          return List<Map<String, dynamic>>.from(data['items']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }

      return [];
    } catch (e) {
      throw AppException('Failed to load customers: $e');
    }
  }

  /// Load payment methods
  Future<List<Map<String, dynamic>>> _loadPaymentMethods(
    String orgId,
    bool forceRefresh,
  ) async {
    try {
      final response = await _apiClient.get(
        '/organizations/$orgId/payment-methods',
        queryParameters: {
          'status': 'active',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('items')) {
          return List<Map<String, dynamic>>.from(data['items']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }

      return [];
    } catch (e) {
      throw AppException('Failed to load payment methods: $e');
    }
  }

  /// Load tax rates
  Future<List<Map<String, dynamic>>> _loadTaxRates(
    String orgId,
    bool forceRefresh,
  ) async {
    try {
      final response = await _apiClient.get(
        '/organizations/$orgId/tax-rates',
        queryParameters: {
          'status': 'active',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('items')) {
          return List<Map<String, dynamic>>.from(data['items']);
        } else if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }

      return [];
    } catch (e) {
      throw AppException('Failed to load tax rates: $e');
    }
  }

  /// Check if session data needs refresh
  /// Based on cache age and last sync time
  Future<bool> needsRefresh({
    required String sessionId,
    Duration maxAge = const Duration(hours: 24),
  }) async {
    // TODO: Implement cache age checking from database
    // For now, always return false (rely on force refresh flag)
    return false;
  }

  /// Get loading progress stream for UI updates
  Stream<SessionDataLoadProgress> loadSessionDataWithProgress({
    required String sessionId,
    bool forceRefresh = false,
  }) async* {
    final orgId = _appContext.currentOrganizationId;
    if (orgId == null) {
      yield SessionDataLoadProgress(
        stage: 'error',
        message: 'No organization context',
        progress: 0.0,
        isComplete: true,
        hasError: true,
      );
      return;
    }

    // Stage 1: Products (40% of total work)
    yield SessionDataLoadProgress(
      stage: 'products',
      message: 'Loading products...',
      progress: 0.0,
    );

    final products = await _loadProducts(orgId, forceRefresh);
    yield SessionDataLoadProgress(
      stage: 'products',
      message: 'Loaded ${products.length} products',
      progress: 0.4,
    );

    // Stage 2: Categories (10%)
    yield SessionDataLoadProgress(
      stage: 'categories',
      message: 'Loading categories...',
      progress: 0.4,
    );

    final categories = await _loadCategories(orgId, forceRefresh);
    yield SessionDataLoadProgress(
      stage: 'categories',
      message: 'Loaded ${categories.length} categories',
      progress: 0.5,
    );

    // Stage 3: Customers (30%)
    yield SessionDataLoadProgress(
      stage: 'customers',
      message: 'Loading customers...',
      progress: 0.5,
    );

    final customers = await _loadCustomers(orgId, forceRefresh);
    yield SessionDataLoadProgress(
      stage: 'customers',
      message: 'Loaded ${customers.length} customers',
      progress: 0.8,
    );

    // Stage 4: Payment methods (10%)
    yield SessionDataLoadProgress(
      stage: 'payment_methods',
      message: 'Loading payment methods...',
      progress: 0.8,
    );

    final paymentMethods = await _loadPaymentMethods(orgId, forceRefresh);
    yield SessionDataLoadProgress(
      stage: 'payment_methods',
      message: 'Loaded ${paymentMethods.length} payment methods',
      progress: 0.9,
    );

    // Stage 5: Tax rates (10%)
    yield SessionDataLoadProgress(
      stage: 'tax_rates',
      message: 'Loading tax rates...',
      progress: 0.9,
    );

    final taxRates = await _loadTaxRates(orgId, forceRefresh);
    yield SessionDataLoadProgress(
      stage: 'complete',
      message: 'Session data loaded successfully',
      progress: 1.0,
      isComplete: true,
    );
  }
}

/// Result of session data loading operation
class SessionDataLoadResult {
  final bool success;
  final String sessionId;
  final int productsCount;
  final int categoriesCount;
  final int customersCount;
  final int paymentMethodsCount;
  final int taxRatesCount;
  final Duration loadDuration;
  final List<String> errors;

  SessionDataLoadResult({
    required this.success,
    required this.sessionId,
    required this.productsCount,
    required this.categoriesCount,
    required this.customersCount,
    required this.paymentMethodsCount,
    required this.taxRatesCount,
    required this.loadDuration,
    required this.errors,
  });

  int get totalItemsLoaded =>
      productsCount +
      categoriesCount +
      customersCount +
      paymentMethodsCount +
      taxRatesCount;

  String get summary =>
      'Loaded $totalItemsLoaded items in ${loadDuration.inSeconds}s';

  bool get hasErrors => errors.isNotEmpty;
}

/// Progress update for session data loading
class SessionDataLoadProgress {
  final String stage;
  final String message;
  final double progress; // 0.0 to 1.0
  final bool isComplete;
  final bool hasError;

  SessionDataLoadProgress({
    required this.stage,
    required this.message,
    required this.progress,
    this.isComplete = false,
    this.hasError = false,
  });
}
