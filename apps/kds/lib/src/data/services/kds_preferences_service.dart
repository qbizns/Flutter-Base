/// KDS Preferences Service
/// Handles persistence of KDS user preferences
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/kds_preferences.dart';

/// Preferences service provider
final kdsPreferencesServiceProvider = Provider<KdsPreferencesService>((ref) {
  return KdsPreferencesService();
});

/// Current preferences provider
final currentPreferencesProvider =
    StateNotifierProvider<PreferencesNotifier, KdsPreferences>((ref) {
  final service = ref.watch(kdsPreferencesServiceProvider);
  return PreferencesNotifier(service);
});

/// KDS Preferences Service
/// Manages loading and saving KDS preferences following Odoo patterns
class KdsPreferencesService {
  static const String _prefsKey = 'kds_preferences';
  SharedPreferences? _prefs;
  final _prefsController = StreamController<KdsPreferences>.broadcast();

  /// Stream of preference changes
  Stream<KdsPreferences> get preferencesStream => _prefsController.stream;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Load preferences from storage
  Future<KdsPreferences> loadPreferences() async {
    await initialize();

    final jsonString = _prefs?.getString(_prefsKey);
    if (jsonString == null) {
      // Return defaults if no saved preferences
      final defaults = KdsPreferences.defaults();
      await savePreferences(defaults);
      return defaults;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return KdsPreferences.fromJson(json);
    } catch (e) {
      // If parse error, return defaults
      return KdsPreferences.defaults();
    }
  }

  /// Save preferences to storage
  Future<bool> savePreferences(KdsPreferences preferences) async {
    await initialize();

    try {
      // Validate before saving
      if (!preferences.isValid) {
        return false;
      }

      final json = preferences.toJson();
      final jsonString = jsonEncode(json);
      final success = await _prefs?.setString(_prefsKey, jsonString) ?? false;

      if (success) {
        _prefsController.add(preferences);
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Reset preferences to defaults
  Future<bool> resetPreferences() async {
    await initialize();

    try {
      await _prefs?.remove(_prefsKey);
      final defaults = KdsPreferences.defaults();
      _prefsController.add(defaults);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update specific preference
  Future<bool> updatePreference<T>(
    KdsPreferences current,
    T Function(KdsPreferences) updater,
  ) async {
    // This is a helper to update a single field
    // Caller should create new instance with copyWith
    return savePreferences(current);
  }

  /// Quick setters for common preferences

  Future<bool> setSelectedStation(
    KdsPreferences current,
    String stationId,
  ) async {
    final updated = current.copyWith(selectedStationId: stationId);
    return savePreferences(updated);
  }

  Future<bool> setViewMode(KdsPreferences current, KdsViewMode mode) async {
    final updated = current.copyWith(viewMode: mode);
    return savePreferences(updated);
  }

  Future<bool> setSoundEnabled(KdsPreferences current, bool enabled) async {
    final updated = current.copyWith(soundEnabled: enabled);
    return savePreferences(updated);
  }

  Future<bool> setSoundVolume(KdsPreferences current, double volume) async {
    final updated = current.copyWith(soundVolume: volume);
    return savePreferences(updated);
  }

  Future<bool> setAnimationsEnabled(
    KdsPreferences current,
    bool enabled,
  ) async {
    final updated = current.copyWith(animationsEnabled: enabled);
    return savePreferences(updated);
  }

  Future<bool> setTimerThresholds(
    KdsPreferences current,
    int normal,
    int warning,
  ) async {
    final updated = current.copyWith(
      normalThresholdMinutes: normal,
      warningThresholdMinutes: warning,
    );
    return savePreferences(updated);
  }

  Future<bool> setGridColumns(KdsPreferences current, int columns) async {
    final updated = current.copyWith(gridColumns: columns);
    return savePreferences(updated);
  }

  Future<bool> setDarkMode(KdsPreferences current, bool enabled) async {
    final updated = current.copyWith(
      darkMode: enabled,
      useSystemTheme: false,
    );
    return savePreferences(updated);
  }

  /// Dispose resources
  void dispose() {
    _prefsController.close();
  }
}

/// Preferences State Notifier
/// Manages preferences state with Riverpod
class PreferencesNotifier extends StateNotifier<KdsPreferences> {
  final KdsPreferencesService _service;
  StreamSubscription<KdsPreferences>? _subscription;

  PreferencesNotifier(this._service) : super(KdsPreferences.defaults()) {
    _loadPreferences();
    _subscription = _service.preferencesStream.listen((prefs) {
      state = prefs;
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await _service.loadPreferences();
    state = prefs;
  }

  /// Update preferences
  Future<bool> update(KdsPreferences preferences) async {
    final success = await _service.savePreferences(preferences);
    if (success) {
      state = preferences;
    }
    return success;
  }

  /// Quick update methods

  Future<void> setSelectedStation(String stationId) async {
    await _service.setSelectedStation(state, stationId);
  }

  Future<void> setViewMode(KdsViewMode mode) async {
    await _service.setViewMode(state, mode);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _service.setSoundEnabled(state, enabled);
  }

  Future<void> setSoundVolume(double volume) async {
    await _service.setSoundVolume(state, volume);
  }

  Future<void> setAnimationsEnabled(bool enabled) async {
    await _service.setAnimationsEnabled(state, enabled);
  }

  Future<void> setTimerThresholds(int normal, int warning) async {
    await _service.setTimerThresholds(state, normal, warning);
  }

  Future<void> setGridColumns(int columns) async {
    await _service.setGridColumns(state, columns);
  }

  Future<void> setDarkMode(bool enabled) async {
    await _service.setDarkMode(state, enabled);
  }

  /// Reset to defaults
  Future<void> reset() async {
    await _service.resetPreferences();
    state = KdsPreferences.defaults();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
