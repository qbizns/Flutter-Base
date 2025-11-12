/// Error Handler
/// Centralized error handling with retry logic following Odoo patterns
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

/// Error Handler
/// Handles errors with retry logic and user-friendly messages
class ErrorHandler {
  /// Convert exception to user-friendly message
  static String getUserMessage(dynamic error) {
    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    } else if (error is ConnectionException) {
      return 'Unable to connect to server. Please check your connection.';
    } else if (error is AuthenticationException) {
      return 'Authentication failed. Please log in again.';
    } else if (error is NotFoundException) {
      return 'Requested resource not found.';
    } else if (error is ValidationException) {
      return error.message ?? 'Validation error occurred.';
    } else if (error is ServerException) {
      return 'Server error occurred. Please try again later.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get detailed error for logging/debugging
  static String getDetailedMessage(dynamic error, {StackTrace? stackTrace}) {
    final buffer = StringBuffer();

    buffer.writeln('Error Type: ${error.runtimeType}');
    buffer.writeln('Message: ${error.toString()}');

    if (error is KdsException) {
      buffer.writeln('Code: ${error.code}');
      if (error.details != null) {
        buffer.writeln('Details: ${error.details}');
      }
    }

    if (stackTrace != null) {
      buffer.writeln('Stack Trace:');
      buffer.writeln(stackTrace.toString());
    }

    return buffer.toString();
  }

  /// Execute with retry logic
  static Future<T> executeWithRetry<T>({
    required Future<T> Function() action,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      attempt++;

      try {
        return await action();
      } catch (error, stackTrace) {
        // Check if we should retry
        final canRetry = shouldRetry?.call(error) ?? _defaultShouldRetry(error);

        if (attempt >= maxAttempts || !canRetry) {
          debugPrint('Failed after $attempt attempts: $error');
          debugPrint(stackTrace.toString());
          rethrow;
        }

        // Log retry attempt
        debugPrint('Attempt $attempt failed, retrying in ${delay.inSeconds}s: $error');

        // Wait before retry
        await Future.delayed(delay);

        // Increase delay for next attempt (exponential backoff)
        delay = Duration(
          milliseconds: (delay.inMilliseconds * backoffMultiplier).round(),
        );
      }
    }
  }

  /// Default retry logic - retry on network errors, timeouts, and 5xx errors
  static bool _defaultShouldRetry(dynamic error) {
    return error is TimeoutException ||
        error is ConnectionException ||
        error is ServerException;
  }

  /// Execute with timeout
  static Future<T> executeWithTimeout<T>({
    required Future<T> Function() action,
    Duration timeout = const Duration(seconds: 30),
    String? timeoutMessage,
  }) async {
    try {
      return await action().timeout(
        timeout,
        onTimeout: () {
          throw TimeoutException(
            timeoutMessage ?? 'Operation timed out after ${timeout.inSeconds}s',
          );
        },
      );
    } catch (error) {
      rethrow;
    }
  }

  /// Safe execute - catches all errors and returns result or null
  static Future<T?> executeSafely<T>({
    required Future<T> Function() action,
    void Function(dynamic error)? onError,
  }) async {
    try {
      return await action();
    } catch (error, stackTrace) {
      debugPrint('Safe execution failed: $error');
      debugPrint(stackTrace.toString());
      onError?.call(error);
      return null;
    }
  }
}

/// Base KDS Exception
abstract class KdsException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  KdsException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

/// Connection Exception
class ConnectionException extends KdsException {
  ConnectionException([String? message])
      : super(
          message ?? 'Unable to connect to server',
          code: 'CONNECTION_ERROR',
        );
}

/// Timeout Exception (override built-in)
class TimeoutException extends KdsException {
  TimeoutException([String? message])
      : super(
          message ?? 'Request timed out',
          code: 'TIMEOUT',
        );
}

/// Authentication Exception
class AuthenticationException extends KdsException {
  AuthenticationException([String? message])
      : super(
          message ?? 'Authentication failed',
          code: 'AUTH_ERROR',
        );
}

/// Not Found Exception
class NotFoundException extends KdsException {
  NotFoundException([String? message])
      : super(
          message ?? 'Resource not found',
          code: 'NOT_FOUND',
        );
}

/// Validation Exception
class ValidationException extends KdsException {
  ValidationException([String? message, Map<String, dynamic>? errors])
      : super(
          message ?? 'Validation failed',
          code: 'VALIDATION_ERROR',
          details: errors,
        );
}

/// Server Exception
class ServerException extends KdsException {
  final int? statusCode;

  ServerException([String? message, this.statusCode])
      : super(
          message ?? 'Server error occurred',
          code: 'SERVER_ERROR',
          details: {'statusCode': statusCode},
        );
}

/// WebSocket Exception
class WebSocketException extends KdsException {
  WebSocketException([String? message])
      : super(
          message ?? 'WebSocket connection error',
          code: 'WEBSOCKET_ERROR',
        );
}

/// Data Sync Exception
class DataSyncException extends KdsException {
  DataSyncException([String? message])
      : super(
          message ?? 'Data synchronization failed',
          code: 'SYNC_ERROR',
        );
}

/// Retry Configuration
class RetryConfig {
  final int maxAttempts;
  final Duration initialDelay;
  final double backoffMultiplier;
  final Duration? maxDelay;
  final bool Function(dynamic error)? shouldRetry;

  const RetryConfig({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.maxDelay,
    this.shouldRetry,
  });

  /// Default config for network requests
  static const RetryConfig network = RetryConfig(
    maxAttempts: 3,
    initialDelay: Duration(seconds: 2),
    backoffMultiplier: 2.0,
  );

  /// Aggressive retry config
  static const RetryConfig aggressive = RetryConfig(
    maxAttempts: 5,
    initialDelay: Duration(milliseconds: 500),
    backoffMultiplier: 1.5,
  );

  /// Quick retry config
  static const RetryConfig quick = RetryConfig(
    maxAttempts: 2,
    initialDelay: Duration(seconds: 1),
    backoffMultiplier: 1.0,
  );
}

/// Error Recovery Strategy
class ErrorRecoveryStrategy {
  final String name;
  final Future<void> Function() action;
  final String description;

  const ErrorRecoveryStrategy({
    required this.name,
    required this.action,
    required this.description,
  });
}

/// Error State
enum ErrorState {
  none,
  loading,
  retrying,
  failed,
  recovered;

  bool get isError => this == ErrorState.failed;
  bool get isLoading => this == ErrorState.loading || this == ErrorState.retrying;
  bool get canRetry => this == ErrorState.failed;
}

/// Operation Result
class OperationResult<T> {
  final T? data;
  final dynamic error;
  final bool isSuccess;
  final String? message;

  const OperationResult._({
    this.data,
    this.error,
    required this.isSuccess,
    this.message,
  });

  factory OperationResult.success(T data, {String? message}) {
    return OperationResult._(
      data: data,
      isSuccess: true,
      message: message,
    );
  }

  factory OperationResult.failure(dynamic error, {String? message}) {
    return OperationResult._(
      error: error,
      isSuccess: false,
      message: message ?? ErrorHandler.getUserMessage(error),
    );
  }

  bool get isFailure => !isSuccess;

  T get dataOrThrow {
    if (!isSuccess) {
      throw error ?? Exception('Operation failed');
    }
    return data as T;
  }

  T? get dataOrNull => data;
}
