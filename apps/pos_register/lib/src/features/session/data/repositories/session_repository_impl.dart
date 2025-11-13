/// Session Repository Implementation
/// Implements session repository contract with backend integration
library;

import 'package:pos_core/pos_core.dart';
import '../../domain/models/pos_session.dart';
import '../../domain/models/cash_movement.dart';
import '../../domain/repositories/session_repository.dart';
import '../datasources/session_remote_datasource.dart';

/// Session repository implementation
class SessionRepositoryImpl implements SessionRepository {
  final SessionRemoteDataSource _remoteDataSource;

  SessionRepositoryImpl({
    required SessionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<PosSession?>> getCurrentSession() async {
    try {
      final session = await _remoteDataSource.getCurrentSession();
      return Result.success(session);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to get current session: $e'),
      );
    }
  }

  @override
  Future<Result<PosSession>> openSession({
    required double openingCash,
    required String registerId,
    Map<String, dynamic>? cashDenominations,
    String? deviceId,
    String? deviceName,
    String? notes,
  }) async {
    try {
      final session = await _remoteDataSource.openSession(
        openingCash: openingCash,
        registerId: registerId,
        cashDenominations: cashDenominations,
        deviceId: deviceId,
        deviceName: deviceName,
        notes: notes,
      );
      return Result.success(session);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to open session: $e'),
      );
    }
  }

  @override
  Future<Result<PosSession>> closeSession({
    required double actualClosingCash,
    Map<String, dynamic>? cashDenominations,
    double? actualCard,
    double? actualOther,
    String? notes,
  }) async {
    try {
      // First get current session to get its ID
      final currentSessionResult = await getCurrentSession();
      if (currentSessionResult.isFailure) {
        return Result.failure(currentSessionResult.error!);
      }

      final currentSession = currentSessionResult.data;
      if (currentSession == null) {
        return Result.failure(
          Failure(message: 'No active session to close'),
        );
      }

      final session = await _remoteDataSource.closeSession(
        sessionId: currentSession.id,
        actualClosingCash: actualClosingCash,
        cashDenominations: cashDenominations,
        actualCard: actualCard,
        actualOther: actualOther,
        notes: notes,
      );
      return Result.success(session);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to close session: $e'),
      );
    }
  }

  @override
  Future<Result<PosSession>> getSessionById(String sessionId) async {
    try {
      final session = await _remoteDataSource.getSessionById(sessionId);
      return Result.success(session);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to get session: $e'),
      );
    }
  }

  @override
  Future<Result<List<PosSession>>> getSessionHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final sessions = await _remoteDataSource.getSessionHistory(
        limit: limit,
        offset: offset,
      );
      return Result.success(sessions);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to get session history: $e'),
      );
    }
  }

  @override
  Future<Result<CashMovement>> addCashMovement({
    required CashMovementType type,
    required double amount,
    required CashMovementReason reason,
    String? customReason,
    String? notes,
  }) async {
    try {
      // First get current session to get its ID
      final currentSessionResult = await getCurrentSession();
      if (currentSessionResult.isFailure) {
        return Result.failure(currentSessionResult.error!);
      }

      final currentSession = currentSessionResult.data;
      if (currentSession == null) {
        return Result.failure(
          Failure(message: 'No active session for cash movement'),
        );
      }

      final movement = await _remoteDataSource.addCashMovement(
        sessionId: currentSession.id,
        type: type,
        amount: amount,
        reason: reason,
        customReason: customReason,
        notes: notes,
      );
      return Result.success(movement);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to add cash movement: $e'),
      );
    }
  }

  @override
  Future<Result<List<CashMovement>>> getCashMovements(
    String sessionId,
  ) async {
    try {
      final movements = await _remoteDataSource.getCashMovements(sessionId);
      return Result.success(movements);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to get cash movements: $e'),
      );
    }
  }

  @override
  Future<Result<PosSession>> updateSession(PosSession session) async {
    try {
      final updatedSession = await _remoteDataSource.updateSession(
        session.id,
        session.toJson(),
      );
      return Result.success(updatedSession);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to update session: $e'),
      );
    }
  }

  @override
  Future<Result<void>> cancelSession(String sessionId) async {
    try {
      await _remoteDataSource.cancelSession(sessionId);
      return const Result.success(null);
    } on AppException catch (e) {
      return Result.failure(Failure(message: e.message));
    } catch (e) {
      return Result.failure(
        Failure(message: 'Failed to cancel session: $e'),
      );
    }
  }
}
