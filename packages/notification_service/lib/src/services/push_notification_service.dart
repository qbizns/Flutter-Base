import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/notification_model.dart';

/// Service for handling push notifications via Firebase Cloud Messaging
class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  String? _fcmToken;

  /// Initialize push notification service
  Future<void> initialize() async {
    try {
      // Request permission for iOS
      final settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('Push notification permission granted');

        // Get FCM token
        _fcmToken = await _fcm.getToken();
        debugPrint('FCM Token: $_fcmToken');

        // Listen for token refresh
        _fcm.onTokenRefresh.listen((newToken) {
          _fcmToken = newToken;
          debugPrint('FCM Token refreshed: $newToken');
          // TODO: Send new token to backend
        });
      } else {
        debugPrint('Push notification permission denied');
      }
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getFCMToken() async {
    if (_fcmToken == null) {
      _fcmToken = await _fcm.getToken();
    }
    return _fcmToken;
  }

  /// Send push notification via FCM (requires backend API)
  Future<bool> sendPushNotification(AppNotification notification) async {
    try {
      // This should be called from backend, not client-side
      // Keeping this as a placeholder for backend integration

      // For testing, we can use FCM REST API
      // In production, this should be done from your backend server

      debugPrint('Push notification queued: ${notification.title}');

      // TODO: Call backend API to send push notification
      // Example:
      // final response = await http.post(
      //   Uri.parse('YOUR_BACKEND_API/notifications/push'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: jsonEncode({
      //     'token': await getFCMToken(),
      //     'notification': notification.toJson(),
      //   }),
      // );
      //
      // return response.statusCode == 200;

      return true;
    } catch (e) {
      debugPrint('Error sending push notification: $e');
      return false;
    }
  }

  /// Send push notification to specific token
  Future<bool> sendToToken({
    required String token,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // This should be done from backend using Firebase Admin SDK
      // Example payload for backend:
      final payload = {
        'token': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': data ?? {},
        'android': {
          'priority': 'high',
          'notification': {
            'sound': 'default',
            'channelId': 'smartpos_channel',
          },
        },
        'apns': {
          'payload': {
            'aps': {
              'sound': 'default',
              'badge': 1,
            },
          },
        },
      };

      debugPrint('Push notification payload prepared: $payload');

      // TODO: Send to backend
      return true;
    } catch (e) {
      debugPrint('Error sending push to token: $e');
      return false;
    }
  }

  /// Send push notification to topic
  Future<bool> sendToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    try {
      // This should be done from backend using Firebase Admin SDK
      debugPrint('Push notification to topic "$topic" queued');

      // TODO: Call backend API
      return true;
    } catch (e) {
      debugPrint('Error sending push to topic: $e');
      return false;
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await _fcm.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _fcm.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    await _fcm.deleteToken();
    _fcmToken = null;
    debugPrint('FCM token deleted');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
  // Handle background message
  // Note: You can't update UI here, only perform background tasks
}
