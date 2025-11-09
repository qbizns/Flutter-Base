import 'package:equatable/equatable.dart';

/// Type of failure that can occur in the application.
enum FailureType {
  /// Network-related failures (no connection, timeout, etc.)
  network,

  /// Server-related failures (4xx, 5xx errors)
  server,

  /// Authentication/authorization failures
  auth,

  /// Data validation failures
  validation,

  /// Storage/cache failures
  storage,

  /// Unknown/unexpected failures
  unknown,
}

/// Represents a failure in the application.
/// Contains information about what went wrong and how to handle it.
class Failure extends Equatable {
  const Failure({
    required this.message,
    this.type = FailureType.unknown,
    this.code,
    this.stackTrace,
  });

  /// Human-readable error message
  final String message;

  /// Type of failure for categorization
  final FailureType type;

  /// Optional error code (HTTP status, error code, etc.)
  final String? code;

  /// Optional stack trace for debugging
  final StackTrace? stackTrace;

  /// Factory for network failures
  factory Failure.network({
    String message = 'Network error occurred',
    String? code,
    StackTrace? stackTrace,
  }) =>
      Failure(
        message: message,
        type: FailureType.network,
        code: code,
        stackTrace: stackTrace,
      );

  /// Factory for server failures
  factory Failure.server({
    required String message,
    String? code,
    StackTrace? stackTrace,
  }) =>
      Failure(
        message: message,
        type: FailureType.server,
        code: code,
        stackTrace: stackTrace,
      );

  /// Factory for authentication failures
  factory Failure.auth({
    String message = 'Authentication failed',
    String? code,
    StackTrace? stackTrace,
  }) =>
      Failure(
        message: message,
        type: FailureType.auth,
        code: code,
        stackTrace: stackTrace,
      );

  /// Factory for validation failures
  factory Failure.validation({
    required String message,
    String? code,
    StackTrace? stackTrace,
  }) =>
      Failure(
        message: message,
        type: FailureType.validation,
        code: code,
        stackTrace: stackTrace,
      );

  /// Factory for storage failures
  factory Failure.storage({
    required String message,
    String? code,
    StackTrace? stackTrace,
  }) =>
      Failure(
        message: message,
        type: FailureType.storage,
        code: code,
        stackTrace: stackTrace,
      );

  /// Factory for unknown failures
  factory Failure.unknown({
    String message = 'An unexpected error occurred',
    String? code,
    StackTrace? stackTrace,
  }) =>
      Failure(
        message: message,
        type: FailureType.unknown,
        code: code,
        stackTrace: stackTrace,
      );

  /// Create a failure from an exception
  factory Failure.fromException(
    Exception exception, {
    FailureType type = FailureType.unknown,
    StackTrace? stackTrace,
  }) {
    return Failure(
      message: exception.toString(),
      type: type,
      stackTrace: stackTrace,
    );
  }

  @override
  List<Object?> get props => [message, type, code];

  @override
  String toString() {
    final buffer = StringBuffer('Failure(type: $type, message: $message');
    if (code != null) buffer.write(', code: $code');
    buffer.write(')');
    return buffer.toString();
  }
}
