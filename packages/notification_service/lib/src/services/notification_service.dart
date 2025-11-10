import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/notification_model.dart';
import 'push_notification_service.dart';
import 'sms_notification_service.dart';
import 'email_notification_service.dart';

/// Core notification service that coordinates all notification channels
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final PushNotificationService _pushService = PushNotificationService();
  final SMSNotificationService _smsService = SMSNotificationService();
  final EmailNotificationService _emailService = EmailNotificationService();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final StreamController<AppNotification> _notificationStreamController =
      StreamController<AppNotification>.broadcast();

  final List<AppNotification> _notifications = [];
  bool _isInitialized = false;

  /// Stream of incoming notifications
  Stream<AppNotification> get notificationStream =>
      _notificationStreamController.stream;

  /// Get all cached notifications
  List<AppNotification> get notifications => List.unmodifiable(_notifications);

  /// Get unread count
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize push notifications (FCM)
      await _pushService.initialize();

      // Load cached notifications
      await _loadCachedNotifications();

      // Listen to FCM messages
      _setupFCMListeners();

      _isInitialized = true;
      debugPrint('NotificationService initialized successfully');
    } catch (e) {
      debugPrint('Error initializing NotificationService: $e');
      rethrow;
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null) {
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final notification = AppNotification.fromJson(data);

        // Mark as read
        markAsRead(notification.id);

        // Emit to stream for app to handle
        _notificationStreamController.add(notification);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Setup FCM message listeners
  void _setupFCMListeners() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleRemoteMessage(message, showLocal: true);
    });

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleRemoteMessage(message, showLocal: false);
    });
  }

  /// Handle incoming FCM message
  void _handleRemoteMessage(RemoteMessage message, {bool showLocal = false}) {
    try {
      final notification = _parseRemoteMessage(message);

      // Add to cache
      _notifications.insert(0, notification);
      _saveCachedNotifications();

      // Show local notification if in foreground
      if (showLocal) {
        _showLocalNotification(notification);
      }

      // Emit to stream
      _notificationStreamController.add(notification);
    } catch (e) {
      debugPrint('Error handling remote message: $e');
    }
  }

  /// Parse FCM message to AppNotification
  AppNotification _parseRemoteMessage(RemoteMessage message) {
    return AppNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      type: _parseNotificationType(message.data['type']),
      priority: _parseNotificationPriority(message.data['priority']),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? '',
      data: message.data,
      imageUrl: message.notification?.android?.imageUrl,
      actionUrl: message.data['actionUrl'],
      userId: message.data['userId'],
      groupId: message.data['groupId'],
      createdAt: DateTime.now(),
      channels: [NotificationChannel.push],
    );
  }

  /// Show local notification
  Future<void> _showLocalNotification(AppNotification notification) async {
    const androidDetails = AndroidNotificationDetails(
      'smartpos_channel',
      'SmartPOS Notifications',
      channelDescription: 'Notifications for SmartPOS operations',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.id.hashCode,
      notification.title,
      notification.body,
      details,
      payload: jsonEncode(notification.toJson()),
    );
  }

  /// Send notification through specified channels
  Future<Map<NotificationChannel, bool>> sendNotification(
    AppNotification notification,
    NotificationPreferences? preferences,
  ) async {
    final results = <NotificationChannel, bool>{};

    for (final channel in notification.channels) {
      // Check user preferences
      if (preferences != null &&
          !preferences.shouldReceive(notification.type, channel)) {
        results[channel] = false;
        continue;
      }

      // Check do-not-disturb
      if (preferences?.isInDoNotDisturb() == true &&
          notification.priority != NotificationPriority.urgent) {
        results[channel] = false;
        continue;
      }

      // Send through appropriate channel
      bool success = false;
      try {
        switch (channel) {
          case NotificationChannel.push:
            success = await _pushService.sendPushNotification(notification);
            break;
          case NotificationChannel.sms:
            success = await _smsService.sendSMS(notification);
            break;
          case NotificationChannel.email:
            success = await _emailService.sendEmail(notification);
            break;
          case NotificationChannel.inApp:
            success = await _sendInAppNotification(notification);
            break;
        }
      } catch (e) {
        debugPrint('Error sending notification via $channel: $e');
        success = false;
      }

      results[channel] = success;
    }

    return results;
  }

  /// Send in-app notification
  Future<bool> _sendInAppNotification(AppNotification notification) async {
    try {
      // Add to local cache
      _notifications.insert(0, notification);
      await _saveCachedNotifications();

      // Show local notification
      await _showLocalNotification(notification);

      // Emit to stream
      _notificationStreamController.add(notification);

      return true;
    } catch (e) {
      debugPrint('Error sending in-app notification: $e');
      return false;
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveCachedNotifications();
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    await _saveCachedNotifications();
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    _notifications.removeWhere((n) => n.id == notificationId);
    await _saveCachedNotifications();
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    _notifications.clear();
    await _saveCachedNotifications();
    await _localNotifications.cancelAll();
  }

  /// Get FCM token
  Future<String?> getFCMToken() async {
    return await _pushService.getFCMToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  /// Load cached notifications from storage
  Future<void> _loadCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('cached_notifications');

      if (cached != null) {
        final List<dynamic> jsonList = jsonDecode(cached);
        _notifications.clear();
        _notifications.addAll(
          jsonList.map((json) => AppNotification.fromJson(json)).toList(),
        );
      }
    } catch (e) {
      debugPrint('Error loading cached notifications: $e');
    }
  }

  /// Save notifications to cache
  Future<void> _saveCachedNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Keep only last 100 notifications
      final toSave = _notifications.take(100).toList();
      final jsonList = toSave.map((n) => n.toJson()).toList();

      await prefs.setString('cached_notifications', jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Error saving cached notifications: $e');
    }
  }

  /// Parse notification type from string
  NotificationType _parseNotificationType(String? type) {
    if (type == null) return NotificationType.system;

    try {
      return NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == type,
        orElse: () => NotificationType.system,
      );
    } catch (e) {
      return NotificationType.system;
    }
  }

  /// Parse notification priority from string
  NotificationPriority _parseNotificationPriority(String? priority) {
    if (priority == null) return NotificationPriority.normal;

    try {
      return NotificationPriority.values.firstWhere(
        (e) => e.toString().split('.').last == priority,
        orElse: () => NotificationPriority.normal,
      );
    } catch (e) {
      return NotificationPriority.normal;
    }
  }

  /// Dispose resources
  void dispose() {
    _notificationStreamController.close();
  }
}
