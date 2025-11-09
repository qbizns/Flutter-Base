import 'failure.dart';

/// Represents the result of an operation that can either succeed or fail.
///
/// This is a functional approach to error handling that makes errors explicit
/// in the type system, avoiding exceptions for control flow.
///
/// Usage:
/// ```dart
/// Result<User> result = await userRepository.getUser(id);
///
/// return result.when(
///   success: (user) => Text('Hello ${user.name}'),
///   failure: (failure) => Text('Error: ${failure.message}'),
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Creates a successful result with a value
  const factory Result.success(T value) = Success<T>;

  /// Creates a failed result with a failure
  const factory Result.failure(Failure failure) = ResultFailure<T>;

  /// Returns true if this is a success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure
  bool get isFailure => this is ResultFailure<T>;

  /// Gets the value if success, throws if failure
  T get value {
    return switch (this) {
      Success(value: final v) => v,
      ResultFailure() => throw StateError('Cannot get value from failure'),
    };
  }

  /// Gets the failure if failed, throws if success
  Failure get failure {
    return switch (this) {
      Success() => throw StateError('Cannot get failure from success'),
      ResultFailure(failure: final f) => f,
    };
  }

  /// Gets the value if success, null otherwise
  T? get valueOrNull {
    return switch (this) {
      Success(value: final v) => v,
      ResultFailure() => null,
    };
  }

  /// Gets the failure if failed, null otherwise
  Failure? get failureOrNull {
    return switch (this) {
      Success() => null,
      ResultFailure(failure: final f) => f,
    };
  }

  /// Pattern matching on result
  R when<R>({
    required R Function(T value) success,
    required R Function(Failure failure) failure,
  }) {
    return switch (this) {
      Success(value: final v) => success(v),
      ResultFailure(failure: final f) => failure(f),
    };
  }

  /// Maps the success value to a new value
  Result<R> map<R>(R Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => Result.success(transform(v)),
      ResultFailure(failure: final f) => Result.failure(f),
    };
  }

  /// Flat maps the success value to a new result
  Result<R> flatMap<R>(Result<R> Function(T value) transform) {
    return switch (this) {
      Success(value: final v) => transform(v),
      ResultFailure(failure: final f) => Result.failure(f),
    };
  }

  /// Gets the value or a default if failure
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success(value: final v) => v,
      ResultFailure() => defaultValue,
    };
  }

  /// Gets the value or computes a default from the failure
  T getOrElseFrom(T Function(Failure failure) defaultValue) {
    return switch (this) {
      Success(value: final v) => v,
      ResultFailure(failure: final f) => defaultValue(f),
    };
  }
}

/// Successful result containing a value
final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  String toString() => 'Success($value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;
}

/// Failed result containing a failure
final class ResultFailure<T> extends Result<T> {
  const ResultFailure(this.failure);

  final Failure failure;

  @override
  String toString() => 'Failure($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;
}

/// Extension for easier Result creation from async operations
extension FutureResultExtension<T> on Future<T> {
  /// Wraps a future in a Result, catching any exceptions
  Future<Result<T>> toResult({
    FailureType failureType = FailureType.unknown,
  }) async {
    try {
      final value = await this;
      return Result.success(value);
    } on Exception catch (e, stackTrace) {
      return Result.failure(
        Failure.fromException(
          e,
          type: failureType,
          stackTrace: stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return Result.failure(
        Failure(
          message: e.toString(),
          type: failureType,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
