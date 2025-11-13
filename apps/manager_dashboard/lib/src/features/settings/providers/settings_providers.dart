import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../models/settings_models.dart';

/// Storage key for settings
const String _settingsStorageKey = 'app_settings';

/// Settings state notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  final AppStorage _storage;

  SettingsNotifier(this._storage) : super(AppSettings.defaultSettings()) {
    _loadSettings();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      final settingsJson = await _storage.getString(_settingsStorageKey);
      if (settingsJson != null && settingsJson.isNotEmpty) {
        final decoded = jsonDecode(settingsJson) as Map<String, dynamic>;
        state = AppSettings.fromJson(decoded);
      }
    } catch (e) {
      // If there's an error loading settings, use defaults
      state = AppSettings.defaultSettings();
    }
  }

  /// Save settings to storage
  Future<bool> saveSettings() async {
    try {
      final settingsJson = jsonEncode(state.toJson());
      return await _storage.saveString(_settingsStorageKey, settingsJson);
    } catch (e) {
      return false;
    }
  }

  /// Update general settings
  void updateGeneralSettings({
    String? restaurantName,
    String? location,
    String? contactEmail,
    String? contactPhone,
    String? timezone,
    String? currency,
    String? language,
  }) {
    state = state.copyWith(
      restaurantName: restaurantName,
      location: location,
      contactEmail: contactEmail,
      contactPhone: contactPhone,
      timezone: timezone,
      currency: currency,
      language: language,
    );
  }

  /// Update API configuration
  void updateApiConfig(ApiConfiguration apiConfig) {
    state = state.copyWith(apiConfig: apiConfig);
  }

  /// Update appearance settings
  void updateAppearanceSettings({
    AppThemeMode? themeMode,
    Color? primaryColor,
    double? fontSize,
  }) {
    state = state.copyWith(
      themeMode: themeMode,
      primaryColor: primaryColor,
      fontSize: fontSize,
    );
  }

  /// Update business hours for a specific day
  void updateBusinessHours(int dayOfWeek, BusinessHours hours) {
    final updatedHours = Map<int, BusinessHours>.from(state.businessHours);
    updatedHours[dayOfWeek] = hours;
    state = state.copyWith(businessHours: updatedHours);
  }

  /// Add holiday
  void addHoliday(DateTime date) {
    final updatedHolidays = List<DateTime>.from(state.holidays);
    if (!updatedHolidays.contains(date)) {
      updatedHolidays.add(date);
      state = state.copyWith(holidays: updatedHolidays);
    }
  }

  /// Remove holiday
  void removeHoliday(DateTime date) {
    final updatedHolidays = List<DateTime>.from(state.holidays);
    updatedHolidays.removeWhere((d) =>
        d.year == date.year && d.month == date.month && d.day == date.day);
    state = state.copyWith(holidays: updatedHolidays);
  }

  /// Update tax settings
  void updateTaxSettings(TaxSettings taxSettings) {
    state = state.copyWith(taxSettings: taxSettings);
  }

  /// Add tax rate
  void addTaxRate(TaxRate taxRate) {
    final updatedRates = List<TaxRate>.from(state.taxSettings.taxRates);
    updatedRates.add(taxRate);
    state = state.copyWith(
      taxSettings: state.taxSettings.copyWith(taxRates: updatedRates),
    );
  }

  /// Update tax rate
  void updateTaxRate(String id, TaxRate updatedRate) {
    final updatedRates = state.taxSettings.taxRates.map((rate) {
      return rate.id == id ? updatedRate : rate;
    }).toList();
    state = state.copyWith(
      taxSettings: state.taxSettings.copyWith(taxRates: updatedRates),
    );
  }

  /// Remove tax rate
  void removeTaxRate(String id) {
    final updatedRates = state.taxSettings.taxRates
        .where((rate) => rate.id != id)
        .toList();
    state = state.copyWith(
      taxSettings: state.taxSettings.copyWith(taxRates: updatedRates),
    );
  }

  /// Update receipt settings
  void updateReceiptSettings(ReceiptSettings receiptSettings) {
    state = state.copyWith(receiptSettings: receiptSettings);
  }

  /// Update notification settings
  void updateNotificationSettings(NotificationSettings notificationSettings) {
    state = state.copyWith(notificationSettings: notificationSettings);
  }

  /// Reset settings to default
  void resetToDefaults() {
    state = AppSettings.defaultSettings();
  }
}

/// Settings provider
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final storage = ref.watch(appStorageProvider).requireValue;
  return SettingsNotifier(storage);
});

/// Theme mode provider (derived from settings)
final themeModeProvider = Provider<AppThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

/// Primary color provider (derived from settings)
final primaryColorProvider = Provider<Color>((ref) {
  return ref.watch(settingsProvider).primaryColor;
});

/// Currency provider (derived from settings)
final currencyProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).currency;
});

/// Timezone provider (derived from settings)
final timezoneProvider = Provider<String>((ref) {
  return ref.watch(settingsProvider).timezone;
});
