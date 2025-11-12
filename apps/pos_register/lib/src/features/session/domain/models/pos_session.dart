/// POS Session Model
/// Represents a cashier work session with opening and closing cash management
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'pos_session.freezed.dart';
part 'pos_session.g.dart';

/// POS Session entity
/// Follows Odoo POS session workflow
@freezed
class PosSession with _$PosSession {
  const factory PosSession({
    /// Unique session ID
    required String id,

    /// Session number/name (e.g., "Session #045")
    required String number,

    /// Organization ID
    required String organizationId,

    /// Cashier user ID
    required String userId,

    /// Cashier user name
    required String userName,

    /// Register/Terminal ID
    required String registerId,

    /// Register name
    required String registerName,

    /// Session status
    required SessionStatus status,

    /// Opening date and time
    required DateTime startedAt,

    /// Closing date and time (null if still open)
    DateTime? closedAt,

    /// Opening cash amount
    required double openingCash,

    /// Expected closing cash (based on transactions)
    required double expectedClosingCash,

    /// Actual closing cash (counted by cashier)
    double? actualClosingCash,

    /// Cash difference (actual - expected)
    double? cashDifference,

    /// Total sales amount during session
    @Default(0.0) double totalSales,

    /// Total number of orders
    @Default(0) int totalOrders,

    /// Total cash in movements
    @Default(0.0) double totalCashIn,

    /// Total cash out movements
    @Default(0.0) double totalCashOut,

    /// Total cash payments
    @Default(0.0) double totalCashPayments,

    /// Total card payments
    @Default(0.0) double totalCardPayments,

    /// Total mobile payments
    @Default(0.0) double totalMobilePayments,

    /// Notes from cashier
    String? notes,

    /// Created at timestamp
    required DateTime createdAt,

    /// Updated at timestamp
    required DateTime updatedAt,
  }) = _PosSession;

  factory PosSession.fromJson(Map<String, dynamic> json) =>
      _$PosSessionFromJson(json);
}

/// Session status enum
enum SessionStatus {
  /// Draft state - session being prepared
  draft,

  /// Open and active
  open,

  /// Closing in progress
  closing,

  /// Closed successfully
  closed,

  /// Cancelled
  cancelled;

  /// Get display name
  String get displayName {
    switch (this) {
      case SessionStatus.draft:
        return 'Draft';
      case SessionStatus.open:
        return 'Open';
      case SessionStatus.closing:
        return 'Closing';
      case SessionStatus.closed:
        return 'Closed';
      case SessionStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Check if session is active
  bool get isActive => this == SessionStatus.open;

  /// Check if session is closed
  bool get isClosed =>
      this == SessionStatus.closed || this == SessionStatus.cancelled;
}
