import 'package:logger/logger.dart' as log;
import '../config/app_config.dart';

/// Application logger wrapper.
/// Provides a simple interface for logging throughout the app.
class AppLogger {
  static final _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: log.DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  static bool _isEnabled = true;

  /// Initialize logger with config.
  static void init(AppConfig config) {
    _isEnabled = config.enableLogging;
  }

  /// Log debug message.
  static void debug(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isEnabled) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log info message.
  static void info(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isEnabled) {
      _logger.i(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log warning message.
  static void warning(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isEnabled) {
      _logger.w(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log error message.
  static void error(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isEnabled) {
      _logger.e(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log fatal/critical message.
  static void fatal(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (_isEnabled) {
      _logger.f(message, error: error, stackTrace: stackTrace);
    }
  }
}
