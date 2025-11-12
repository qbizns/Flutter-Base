/// Session Controller
/// Manages POS session state and operations
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/pos_session.dart';
import '../domain/models/cash_movement.dart';
import '../domain/repositories/session_repository.dart';

/// Session state controller
class SessionController extends StateNotifier<AsyncValue<PosSession?>> {
  final SessionRepository _repository;

  SessionController({
    required SessionRepository repository,
  })  : _repository = repository,
        super(const AsyncValue.loading()) {
    // Load current session on initialization
    loadCurrentSession();
  }

  /// Load current active session
  Future<void> loadCurrentSession() async {
    state = const AsyncValue.loading();

    final result = await _repository.getCurrentSession();

    state = result.when(
      success: (session) => AsyncValue.data(session),
      failure: (error) => AsyncValue.error(
        Exception(error.message),
        StackTrace.current,
      ),
    );
  }

  /// Open a new POS session
  Future<bool> openSession({
    required double openingCash,
    required String registerId,
    String? notes,
  }) async {
    // Set loading state
    state = const AsyncValue.loading();

    final result = await _repository.openSession(
      openingCash: openingCash,
      registerId: registerId,
      notes: notes,
    );

    return result.when(
      success: (session) {
        state = AsyncValue.data(session);
        return true;
      },
      failure: (error) {
        state = AsyncValue.error(
          Exception(error.message),
          StackTrace.current,
        );
        return false;
      },
    );
  }

  /// Close current POS session
  Future<bool> closeSession({
    required double actualClosingCash,
    String? notes,
  }) async {
    // Set loading state
    state = const AsyncValue.loading();

    final result = await _repository.closeSession(
      actualClosingCash: actualClosingCash,
      notes: notes,
    );

    return result.when(
      success: (session) {
        state = AsyncValue.data(session);
        return true;
      },
      failure: (error) {
        state = AsyncValue.error(
          Exception(error.message),
          StackTrace.current,
        );
        return false;
      },
    );
  }

  /// Add cash movement to current session
  Future<bool> addCashMovement({
    required CashMovementType type,
    required double amount,
    required CashMovementReason reason,
    String? customReason,
    String? notes,
  }) async {
    final result = await _repository.addCashMovement(
      type: type,
      amount: amount,
      reason: reason,
      customReason: customReason,
      notes: notes,
    );

    if (result.isSuccess) {
      // Reload session to get updated totals
      await loadCurrentSession();
      return true;
    } else {
      return false;
    }
  }

  /// Cancel session (emergency)
  Future<bool> cancelSession(String sessionId) async {
    final result = await _repository.cancelSession(sessionId);

    if (result.isSuccess) {
      state = const AsyncValue.data(null);
      return true;
    } else {
      return false;
    }
  }

  /// Refresh current session data
  Future<void> refresh() async {
    await loadCurrentSession();
  }
}
