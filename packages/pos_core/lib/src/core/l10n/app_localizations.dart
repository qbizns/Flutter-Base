import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// App localizations delegate for loading translations
class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  /// Helper method to get current localizations instance
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Supported locales
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  /// Load translations from JSON file
  Future<bool> load() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/l10n/${locale.languageCode}.json',
      );
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      _localizedStrings = jsonMap;
      return true;
    } catch (e) {
      // Fallback to English if translation file not found
      if (locale.languageCode != 'en') {
        final jsonString = await rootBundle.loadString('assets/l10n/en.json');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        _localizedStrings = jsonMap;
      }
      return false;
    }
  }

  /// Get translated string by key (supports nested keys with dot notation)
  String translate(String key, {Map<String, dynamic>? params}) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation not found
      }
    }

    String result = value.toString();

    // Replace parameters if provided
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        result = result.replaceAll('{$paramKey}', paramValue.toString());
      });
    }

    return result;
  }

  /// Shorthand for translate
  String tr(String key, {Map<String, dynamic>? params}) {
    return translate(key, params: params);
  }

  // Common translations
  String get appName => tr('appName');

  // Welcome screen
  String get welcomeTitle => tr('welcome.title');
  String get welcomeTagline => tr('welcome.tagline');
  String get welcomeDescription => tr('welcome.description');
  String get welcomeGetStarted => tr('welcome.getStarted');
  String get welcomeLearnMore => tr('welcome.learnMore');

  // Common
  String get commonOk => tr('common.ok');
  String get commonCancel => tr('common.cancel');
  String get commonSave => tr('common.save');
  String get commonDelete => tr('common.delete');
  String get commonEdit => tr('common.edit');
  String get commonClose => tr('common.close');
  String get commonYes => tr('common.yes');
  String get commonNo => tr('common.no');
  String get commonLoading => tr('common.loading');
  String get commonError => tr('common.error');
  String get commonSuccess => tr('common.success');
  String get commonRetry => tr('common.retry');

  // Errors
  String get errorNetwork => tr('errors.network');
  String get errorServer => tr('errors.server');
  String get errorUnknown => tr('errors.unknown');
  String get errorValidation => tr('errors.validation');
}

/// LocalizationsDelegate for AppLocalizations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .map((e) => e.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

/// Extension on BuildContext for easier access to translations
extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  String tr(String key, {Map<String, dynamic>? params}) {
    return AppLocalizations.of(this).tr(key, params: params);
  }
}
