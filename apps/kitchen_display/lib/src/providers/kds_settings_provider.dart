import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// KDS Settings Model
class KdsSettings {
  const KdsSettings({
    this.audioAlertsEnabled = true,
    this.autoRefreshEnabled = true,
    this.showTimerWarnings = true,
    this.warningTimeMinutes = 10,
    this.criticalTimeMinutes = 15,
    this.refreshIntervalSeconds = 5,
    this.selectedStationId,
  });

  final bool audioAlertsEnabled;
  final bool autoRefreshEnabled;
  final bool showTimerWarnings;
  final int warningTimeMinutes;
  final int criticalTimeMinutes;
  final int refreshIntervalSeconds;
  final String? selectedStationId;

  KdsSettings copyWith({
    bool? audioAlertsEnabled,
    bool? autoRefreshEnabled,
    bool? showTimerWarnings,
    int? warningTimeMinutes,
    int? criticalTimeMinutes,
    int? refreshIntervalSeconds,
    String? selectedStationId,
  }) {
    return KdsSettings(
      audioAlertsEnabled: audioAlertsEnabled ?? this.audioAlertsEnabled,
      autoRefreshEnabled: autoRefreshEnabled ?? this.autoRefreshEnabled,
      showTimerWarnings: showTimerWarnings ?? this.showTimerWarnings,
      warningTimeMinutes: warningTimeMinutes ?? this.warningTimeMinutes,
      criticalTimeMinutes: criticalTimeMinutes ?? this.criticalTimeMinutes,
      refreshIntervalSeconds: refreshIntervalSeconds ?? this.refreshIntervalSeconds,
      selectedStationId: selectedStationId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'audioAlertsEnabled': audioAlertsEnabled,
      'autoRefreshEnabled': autoRefreshEnabled,
      'showTimerWarnings': showTimerWarnings,
      'warningTimeMinutes': warningTimeMinutes,
      'criticalTimeMinutes': criticalTimeMinutes,
      'refreshIntervalSeconds': refreshIntervalSeconds,
      'selectedStationId': selectedStationId,
    };
  }

  factory KdsSettings.fromJson(Map<String, dynamic> json) {
    return KdsSettings(
      audioAlertsEnabled: json['audioAlertsEnabled'] as bool? ?? true,
      autoRefreshEnabled: json['autoRefreshEnabled'] as bool? ?? true,
      showTimerWarnings: json['showTimerWarnings'] as bool? ?? true,
      warningTimeMinutes: json['warningTimeMinutes'] as int? ?? 10,
      criticalTimeMinutes: json['criticalTimeMinutes'] as int? ?? 15,
      refreshIntervalSeconds: json['refreshIntervalSeconds'] as int? ?? 5,
      selectedStationId: json['selectedStationId'] as String?,
    );
  }
}

/// KDS Settings Provider
class KdsSettingsNotifier extends StateNotifier<KdsSettings> {
  KdsSettingsNotifier() : super(const KdsSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('kds_settings');
      if (jsonString != null) {
        // In a real app, parse JSON here
        // For now, just use defaults
      }
    } catch (e) {
      debugPrint('Error loading KDS settings: $e');
    }
  }

  Future<void> updateAudioAlerts(bool enabled) async {
    state = state.copyWith(audioAlertsEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateAutoRefresh(bool enabled) async {
    state = state.copyWith(autoRefreshEnabled: enabled);
    await _saveSettings();
  }

  Future<void> updateWarningTime(int minutes) async {
    state = state.copyWith(warningTimeMinutes: minutes);
    await _saveSettings();
  }

  Future<void> updateCriticalTime(int minutes) async {
    state = state.copyWith(criticalTimeMinutes: minutes);
    await _saveSettings();
  }

  Future<void> updateRefreshInterval(int seconds) async {
    state = state.copyWith(refreshIntervalSeconds: seconds);
    await _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // In a real app, save JSON here
      await prefs.setString('kds_settings', ''); // Placeholder
    } catch (e) {
      debugPrint('Error saving KDS settings: $e');
    }
  }
}

final kdsSettingsProvider = StateNotifierProvider<KdsSettingsNotifier, KdsSettings>((ref) {
  return KdsSettingsNotifier();
});
