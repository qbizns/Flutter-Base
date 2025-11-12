/// Cash Movement Model
/// Represents cash in/out movements during a POS session
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_movement.freezed.dart';
part 'cash_movement.g.dart';

/// Cash Movement entity
@freezed
class CashMovement with _$CashMovement {
  const factory CashMovement({
    /// Unique movement ID
    required String id,

    /// POS Session ID
    required String sessionId,

    /// Movement type (in or out)
    required CashMovementType type,

    /// Amount
    required double amount,

    /// Reason/category for movement
    required CashMovementReason reason,

    /// Custom reason text
    String? customReason,

    /// Notes/description
    String? notes,

    /// Created by user ID
    required String createdBy,

    /// Created by user name
    required String createdByName,

    /// Created at timestamp
    required DateTime createdAt,
  }) = _CashMovement;

  factory CashMovement.fromJson(Map<String, dynamic> json) =>
      _$CashMovementFromJson(json);
}

/// Cash movement type
enum CashMovementType {
  /// Cash added to register
  cashIn,

  /// Cash removed from register
  cashOut;

  /// Get display name
  String get displayName {
    switch (this) {
      case CashMovementType.cashIn:
        return 'Cash In';
      case CashMovementType.cashOut:
        return 'Cash Out';
    }
  }

  /// Check if this is cash in
  bool get isCashIn => this == CashMovementType.cashIn;

  /// Check if this is cash out
  bool get isCashOut => this == CashMovementType.cashOut;
}

/// Cash movement reason
enum CashMovementReason {
  /// Opening balance
  opening,

  /// Safe drop (removing excess cash)
  safeDrop,

  /// Bank deposit
  bankDeposit,

  /// Petty cash
  pettyCash,

  /// Tips payout
  tips,

  /// Cash from bank
  cashFromBank,

  /// Vendor payment
  vendorPayment,

  /// Refund from supplier
  refundFromSupplier,

  /// Correction/adjustment
  correction,

  /// Other reason
  other;

  /// Get display name
  String get displayName {
    switch (this) {
      case CashMovementReason.opening:
        return 'Opening Balance';
      case CashMovementReason.safeDrop:
        return 'Safe Drop';
      case CashMovementReason.bankDeposit:
        return 'Bank Deposit';
      case CashMovementReason.pettyCash:
        return 'Petty Cash';
      case CashMovementReason.tips:
        return 'Tips Payout';
      case CashMovementReason.cashFromBank:
        return 'Cash from Bank';
      case CashMovementReason.vendorPayment:
        return 'Vendor Payment';
      case CashMovementReason.refundFromSupplier:
        return 'Refund from Supplier';
      case CashMovementReason.correction:
        return 'Correction/Adjustment';
      case CashMovementReason.other:
        return 'Other';
    }
  }

  /// Get typical type for this reason
  CashMovementType get typicalType {
    switch (this) {
      case CashMovementReason.opening:
      case CashMovementReason.cashFromBank:
      case CashMovementReason.refundFromSupplier:
        return CashMovementType.cashIn;
      case CashMovementReason.safeDrop:
      case CashMovementReason.bankDeposit:
      case CashMovementReason.pettyCash:
      case CashMovementReason.tips:
      case CashMovementReason.vendorPayment:
        return CashMovementType.cashOut;
      default:
        return CashMovementType.cashOut;
    }
  }
}
