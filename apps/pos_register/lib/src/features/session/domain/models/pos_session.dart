/// POS Session Model
/// Represents a cashier work session with opening and closing cash management
library;

import 'package:freezed_annotation/freezed_annotation.dart';
import 'cash_count.dart';

part 'pos_session.freezed.dart';
part 'pos_session.g.dart';

/// POS Session entity
/// Follows Odoo POS session workflow with full denomination tracking
@freezed
class PosSession with _$PosSession {
  const factory PosSession({
    /// Unique session ID
    required String id,

    /// Session number/name (e.g., "2025-11-13-001")
    required String number,

    /// Z-report number (for closed sessions)
    String? zReportNumber,

    /// Organization ID
    required String organizationId,

    /// Cashier user ID
    required String userId,

    /// Cashier user name
    required String userName,

    /// Register/Terminal ID (device ID)
    required String registerId,

    /// Register name
    required String registerName,

    /// Session status
    required SessionStatus status,

    /// Opening date and time
    required DateTime startedAt,

    /// Closing date and time (null if still open)
    DateTime? closedAt,

    /// Duration in seconds (calculated for closed sessions)
    int? durationSeconds,

    // ========================================
    // OPENING CASH (Odoo pattern with denominations)
    // ========================================

    /// Opening cash amount (total)
    required double openingCash,

    /// Opening cash denominations (Odoo pattern)
    /// Stored as JSON with denomination breakdown
    Map<String, dynamic>? openingCashDenominations,

    /// Opening card amount
    @Default(0.0) double openingCard,

    /// Opening other payment methods
    @Default(0.0) double openingOther,

    // ========================================
    // EXPECTED AMOUNTS (calculated from transactions)
    // ========================================

    /// Expected closing cash (opening + cash payments + cash in - cash out)
    required double expectedClosingCash,

    /// Expected card amount
    @Default(0.0) double expectedCard,

    /// Expected other payments
    @Default(0.0) double expectedOther,

    // ========================================
    // ACTUAL COUNTED AMOUNTS (Odoo pattern)
    // ========================================

    /// Actual closing cash (counted by cashier)
    double? actualClosingCash,

    /// Closing cash denominations (Odoo pattern)
    Map<String, dynamic>? closingCashDenominations,

    /// Actual card amount counted
    double? actualCard,

    /// Actual other payments counted
    double? actualOther,

    // ========================================
    // DIFFERENCES / VARIANCE (Odoo pattern)
    // ========================================

    /// Cash difference (actual - expected)
    double? cashDifference,

    /// Cash difference percentage
    double? cashDifferencePercent,

    /// Card difference
    double? cardDifference,

    /// Other difference
    double? otherDifference,

    /// Total difference
    double? totalDifference,

    // ========================================
    // SALES STATISTICS
    // ========================================

    /// Total sales amount during session
    @Default(0.0) double totalSales,

    /// Gross sales (before discounts/refunds)
    @Default(0.0) double grossSales,

    /// Total discounts given
    @Default(0.0) double totalDiscounts,

    /// Total refunds processed
    @Default(0.0) double totalRefunds,

    /// Net sales (gross - discounts - refunds)
    @Default(0.0) double netSales,

    /// Total tax collected
    @Default(0.0) double totalTax,

    /// Total tips collected
    @Default(0.0) double totalTips,

    /// Total number of orders
    @Default(0) int totalOrders,

    /// Number of voided orders
    @Default(0) int voidedOrders,

    /// Number of refunded orders
    @Default(0) int refundedOrders,

    // ========================================
    // CASH MOVEMENTS (Odoo pattern)
    // ========================================

    /// Total cash in movements
    @Default(0.0) double totalCashIn,

    /// Total cash out movements
    @Default(0.0) double totalCashOut,

    /// Net cash movements (cash in - cash out)
    @Default(0.0) double netCashMovements,

    /// Number of cash movements
    @Default(0) int cashMovementsCount,

    // ========================================
    // PAYMENT METHOD BREAKDOWN
    // ========================================

    /// Total cash payments
    @Default(0.0) double totalCashPayments,

    /// Total card payments
    @Default(0.0) double totalCardPayments,

    /// Total mobile payments
    @Default(0.0) double totalMobilePayments,

    /// Number of cash payment transactions
    @Default(0) int cashPaymentCount,

    /// Number of card payment transactions
    @Default(0) int cardPaymentCount,

    /// Number of mobile payment transactions
    @Default(0) int mobilePaymentCount,

    // ========================================
    // NOTES & METADATA
    // ========================================

    /// Opening notes from cashier
    String? openingNotes,

    /// Closing notes from cashier
    String? closingNotes,

    /// System notes (auto-generated)
    String? systemNotes,

    /// Created at timestamp
    required DateTime createdAt,

    /// Updated at timestamp
    required DateTime updatedAt,
  }) = _PosSession;

  factory PosSession.fromJson(Map<String, dynamic> json) =>
      _$PosSessionFromJson(json);
}

/// Extension methods for PosSession
extension PosSessionX on PosSession {
  /// Get opening cash count from denominations
  CashCount? get openingCashCount {
    if (openingCashDenominations == null) return null;

    try {
      return CashCount.fromJson({
        'type': 'opening',
        'denominations': openingCashDenominations!['denominations'] ?? [],
        'total_amount': openingCash,
        'counted_at': startedAt.toIso8601String(),
        'counted_by': userId,
      });
    } catch (e) {
      return null;
    }
  }

  /// Get closing cash count from denominations
  CashCount? get closingCashCount {
    if (closingCashDenominations == null) return null;

    try {
      return CashCount.fromJson({
        'type': 'closing',
        'denominations': closingCashDenominations!['denominations'] ?? [],
        'total_amount': actualClosingCash ?? 0.0,
        'counted_at': closedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        'counted_by': userId,
      });
    } catch (e) {
      return null;
    }
  }

  /// Check if session has variance issues
  bool get hasVariance {
    if (cashDifference == null) return false;
    return cashDifference!.abs() > 0.01; // More than 1 cent
  }

  /// Check if variance is significant (>2%)
  bool get hasSignificantVariance {
    if (cashDifferencePercent == null) return false;
    return cashDifferencePercent!.abs() > 2.0;
  }

  /// Check if session is short (missing money)
  bool get isShort {
    if (totalDifference == null) return false;
    return totalDifference! < -0.01;
  }

  /// Check if session is over (extra money)
  bool get isOver {
    if (totalDifference == null) return false;
    return totalDifference! > 0.01;
  }

  /// Get session duration as formatted string
  String get durationFormatted {
    if (durationSeconds == null) {
      if (!status.isClosed) {
        final duration = DateTime.now().difference(startedAt);
        return _formatDuration(duration);
      }
      return 'N/A';
    }

    return _formatDuration(Duration(seconds: durationSeconds!));
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Get variance status color
  /// Returns: 'success' for balanced, 'warning' for small variance, 'danger' for significant
  String get varianceStatus {
    if (!hasVariance) return 'success';
    if (hasSignificantVariance) return 'danger';
    return 'warning';
  }

  /// Calculate expected closing balance (for display)
  double get calculatedExpectedClosing {
    return openingCash +
           totalCashPayments +
           totalCashIn -
           totalCashOut;
  }
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
