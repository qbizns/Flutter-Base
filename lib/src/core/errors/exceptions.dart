/// Base class for all application exceptions
abstract class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Exception thrown when a network error occurs
class NetworkException extends AppException {
  const NetworkException([super.message = 'Network error occurred']);
}

/// Exception thrown when the server returns an error
class ServerException extends AppException {
  const ServerException([super.message = 'Server error occurred']);

  factory ServerException.fromStatusCode(int statusCode, String? message) {
    return ServerException(
      message ?? 'Server error: $statusCode',
    );
  }
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed']);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException([super.message = 'Validation failed']);
}

/// Exception thrown when storage operation fails
class StorageException extends AppException {
  const StorageException([super.message = 'Storage operation failed']);
}

/// Exception thrown when cache operation fails
class CacheException extends AppException {
  const CacheException([super.message = 'Cache operation failed']);
}
