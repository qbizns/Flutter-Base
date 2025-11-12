/// Session Remote Data Source
/// Handles API calls to backend for POS sessions
library;

import 'package:pos_core/pos_core.dart';
import '../../domain/models/pos_session.dart';
import '../../domain/models/cash_movement.dart';

/// Remote data source for session operations
class SessionRemoteDataSource {
  final ApiClient _apiClient;
  final AppContext _appContext;

  SessionRemoteDataSource({
    required ApiClient apiClient,
    required AppContext appContext,
  })  : _apiClient = apiClient,
        _appContext = appContext;

  /// Get current active session
  Future<PosSession?> getCurrentSession() async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.get(
        '/organizations/$orgId/pos-sessions/current',
      );

      if (response.statusCode == 404) {
        return null; // No active session
      }

      if (response.statusCode != 200) {
        throw AppException('Failed to get current session');
      }

      return PosSession.fromJson(response.data);
    } catch (e) {
      throw AppException('Failed to get current session: $e');
    }
  }

  /// Open a new POS session
  Future<PosSession> openSession({
    required double openingCash,
    required String registerId,
    String? notes,
  }) async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.post(
        '/organizations/$orgId/pos-sessions/open',
        data: {
          'opening_cash': openingCash,
          'register_id': registerId,
          'notes': notes,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw AppException('Failed to open session');
      }

      return PosSession.fromJson(response.data);
    } catch (e) {
      throw AppException('Failed to open session: $e');
    }
  }

  /// Close current POS session
  Future<PosSession> closeSession({
    required String sessionId,
    required double actualClosingCash,
    String? notes,
  }) async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.post(
        '/organizations/$orgId/pos-sessions/$sessionId/close',
        data: {
          'actual_closing_cash': actualClosingCash,
          'notes': notes,
        },
      );

      if (response.statusCode != 200) {
        throw AppException('Failed to close session');
      }

      return PosSession.fromJson(response.data);
    } catch (e) {
      throw AppException('Failed to close session: $e');
    }
  }

  /// Get session by ID
  Future<PosSession> getSessionById(String sessionId) async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.get(
        '/organizations/$orgId/pos-sessions/$sessionId',
      );

      if (response.statusCode != 200) {
        throw AppException('Failed to get session');
      }

      return PosSession.fromJson(response.data);
    } catch (e) {
      throw AppException('Failed to get session: $e');
    }
  }

  /// Get session history
  Future<List<PosSession>> getSessionHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.get(
        '/organizations/$orgId/pos-sessions',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'sort': '-created_at', // Most recent first
        },
      );

      if (response.statusCode != 200) {
        throw AppException('Failed to get session history');
      }

      final List<dynamic> data = response.data['items'] ?? response.data;
      return data.map((json) => PosSession.fromJson(json)).toList();
    } catch (e) {
      throw AppException('Failed to get session history: $e');
    }
  }

  /// Add cash movement
  Future<CashMovement> addCashMovement({
    required String sessionId,
    required CashMovementType type,
    required double amount,
    required CashMovementReason reason,
    String? customReason,
    String? notes,
  }) async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.post(
        '/organizations/$orgId/pos-sessions/$sessionId/cash-movements',
        data: {
          'type': type.name,
          'amount': amount,
          'reason': reason.name,
          'custom_reason': customReason,
          'notes': notes,
        },
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw AppException('Failed to add cash movement');
      }

      return CashMovement.fromJson(response.data);
    } catch (e) {
      throw AppException('Failed to add cash movement: $e');
    }
  }

  /// Get cash movements for session
  Future<List<CashMovement>> getCashMovements(String sessionId) async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.get(
        '/organizations/$orgId/pos-sessions/$sessionId/cash-movements',
      );

      if (response.statusCode != 200) {
        throw AppException('Failed to get cash movements');
      }

      final List<dynamic> data = response.data['items'] ?? response.data;
      return data.map((json) => CashMovement.fromJson(json)).toList();
    } catch (e) {
      throw AppException('Failed to get cash movements: $e');
    }
  }

  /// Update session
  Future<PosSession> updateSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.patch(
        '/organizations/$orgId/pos-sessions/$sessionId',
        data: updates,
      );

      if (response.statusCode != 200) {
        throw AppException('Failed to update session');
      }

      return PosSession.fromJson(response.data);
    } catch (e) {
      throw AppException('Failed to update session: $e');
    }
  }

  /// Cancel session
  Future<void> cancelSession(String sessionId) async {
    try {
      final orgId = _appContext.currentOrganizationId;
      if (orgId == null) {
        throw AppException('No organization context');
      }

      final response = await _apiClient.post(
        '/organizations/$orgId/pos-sessions/$sessionId/cancel',
      );

      if (response.statusCode != 200) {
        throw AppException('Failed to cancel session');
      }
    } catch (e) {
      throw AppException('Failed to cancel session: $e');
    }
  }
}
