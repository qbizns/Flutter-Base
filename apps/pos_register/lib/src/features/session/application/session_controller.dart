/// Session Controller
/// Manages POS session state and operations
library;

import 'dart:io' show Platform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../domain/models/pos_session.dart';
import '../domain/models/cash_movement.dart';
import '../domain/models/cash_count.dart';
import '../domain/repositories/session_repository.dart';

/// Session state controller (Odoo pattern)
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

  /// Get device ID using platform-specific methods
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id; // Android ID (unique per device)
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'iOS-Unknown';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.machineId ?? 'Linux-Unknown';
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.systemGUID ?? 'MacOS-Unknown';
      } else {
        return 'Web-${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      // Fallback to timestamp-based ID
      return 'Device-${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get device name using platform-specific methods
  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name} (${iosInfo.model})';
      } else if (Platform.isLinux) {
        final linuxInfo = await deviceInfo.linuxInfo;
        return linuxInfo.prettyName;
      } else if (Platform.isWindows) {
        final windowsInfo = await deviceInfo.windowsInfo;
        return windowsInfo.computerName;
      } else if (Platform.isMacOS) {
        final macInfo = await deviceInfo.macOsInfo;
        return macInfo.computerName;
      } else {
        return 'Web Browser';
      }
    } catch (e) {
      return 'POS Terminal';
    }
  }

  /// Convert CashCount to JSON format for API
  Map<String, dynamic> _convertCashCountToJson(CashCount cashCount) {
    final denominations = <String, Map<String, dynamic>>{};

    for (final denom in cashCount.denominations) {
      final key = denom.value >= 1
          ? (denom.type == DenominationType.bill ? '${denom.value.toInt()}s' : 'dollars')
          : (denom.value == 0.25
              ? 'quarters'
              : denom.value == 0.10
                  ? 'dimes'
                  : denom.value == 0.05
                      ? 'nickels'
                      : 'pennies');

      denominations[key] = {
        'count': denom.quantity,
        'value': denom.amount,
      };
    }

    return {
      'denominations': cashCount.denominations
          .map((d) => {
                'value': d.value,
                'type': d.type.name,
                'quantity': d.quantity,
                'amount': d.amount,
              })
          .toList(),
      'total': cashCount.totalAmount,
    };
  }

  /// Open a new POS session (Odoo pattern with denominations)
  Future<bool> openSession({
    required double openingCash,
    required String registerId,
    CashCount? cashCount,
    String? notes,
  }) async {
    // Set loading state
    state = const AsyncValue.loading();

    // Get device info
    final deviceId = await _getDeviceId();
    final deviceName = await _getDeviceName();

    // Convert cash count to JSON if provided
    Map<String, dynamic>? cashDenominations;
    if (cashCount != null) {
      cashDenominations = _convertCashCountToJson(cashCount);
    }

    final result = await _repository.openSession(
      openingCash: openingCash,
      registerId: registerId,
      cashDenominations: cashDenominations,
      deviceId: deviceId,
      deviceName: deviceName,
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

  /// Close current POS session (Odoo pattern with full reconciliation)
  Future<bool> closeSession({
    required double actualClosingCash,
    CashCount? cashCount,
    double? actualCard,
    double? actualOther,
    String? notes,
  }) async {
    // Set loading state
    state = const AsyncValue.loading();

    // Convert cash count to JSON if provided
    Map<String, dynamic>? cashDenominations;
    if (cashCount != null) {
      cashDenominations = _convertCashCountToJson(cashCount);
    }

    final result = await _repository.closeSession(
      actualClosingCash: actualClosingCash,
      cashDenominations: cashDenominations,
      actualCard: actualCard,
      actualOther: actualOther,
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
