import 'package:flutter/material.dart';

/// Theme mode for appearance settings
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Business Hours for a specific day
class BusinessHours {
  final bool isOpen;
  final TimeOfDay? openTime;
  final TimeOfDay? closeTime;

  const BusinessHours({
    required this.isOpen,
    this.openTime,
    this.closeTime,
  });

  BusinessHours copyWith({
    bool? isOpen,
    TimeOfDay? openTime,
    TimeOfDay? closeTime,
  }) {
    return BusinessHours(
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_open': isOpen,
      'open_time': openTime != null ? '${openTime!.hour}:${openTime!.minute}' : null,
      'close_time': closeTime != null ? '${closeTime!.hour}:${closeTime!.minute}' : null,
    };
  }

  factory BusinessHours.fromJson(Map<String, dynamic> json) {
    TimeOfDay? parseTime(String? timeStr) {
      if (timeStr == null) return null;
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }

    return BusinessHours(
      isOpen: json['is_open'] as bool? ?? false,
      openTime: parseTime(json['open_time'] as String?),
      closeTime: parseTime(json['close_time'] as String?),
    );
  }

  static BusinessHours defaultHours() {
    return const BusinessHours(
      isOpen: true,
      openTime: TimeOfDay(hour: 9, minute: 0),
      closeTime: TimeOfDay(hour: 22, minute: 0),
    );
  }

  static BusinessHours closed() {
    return const BusinessHours(isOpen: false);
  }
}

/// Tax rate configuration
class TaxRate {
  final String id;
  final String name;
  final double rate;
  final bool isDefault;

  const TaxRate({
    required this.id,
    required this.name,
    required this.rate,
    this.isDefault = false,
  });

  TaxRate copyWith({
    String? id,
    String? name,
    double? rate,
    bool? isDefault,
  }) {
    return TaxRate(
      id: id ?? this.id,
      name: name ?? this.name,
      rate: rate ?? this.rate,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rate': rate,
      'is_default': isDefault,
    };
  }

  factory TaxRate.fromJson(Map<String, dynamic> json) {
    return TaxRate(
      id: json['id'] as String,
      name: json['name'] as String,
      rate: (json['rate'] as num).toDouble(),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}

/// Tax Settings configuration
class TaxSettings {
  final double defaultTaxRate;
  final bool taxInclusive;
  final List<TaxRate> taxRates;

  const TaxSettings({
    this.defaultTaxRate = 0.0,
    this.taxInclusive = false,
    this.taxRates = const [],
  });

  TaxSettings copyWith({
    double? defaultTaxRate,
    bool? taxInclusive,
    List<TaxRate>? taxRates,
  }) {
    return TaxSettings(
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      taxInclusive: taxInclusive ?? this.taxInclusive,
      taxRates: taxRates ?? this.taxRates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'default_tax_rate': defaultTaxRate,
      'tax_inclusive': taxInclusive,
      'tax_rates': taxRates.map((t) => t.toJson()).toList(),
    };
  }

  factory TaxSettings.fromJson(Map<String, dynamic> json) {
    return TaxSettings(
      defaultTaxRate: (json['default_tax_rate'] as num?)?.toDouble() ?? 0.0,
      taxInclusive: json['tax_inclusive'] as bool? ?? false,
      taxRates: (json['tax_rates'] as List?)
              ?.map((t) => TaxRate.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Receipt Settings configuration
class ReceiptSettings {
  final String headerText;
  final String footerText;
  final bool showLogo;
  final bool autoPrint;
  final int numberOfCopies;
  final bool showQRCode;

  const ReceiptSettings({
    this.headerText = '',
    this.footerText = '',
    this.showLogo = true,
    this.autoPrint = false,
    this.numberOfCopies = 1,
    this.showQRCode = false,
  });

  ReceiptSettings copyWith({
    String? headerText,
    String? footerText,
    bool? showLogo,
    bool? autoPrint,
    int? numberOfCopies,
    bool? showQRCode,
  }) {
    return ReceiptSettings(
      headerText: headerText ?? this.headerText,
      footerText: footerText ?? this.footerText,
      showLogo: showLogo ?? this.showLogo,
      autoPrint: autoPrint ?? this.autoPrint,
      numberOfCopies: numberOfCopies ?? this.numberOfCopies,
      showQRCode: showQRCode ?? this.showQRCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'header_text': headerText,
      'footer_text': footerText,
      'show_logo': showLogo,
      'auto_print': autoPrint,
      'number_of_copies': numberOfCopies,
      'show_qr_code': showQRCode,
    };
  }

  factory ReceiptSettings.fromJson(Map<String, dynamic> json) {
    return ReceiptSettings(
      headerText: json['header_text'] as String? ?? '',
      footerText: json['footer_text'] as String? ?? '',
      showLogo: json['show_logo'] as bool? ?? true,
      autoPrint: json['auto_print'] as bool? ?? false,
      numberOfCopies: json['number_of_copies'] as int? ?? 1,
      showQRCode: json['show_qr_code'] as bool? ?? false,
    );
  }
}

/// Notification Settings configuration
class NotificationSettings {
  final bool pushNotificationsEnabled;
  final bool soundEnabled;
  final bool emailNotificationsEnabled;
  final bool newOrderNotifications;
  final bool lowStockNotifications;
  final bool dailyReportNotifications;

  const NotificationSettings({
    this.pushNotificationsEnabled = true,
    this.soundEnabled = true,
    this.emailNotificationsEnabled = false,
    this.newOrderNotifications = true,
    this.lowStockNotifications = true,
    this.dailyReportNotifications = false,
  });

  NotificationSettings copyWith({
    bool? pushNotificationsEnabled,
    bool? soundEnabled,
    bool? emailNotificationsEnabled,
    bool? newOrderNotifications,
    bool? lowStockNotifications,
    bool? dailyReportNotifications,
  }) {
    return NotificationSettings(
      pushNotificationsEnabled: pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled ?? this.emailNotificationsEnabled,
      newOrderNotifications: newOrderNotifications ?? this.newOrderNotifications,
      lowStockNotifications: lowStockNotifications ?? this.lowStockNotifications,
      dailyReportNotifications: dailyReportNotifications ?? this.dailyReportNotifications,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_notifications_enabled': pushNotificationsEnabled,
      'sound_enabled': soundEnabled,
      'email_notifications_enabled': emailNotificationsEnabled,
      'new_order_notifications': newOrderNotifications,
      'low_stock_notifications': lowStockNotifications,
      'daily_report_notifications': dailyReportNotifications,
    };
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushNotificationsEnabled: json['push_notifications_enabled'] as bool? ?? true,
      soundEnabled: json['sound_enabled'] as bool? ?? true,
      emailNotificationsEnabled: json['email_notifications_enabled'] as bool? ?? false,
      newOrderNotifications: json['new_order_notifications'] as bool? ?? true,
      lowStockNotifications: json['low_stock_notifications'] as bool? ?? true,
      dailyReportNotifications: json['daily_report_notifications'] as bool? ?? false,
    );
  }
}

/// API Configuration
class ApiConfiguration {
  final String baseUrl;
  final String organizationId;
  final String? apiKey;
  final int timeoutSeconds;

  const ApiConfiguration({
    this.baseUrl = '',
    this.organizationId = '',
    this.apiKey,
    this.timeoutSeconds = 30,
  });

  ApiConfiguration copyWith({
    String? baseUrl,
    String? organizationId,
    String? apiKey,
    int? timeoutSeconds,
  }) {
    return ApiConfiguration(
      baseUrl: baseUrl ?? this.baseUrl,
      organizationId: organizationId ?? this.organizationId,
      apiKey: apiKey ?? this.apiKey,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_url': baseUrl,
      'organization_id': organizationId,
      'api_key': apiKey,
      'timeout_seconds': timeoutSeconds,
    };
  }

  factory ApiConfiguration.fromJson(Map<String, dynamic> json) {
    return ApiConfiguration(
      baseUrl: json['base_url'] as String? ?? '',
      organizationId: json['organization_id'] as String? ?? '',
      apiKey: json['api_key'] as String?,
      timeoutSeconds: json['timeout_seconds'] as int? ?? 30,
    );
  }
}

/// Main App Settings Model
class AppSettings {
  // General Settings
  final String restaurantName;
  final String location;
  final String contactEmail;
  final String contactPhone;
  final String timezone;
  final String currency;
  final String language;

  // API Configuration
  final ApiConfiguration apiConfig;

  // Appearance Settings
  final AppThemeMode themeMode;
  final Color primaryColor;
  final double fontSize;

  // Business Settings
  final Map<int, BusinessHours> businessHours; // Day of week (1-7) -> Hours
  final List<DateTime> holidays;

  // Tax Settings
  final TaxSettings taxSettings;

  // Receipt Settings
  final ReceiptSettings receiptSettings;

  // Notification Settings
  final NotificationSettings notificationSettings;

  const AppSettings({
    this.restaurantName = '',
    this.location = '',
    this.contactEmail = '',
    this.contactPhone = '',
    this.timezone = 'UTC',
    this.currency = 'USD',
    this.language = 'en',
    this.apiConfig = const ApiConfiguration(),
    this.themeMode = AppThemeMode.system,
    this.primaryColor = const Color(0xFF714B67),
    this.fontSize = 14.0,
    this.businessHours = const {},
    this.holidays = const [],
    this.taxSettings = const TaxSettings(),
    this.receiptSettings = const ReceiptSettings(),
    this.notificationSettings = const NotificationSettings(),
  });

  AppSettings copyWith({
    String? restaurantName,
    String? location,
    String? contactEmail,
    String? contactPhone,
    String? timezone,
    String? currency,
    String? language,
    ApiConfiguration? apiConfig,
    AppThemeMode? themeMode,
    Color? primaryColor,
    double? fontSize,
    Map<int, BusinessHours>? businessHours,
    List<DateTime>? holidays,
    TaxSettings? taxSettings,
    ReceiptSettings? receiptSettings,
    NotificationSettings? notificationSettings,
  }) {
    return AppSettings(
      restaurantName: restaurantName ?? this.restaurantName,
      location: location ?? this.location,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      timezone: timezone ?? this.timezone,
      currency: currency ?? this.currency,
      language: language ?? this.language,
      apiConfig: apiConfig ?? this.apiConfig,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      fontSize: fontSize ?? this.fontSize,
      businessHours: businessHours ?? this.businessHours,
      holidays: holidays ?? this.holidays,
      taxSettings: taxSettings ?? this.taxSettings,
      receiptSettings: receiptSettings ?? this.receiptSettings,
      notificationSettings: notificationSettings ?? this.notificationSettings,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'restaurant_name': restaurantName,
      'location': location,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'timezone': timezone,
      'currency': currency,
      'language': language,
      'api_config': apiConfig.toJson(),
      'theme_mode': themeMode.name,
      'primary_color': primaryColor.value,
      'font_size': fontSize,
      'business_hours': businessHours.map(
        (day, hours) => MapEntry(day.toString(), hours.toJson()),
      ),
      'holidays': holidays.map((d) => d.toIso8601String()).toList(),
      'tax_settings': taxSettings.toJson(),
      'receipt_settings': receiptSettings.toJson(),
      'notification_settings': notificationSettings.toJson(),
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      restaurantName: json['restaurant_name'] as String? ?? '',
      location: json['location'] as String? ?? '',
      contactEmail: json['contact_email'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      timezone: json['timezone'] as String? ?? 'UTC',
      currency: json['currency'] as String? ?? 'USD',
      language: json['language'] as String? ?? 'en',
      apiConfig: json['api_config'] != null
          ? ApiConfiguration.fromJson(json['api_config'] as Map<String, dynamic>)
          : const ApiConfiguration(),
      themeMode: AppThemeMode.values.firstWhere(
        (e) => e.name == json['theme_mode'],
        orElse: () => AppThemeMode.system,
      ),
      primaryColor: Color(json['primary_color'] as int? ?? 0xFF714B67),
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 14.0,
      businessHours: (json['business_hours'] as Map<String, dynamic>?)?.map(
            (day, hours) => MapEntry(
              int.parse(day),
              BusinessHours.fromJson(hours as Map<String, dynamic>),
            ),
          ) ??
          {},
      holidays: (json['holidays'] as List?)
              ?.map((d) => DateTime.parse(d as String))
              .toList() ??
          [],
      taxSettings: json['tax_settings'] != null
          ? TaxSettings.fromJson(json['tax_settings'] as Map<String, dynamic>)
          : const TaxSettings(),
      receiptSettings: json['receipt_settings'] != null
          ? ReceiptSettings.fromJson(json['receipt_settings'] as Map<String, dynamic>)
          : const ReceiptSettings(),
      notificationSettings: json['notification_settings'] != null
          ? NotificationSettings.fromJson(json['notification_settings'] as Map<String, dynamic>)
          : const NotificationSettings(),
    );
  }

  static AppSettings defaultSettings() {
    return AppSettings(
      restaurantName: 'My Restaurant',
      location: '',
      contactEmail: '',
      contactPhone: '',
      timezone: 'UTC',
      currency: 'USD',
      language: 'en',
      businessHours: {
        1: BusinessHours.defaultHours(), // Monday
        2: BusinessHours.defaultHours(), // Tuesday
        3: BusinessHours.defaultHours(), // Wednesday
        4: BusinessHours.defaultHours(), // Thursday
        5: BusinessHours.defaultHours(), // Friday
        6: BusinessHours.defaultHours(), // Saturday
        7: BusinessHours.closed(), // Sunday
      },
    );
  }
}
