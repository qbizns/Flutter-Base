/// Cash Count Model
/// Represents the physical cash counting process during session open/close
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'cash_count.freezed.dart';
part 'cash_count.g.dart';

/// Cash Count entity
/// Used for detailed bill and coin counting (Odoo-style)
@freezed
class CashCount with _$CashCount {
  const factory CashCount({
    /// Count type (opening or closing)
    required CashCountType type,

    /// List of denominations counted
    @Default([]) List<CashDenomination> denominations,

    /// Total amount
    @Default(0.0) double totalAmount,

    /// Counted at timestamp
    DateTime? countedAt,

    /// Counted by user
    String? countedBy,
  }) = _CashCount;

  factory CashCount.fromJson(Map<String, dynamic> json) =>
      _$CashCountFromJson(json);
}

/// Cash count type
enum CashCountType {
  /// Opening count
  opening,

  /// Closing count
  closing;

  String get displayName {
    switch (this) {
      case CashCountType.opening:
        return 'Opening Count';
      case CashCountType.closing:
        return 'Closing Count';
    }
  }
}

/// Cash denomination (bill or coin)
@freezed
class CashDenomination with _$CashDenomination {
  const factory CashDenomination({
    /// Denomination value (e.g., 1, 5, 10, 20, 50, 100)
    required double value,

    /// Denomination type
    required DenominationType type,

    /// Quantity counted
    @Default(0) int quantity,

    /// Total amount for this denomination
    @Default(0.0) double amount,
  }) = _CashDenomination;

  factory CashDenomination.fromJson(Map<String, dynamic> json) =>
      _$CashDenominationFromJson(json);
}

/// Denomination type
enum DenominationType {
  /// Paper money
  bill,

  /// Metal money
  coin;

  String get displayName {
    switch (this) {
      case DenominationType.bill:
        return 'Bill';
      case DenominationType.coin:
        return 'Coin';
    }
  }
}

/// Predefined US dollar denominations
class USDenominations {
  USDenominations._();

  /// Get all US bill denominations
  static List<CashDenomination> get bills => [
        const CashDenomination(value: 100, type: DenominationType.bill),
        const CashDenomination(value: 50, type: DenominationType.bill),
        const CashDenomination(value: 20, type: DenominationType.bill),
        const CashDenomination(value: 10, type: DenominationType.bill),
        const CashDenomination(value: 5, type: DenominationType.bill),
        const CashDenomination(value: 1, type: DenominationType.bill),
      ];

  /// Get all US coin denominations
  static List<CashDenomination> get coins => [
        const CashDenomination(value: 1.00, type: DenominationType.coin),
        const CashDenomination(value: 0.50, type: DenominationType.coin),
        const CashDenomination(value: 0.25, type: DenominationType.coin),
        const CashDenomination(value: 0.10, type: DenominationType.coin),
        const CashDenomination(value: 0.05, type: DenominationType.coin),
        const CashDenomination(value: 0.01, type: DenominationType.coin),
      ];

  /// Get all US denominations (bills + coins)
  static List<CashDenomination> get all => [...bills, ...coins];
}

/// Extension methods for CashCount
extension CashCountX on CashCount {
  /// Calculate total from denominations
  double calculateTotal() {
    return denominations.fold(
      0.0,
      (sum, denom) => sum + (denom.value * denom.quantity),
    );
  }

  /// Update quantity for a denomination
  CashCount updateDenomination(double value, int quantity) {
    final updatedDenoms = denominations.map((d) {
      if (d.value == value) {
        final amount = value * quantity;
        return d.copyWith(quantity: quantity, amount: amount);
      }
      return d;
    }).toList();

    return copyWith(
      denominations: updatedDenoms,
      totalAmount: updatedDenoms.fold(
        0.0,
        (sum, d) => sum + d.amount,
      ),
    );
  }

  /// Reset all counts to zero
  CashCount reset() {
    final resetDenoms = denominations.map((d) {
      return d.copyWith(quantity: 0, amount: 0.0);
    }).toList();

    return copyWith(
      denominations: resetDenoms,
      totalAmount: 0.0,
    );
  }
}
