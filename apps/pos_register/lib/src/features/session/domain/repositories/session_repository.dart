/// Session Repository Interface
/// Contract for POS session data operations
library;

import 'package:pos_core/pos_core.dart';
import '../models/pos_session.dart';
import '../models/cash_movement.dart';

/// Session repository contract
abstract class SessionRepository {
  /// Get current active session for the user
  Future<Result<PosSession?>> getCurrentSession();

  /// Open a new POS session
  /// [openingCash] - Initial cash amount in register
  /// [registerId] - POS register/terminal ID
  /// [notes] - Optional opening notes
  Future<Result<PosSession>> openSession({
    required double openingCash,
    required String registerId,
    String? notes,
  });

  /// Close current POS session
  /// [actualClosingCash] - Physical cash counted
  /// [notes] - Optional closing notes
  Future<Result<PosSession>> closeSession({
    required double actualClosingCash,
    String? notes,
  });

  /// Get session by ID
  Future<Result<PosSession>> getSessionById(String sessionId);

  /// Get session history for current user
  /// [limit] - Number of sessions to fetch
  /// [offset] - Pagination offset
  Future<Result<List<PosSession>>> getSessionHistory({
    int limit = 20,
    int offset = 0,
  });

  /// Add cash movement to current session
  /// [type] - Cash in or cash out
  /// [amount] - Movement amount
  /// [reason] - Movement reason
  /// [notes] - Optional notes
  Future<Result<CashMovement>> addCashMovement({
    required CashMovementType type,
    required double amount,
    required CashMovementReason reason,
    String? customReason,
    String? notes,
  });

  /// Get cash movements for a session
  Future<Result<List<CashMovement>>> getCashMovements(String sessionId);

  /// Update session (for internal use)
  Future<Result<PosSession>> updateSession(PosSession session);

  /// Cancel session (emergency use)
  Future<Result<void>> cancelSession(String sessionId);
}
