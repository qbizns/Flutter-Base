/// Sound Notification Service
/// Audio alerts for KDS following Odoo patterns
library;

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kitchen_order.dart';

/// Sound types for different events
enum KdsSoundType {
  newOrder,
  urgentOrder,
  orderReady,
  orderDelayed,
  itemCompleted,
}

/// Sound notification settings
class SoundSettings {
  final bool enabled;
  final double volume;
  final bool playForNormalOrders;
  final bool playForHighOrders;
  final bool playForUrgentOrders;
  final bool playForDelayed;
  final bool playForReady;

  const SoundSettings({
    this.enabled = true,
    this.volume = 0.7,
    this.playForNormalOrders = true,
    this.playForHighOrders = true,
    this.playForUrgentOrders = true,
    this.playForDelayed = true,
    this.playForReady = false,
  });

  SoundSettings copyWith({
    bool? enabled,
    double? volume,
    bool? playForNormalOrders,
    bool? playForHighOrders,
    bool? playForUrgentOrders,
    bool? playForDelayed,
    bool? playForReady,
  }) {
    return SoundSettings(
      enabled: enabled ?? this.enabled,
      volume: volume ?? this.volume,
      playForNormalOrders: playForNormalOrders ?? this.playForNormalOrders,
      playForHighOrders: playForHighOrders ?? this.playForHighOrders,
      playForUrgentOrders: playForUrgentOrders ?? this.playForUrgentOrders,
      playForDelayed: playForDelayed ?? this.playForDelayed,
      playForReady: playForReady ?? this.playForReady,
    );
  }
}

/// Sound Notification Service
/// Plays audio alerts for kitchen events following Odoo KDS patterns
class SoundNotificationService {
  final Map<KdsSoundType, AudioPlayer> _players = {};
  SoundSettings _settings = const SoundSettings();

  SoundSettings get settings => _settings;

  /// Initialize audio players
  Future<void> initialize() async {
    // Create audio players for each sound type
    for (final soundType in KdsSoundType.values) {
      _players[soundType] = AudioPlayer();
    }

    // Preload sound files (in production, these would be actual audio files)
    // For now, we'll use system sounds or generate tones
  }

  /// Update settings
  void updateSettings(SoundSettings settings) {
    _settings = settings;

    // Update volume for all players
    for (final player in _players.values) {
      player.setVolume(settings.volume);
    }
  }

  /// Play sound for new order
  Future<void> playNewOrder(KitchenOrder order) async {
    if (!_settings.enabled) return;

    // Check if we should play based on priority
    final shouldPlay = switch (order.priority) {
      OrderPriority.normal => _settings.playForNormalOrders,
      OrderPriority.high => _settings.playForHighOrders,
      OrderPriority.urgent => _settings.playForUrgentOrders,
    };

    if (!shouldPlay) return;

    // Play appropriate sound based on priority
    final soundType = order.isUrgent || order.priority == OrderPriority.urgent
        ? KdsSoundType.urgentOrder
        : KdsSoundType.newOrder;

    await _playSound(soundType);
  }

  /// Play sound for order ready
  Future<void> playOrderReady() async {
    if (!_settings.enabled || !_settings.playForReady) return;
    await _playSound(KdsSoundType.orderReady);
  }

  /// Play sound for delayed order
  Future<void> playOrderDelayed() async {
    if (!_settings.enabled || !_settings.playForDelayed) return;
    await _playSound(KdsSoundType.orderDelayed);
  }

  /// Play sound for item completed
  Future<void> playItemCompleted() async {
    if (!_settings.enabled) return;
    await _playSound(KdsSoundType.itemCompleted);
  }

  /// Play specific sound
  Future<void> _playSound(KdsSoundType soundType) async {
    final player = _players[soundType];
    if (player == null) return;

    try {
      // Stop any currently playing sound of this type
      await player.stop();

      // In production, play actual audio files:
      // await player.play(AssetSource('sounds/${soundType.fileName}'));

      // For development, use system beep or generate tone
      // Using a short beep sound (platform-dependent)
      await _playBeep(soundType);
    } catch (e) {
      // Handle audio playback error
    }
  }

  /// Play beep sound (development fallback)
  Future<void> _playBeep(KdsSoundType soundType) async {
    final player = _players[soundType];
    if (player == null) return;

    // Generate different beep patterns for different sound types
    final pattern = switch (soundType) {
      KdsSoundType.newOrder => 1, // Single beep
      KdsSoundType.urgentOrder => 3, // Triple beep
      KdsSoundType.orderReady => 2, // Double beep
      KdsSoundType.orderDelayed => 2, // Double beep (warning tone)
      KdsSoundType.itemCompleted => 1, // Single short beep
    };

    // In production, load actual sound files here
    // For now, this is a placeholder
    // await player.play(AssetSource('sounds/beep.mp3'));
  }

  /// Dispose resources
  Future<void> dispose() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}

/// Sound notification service provider
final soundNotificationServiceProvider = Provider<SoundNotificationService>((ref) {
  final service = SoundNotificationService();

  // Initialize on first access
  service.initialize();

  // Dispose when provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
});

/// Sound settings provider
final soundSettingsProvider = StateProvider<SoundSettings>((ref) {
  return const SoundSettings();
});

/// Sound settings notifier
class SoundSettingsNotifier extends StateNotifier<SoundSettings> {
  final SoundNotificationService _service;

  SoundSettingsNotifier(this._service) : super(const SoundSettings()) {
    _service.updateSettings(state);
  }

  void updateSettings(SoundSettings settings) {
    state = settings;
    _service.updateSettings(settings);
  }

  void setEnabled(bool enabled) {
    updateSettings(state.copyWith(enabled: enabled));
  }

  void setVolume(double volume) {
    updateSettings(state.copyWith(volume: volume));
  }

  void setPlayForNormalOrders(bool play) {
    updateSettings(state.copyWith(playForNormalOrders: play));
  }

  void setPlayForHighOrders(bool play) {
    updateSettings(state.copyWith(playForHighOrders: play));
  }

  void setPlayForUrgentOrders(bool play) {
    updateSettings(state.copyWith(playForUrgentOrders: play));
  }

  void setPlayForDelayed(bool play) {
    updateSettings(state.copyWith(playForDelayed: play));
  }

  void setPlayForReady(bool play) {
    updateSettings(state.copyWith(playForReady: play));
  }
}

/// Sound settings notifier provider
final soundSettingsNotifierProvider =
    StateNotifierProvider<SoundSettingsNotifier, SoundSettings>((ref) {
  final service = ref.watch(soundNotificationServiceProvider);
  return SoundSettingsNotifier(service);
});
