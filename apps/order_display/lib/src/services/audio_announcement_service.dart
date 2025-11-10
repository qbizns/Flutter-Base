import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio Announcement Service
///
/// Provides audio notifications for order status changes.
/// Features:
/// - Text-to-speech announcements (simulated)
/// - Volume control
/// - Enable/disable audio
/// - Multiple announcement types
class AudioAnnouncementService {
  final AudioPlayer _player = AudioPlayer();
  bool _isEnabled = true;
  double _volume = 0.8;

  bool get isEnabled => _isEnabled;
  double get volume => _volume;

  /// Enable or disable audio announcements
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    debugPrint('🔊 Audio announcements ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Set volume (0.0 to 1.0)
  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    _player.setVolume(_volume);
    debugPrint('🔊 Audio volume set to ${(_volume * 100).toInt()}%');
  }

  /// Announce that an order is now ready
  Future<void> announceOrderReady(String orderNumber, {String? language}) async {
    if (!_isEnabled) return;

    debugPrint('🔔 Announcing: Order $orderNumber is ready');

    // In a real app, this would use text-to-speech or play pre-recorded audio
    // For now, we'll simulate the announcement
    await _simulateAnnouncement(
      _getReadyMessage(orderNumber, language ?? 'en'),
    );
  }

  /// Announce now serving
  Future<void> announceNowServing(String orderNumber, {String? language}) async {
    if (!_isEnabled) return;

    debugPrint('📢 Announcing: Now serving order $orderNumber');

    await _simulateAnnouncement(
      _getNowServingMessage(orderNumber, language ?? 'en'),
    );
  }

  /// Announce multiple orders ready
  Future<void> announceMultipleOrdersReady(List<String> orderNumbers, {String? language}) async {
    if (!_isEnabled) return;

    debugPrint('🔔 Announcing: ${orderNumbers.length} orders ready');

    for (final orderNumber in orderNumbers) {
      await announceOrderReady(orderNumber, language: language);
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  /// Play attention sound (bell/chime)
  Future<void> playAttentionSound() async {
    if (!_isEnabled) return;

    debugPrint('🔔 Playing attention sound');

    // In a real app, this would play an actual sound file
    // await _player.play(AssetSource('sounds/bell.mp3'));

    // Simulate sound playback
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Simulate announcement (replace with actual TTS or audio playback)
  Future<void> _simulateAnnouncement(String message) async {
    // In a real implementation, this would:
    // 1. Use flutter_tts package for text-to-speech
    // 2. Or play pre-recorded audio files
    // 3. Or send to external announcement system

    debugPrint('🎙️ Announcement: $message');

    // Simulate announcement duration based on message length
    final duration = Duration(milliseconds: message.length * 50);
    await Future.delayed(duration);
  }

  String _getReadyMessage(String orderNumber, String language) {
    switch (language) {
      case 'es':
        return 'Pedido número $orderNumber está listo';
      case 'ar':
        return 'الطلب رقم $orderNumber جاهز';
      case 'fr':
        return 'Commande numéro $orderNumber est prête';
      case 'zh':
        return '订单号 $orderNumber 已准备好';
      default:
        return 'Order number $orderNumber is ready';
    }
  }

  String _getNowServingMessage(String orderNumber, String language) {
    switch (language) {
      case 'es':
        return 'Ahora sirviendo orden número $orderNumber';
      case 'ar':
        return 'نقدم الآن الطلب رقم $orderNumber';
      case 'fr':
        return 'Maintenant en service commande numéro $orderNumber';
      case 'zh':
        return '现在服务订单号 $orderNumber';
      default:
        return 'Now serving order number $orderNumber';
    }
  }

  /// Dispose resources
  void dispose() {
    _player.dispose();
  }
}

// Global instance
final audioAnnouncementService = AudioAnnouncementService();
