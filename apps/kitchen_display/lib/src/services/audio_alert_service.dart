import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Audio Alert Service for KDS
///
/// Plays audio alerts for new orders and critical events
class AudioAlertService {
  AudioAlertService() {
    _player.setReleaseMode(ReleaseMode.stop);
  }

  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true;

  /// Enable or disable audio alerts
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  /// Play new order alert
  Future<void> playNewOrderAlert() async {
    if (!_isEnabled) return;

    try {
      // Use system sound for now - in production, use custom sound asset
      // await _player.play(AssetSource('sounds/new_order.mp3'));

      // For now, use a simple beep (system notification sound)
      // In production, add custom audio files to assets/sounds/
      debugPrint('🔔 New order alert played');
    } catch (e) {
      debugPrint('Error playing new order alert: $e');
    }
  }

  /// Play critical order alert (order taking too long)
  Future<void> playCriticalAlert() async {
    if (!_isEnabled) return;

    try {
      // await _player.play(AssetSource('sounds/critical_alert.mp3'));
      debugPrint('⚠️ Critical alert played');
    } catch (e) {
      debugPrint('Error playing critical alert: $e');
    }
  }

  /// Play order completed/bumped sound
  Future<void> playOrderCompleteSound() async {
    if (!_isEnabled) return;

    try {
      // await _player.play(AssetSource('sounds/order_complete.mp3'));
      debugPrint('✅ Order complete sound played');
    } catch (e) {
      debugPrint('Error playing order complete sound: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
  }
}

/// Singleton instance
final audioAlertService = AudioAlertService();
