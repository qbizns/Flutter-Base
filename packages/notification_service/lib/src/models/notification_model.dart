import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

/// Notification model representing a single notification
@JsonSerializable()
class AppNotification {
  final String id;
  final NotificationType type;
  final NotificationPriority priority;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String? imageUrl;
  final String? actionUrl;
  final String? userId;
  final String? groupId;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final DateTime? expiresAt;
  final bool isRead;
  final bool isSent;
  final List<NotificationChannel> channels;

  AppNotification({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.body,
    this.data,
    this.imageUrl,
    this.actionUrl,
    this.userId,
    this.groupId,
    required this.createdAt,
    this.scheduledFor,
    this.expiresAt,
    this.isRead = false,
    this.isSent = false,
    required this.channels,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  Map<String, dynamic> toJson() => _$AppNotificationToJson(this);

  AppNotification copyWith({
    String? id,
    NotificationType? type,
    NotificationPriority? priority,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    String? imageUrl,
    String? actionUrl,
    String? userId,
    String? groupId,
    DateTime? createdAt,
    DateTime? scheduledFor,
    DateTime? expiresAt,
    bool? isRead,
    bool? isSent,
    List<NotificationChannel>? channels,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      userId: userId ?? this.userId,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
      scheduledFor: scheduledFor ?? this.scheduledFor,
      expiresAt: expiresAt ?? this.expiresAt,
      isRead: isRead ?? this.isRead,
      isSent: isSent ?? this.isSent,
      channels: channels ?? this.channels,
    );
  }
}

/// Notification types categorizing different kinds of notifications
enum NotificationType {
  @JsonValue('order')
  order,
  @JsonValue('kitchen')
  kitchen,
  @JsonValue('delivery')
  delivery,
  @JsonValue('reservation')
  reservation,
  @JsonValue('inventory')
  inventory,
  @JsonValue('staff')
  staff,
  @JsonValue('customer')
  customer,
  @JsonValue('payment')
  payment,
  @JsonValue('loyalty')
  loyalty,
  @JsonValue('marketing')
  marketing,
  @JsonValue('system')
  system,
  @JsonValue('alert')
  alert,
}

/// Notification priority levels
enum NotificationPriority {
  @JsonValue('low')
  low,
  @JsonValue('normal')
  normal,
  @JsonValue('high')
  high,
  @JsonValue('urgent')
  urgent,
}

/// Delivery channels for notifications
enum NotificationChannel {
  @JsonValue('push')
  push,
  @JsonValue('sms')
  sms,
  @JsonValue('email')
  email,
  @JsonValue('inApp')
  inApp,
}

/// Notification template for predefined message structures
@JsonSerializable()
class NotificationTemplate {
  final String id;
  final String name;
  final NotificationType type;
  final String titleTemplate;
  final String bodyTemplate;
  final Map<String, dynamic>? defaultData;
  final List<NotificationChannel> defaultChannels;
  final bool isActive;

  NotificationTemplate({
    required this.id,
    required this.name,
    required this.type,
    required this.titleTemplate,
    required this.bodyTemplate,
    this.defaultData,
    required this.defaultChannels,
    this.isActive = true,
  });

  factory NotificationTemplate.fromJson(Map<String, dynamic> json) =>
      _$NotificationTemplateFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationTemplateToJson(this);

  /// Render template with variables
  AppNotification render(Map<String, String> variables, String userId) {
    String title = titleTemplate;
    String body = bodyTemplate;

    // Replace variables in templates
    variables.forEach((key, value) {
      title = title.replaceAll('{$key}', value);
      body = body.replaceAll('{$key}', value);
    });

    return AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      priority: NotificationPriority.normal,
      title: title,
      body: body,
      data: defaultData,
      userId: userId,
      createdAt: DateTime.now(),
      channels: defaultChannels,
    );
  }
}

/// Notification preferences for users
@JsonSerializable()
class NotificationPreferences {
  final String userId;
  final bool enablePush;
  final bool enableSMS;
  final bool enableEmail;
  final Map<NotificationType, bool> typePreferences;
  final List<String> mutedGroups;
  final DateTime? doNotDisturbStart;
  final DateTime? doNotDisturbEnd;
  final DateTime updatedAt;

  NotificationPreferences({
    required this.userId,
    this.enablePush = true,
    this.enableSMS = true,
    this.enableEmail = true,
    required this.typePreferences,
    this.mutedGroups = const [],
    this.doNotDisturbStart,
    this.doNotDisturbEnd,
    required this.updatedAt,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationPreferencesToJson(this);

  /// Check if user wants to receive notifications for a specific type and channel
  bool shouldReceive(NotificationType type, NotificationChannel channel) {
    // Check if type is enabled
    if (typePreferences[type] == false) return false;

    // Check channel preference
    switch (channel) {
      case NotificationChannel.push:
        return enablePush;
      case NotificationChannel.sms:
        return enableSMS;
      case NotificationChannel.email:
        return enableEmail;
      case NotificationChannel.inApp:
        return true; // Always allow in-app
    }
  }

  /// Check if currently in do-not-disturb period
  bool isInDoNotDisturb() {
    if (doNotDisturbStart == null || doNotDisturbEnd == null) return false;

    final now = DateTime.now();
    final start = doNotDisturbStart!;
    final end = doNotDisturbEnd!;

    // Handle same-day period
    if (start.hour < end.hour ||
        (start.hour == end.hour && start.minute < end.minute)) {
      final currentTime = now.hour * 60 + now.minute;
      final startTime = start.hour * 60 + start.minute;
      final endTime = end.hour * 60 + end.minute;
      return currentTime >= startTime && currentTime <= endTime;
    }

    // Handle overnight period (e.g., 10 PM to 8 AM)
    final currentTime = now.hour * 60 + now.minute;
    final startTime = start.hour * 60 + start.minute;
    final endTime = end.hour * 60 + end.minute;
    return currentTime >= startTime || currentTime <= endTime;
  }
}

/// Notification statistics
@JsonSerializable()
class NotificationStats {
  final int totalSent;
  final int totalDelivered;
  final int totalRead;
  final int totalFailed;
  final Map<NotificationChannel, int> byChannel;
  final Map<NotificationType, int> byType;
  final DateTime periodStart;
  final DateTime periodEnd;

  NotificationStats({
    required this.totalSent,
    required this.totalDelivered,
    required this.totalRead,
    required this.totalFailed,
    required this.byChannel,
    required this.byType,
    required this.periodStart,
    required this.periodEnd,
  });

  factory NotificationStats.fromJson(Map<String, dynamic> json) =>
      _$NotificationStatsFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationStatsToJson(this);

  double get deliveryRate =>
      totalSent > 0 ? (totalDelivered / totalSent) * 100 : 0;

  double get readRate =>
      totalDelivered > 0 ? (totalRead / totalDelivered) * 100 : 0;
}
