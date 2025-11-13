/// Tax Settings Provider
/// Provides tax configuration for POS operations
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tax Settings Model
class TaxSettings {
  final double defaultTaxPercent;
  final bool taxIncludedInPrice;
  final String taxName;

  const TaxSettings({
    this.defaultTaxPercent = 8.5,
    this.taxIncludedInPrice = false,
    this.taxName = 'Sales Tax',
  });

  TaxSettings copyWith({
    double? defaultTaxPercent,
    bool? taxIncludedInPrice,
    String? taxName,
  }) {
    return TaxSettings(
      defaultTaxPercent: defaultTaxPercent ?? this.defaultTaxPercent,
      taxIncludedInPrice: taxIncludedInPrice ?? this.taxIncludedInPrice,
      taxName: taxName ?? this.taxName,
    );
  }
}

/// Tax Settings Provider
/// Loads and provides tax configuration
final taxSettingsProvider = FutureProvider<TaxSettings>((ref) async {
  final prefs = await SharedPreferences.getInstance();

  final taxPercent = prefs.getDouble('tax_percent') ?? 8.5;
  final taxIncluded = prefs.getBool('tax_included_in_price') ?? false;
  final taxName = prefs.getString('tax_name') ?? 'Sales Tax';

  return TaxSettings(
    defaultTaxPercent: taxPercent,
    taxIncludedInPrice: taxIncluded,
    taxName: taxName,
  );
});

/// Tax Settings Notifier
/// Allows updating tax settings
class TaxSettingsNotifier extends StateNotifier<TaxSettings> {
  TaxSettingsNotifier() : super(const TaxSettings());

  Future<void> updateTaxPercent(double percent) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('tax_percent', percent);
    state = state.copyWith(defaultTaxPercent: percent);
  }

  Future<void> updateTaxIncluded(bool included) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tax_included_in_price', included);
    state = state.copyWith(taxIncludedInPrice: included);
  }

  Future<void> updateTaxName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tax_name', name);
    state = state.copyWith(taxName: name);
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final taxPercent = prefs.getDouble('tax_percent') ?? 8.5;
    final taxIncluded = prefs.getBool('tax_included_in_price') ?? false;
    final taxName = prefs.getString('tax_name') ?? 'Sales Tax';

    state = TaxSettings(
      defaultTaxPercent: taxPercent,
      taxIncludedInPrice: taxIncluded,
      taxName: taxName,
    );
  }
}

final taxSettingsNotifierProvider =
    StateNotifierProvider<TaxSettingsNotifier, TaxSettings>((ref) {
  final notifier = TaxSettingsNotifier();
  notifier.loadSettings();
  return notifier;
});
