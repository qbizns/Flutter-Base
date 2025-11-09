import 'package:flutter_starter/src/core/errors/failure.dart';
import 'package:flutter_starter/src/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    test('Success contains value', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.value, equals(42));
      expect(result.valueOrNull, equals(42));
      expect(result.failureOrNull, isNull);
    });

    test('Failure contains failure', () {
      const failure = Failure(message: 'Test error');
      const result = Result<int>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.failure, equals(failure));
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, equals(failure));
    });

    test('when() handles success case', () {
      const result = Result<int>.success(42);

      final output = result.when(
        success: (value) => 'Value: $value',
        failure: (failure) => 'Error: ${failure.message}',
      );

      expect(output, equals('Value: 42'));
    });

    test('when() handles failure case', () {
      const failure = Failure(message: 'Test error');
      const result = Result<int>.failure(failure);

      final output = result.when(
        success: (value) => 'Value: $value',
        failure: (failure) => 'Error: ${failure.message}',
      );

      expect(output, equals('Error: Test error'));
    });

    test('map() transforms success value', () {
      const result = Result<int>.success(42);
      final mapped = result.map((value) => value * 2);

      expect(mapped.isSuccess, isTrue);
      expect(mapped.value, equals(84));
    });

    test('map() preserves failure', () {
      const failure = Failure(message: 'Test error');
      const result = Result<int>.failure(failure);
      final mapped = result.map((value) => value * 2);

      expect(mapped.isFailure, isTrue);
      expect(mapped.failure, equals(failure));
    });

    test('flatMap() chains success results', () {
      const result = Result<int>.success(42);
      final flatMapped = result.flatMap(
        (value) => Result<String>.success('Value: $value'),
      );

      expect(flatMapped.isSuccess, isTrue);
      expect(flatMapped.value, equals('Value: 42'));
    });

    test('flatMap() short-circuits on failure', () {
      const failure = Failure(message: 'Test error');
      const result = Result<int>.failure(failure);
      final flatMapped = result.flatMap(
        (value) => Result<String>.success('Value: $value'),
      );

      expect(flatMapped.isFailure, isTrue);
      expect(flatMapped.failure, equals(failure));
    });

    test('getOrElse() returns value on success', () {
      const result = Result<int>.success(42);
      final value = result.getOrElse(0);

      expect(value, equals(42));
    });

    test('getOrElse() returns default on failure', () {
      const failure = Failure(message: 'Test error');
      const result = Result<int>.failure(failure);
      final value = result.getOrElse(0);

      expect(value, equals(0));
    });
  });

  group('Failure', () {
    test('creates network failure', () {
      final failure = Failure.network(message: 'No connection');

      expect(failure.type, equals(FailureType.network));
      expect(failure.message, equals('No connection'));
    });

    test('creates server failure', () {
      final failure = Failure.server(message: 'Server error', code: '500');

      expect(failure.type, equals(FailureType.server));
      expect(failure.message, equals('Server error'));
      expect(failure.code, equals('500'));
    });

    test('creates auth failure', () {
      final failure = Failure.auth();

      expect(failure.type, equals(FailureType.auth));
      expect(failure.message, equals('Authentication failed'));
    });

    test('equality works correctly', () {
      const failure1 = Failure(message: 'Test', type: FailureType.network);
      const failure2 = Failure(message: 'Test', type: FailureType.network);
      const failure3 = Failure(message: 'Different', type: FailureType.network);

      expect(failure1, equals(failure2));
      expect(failure1, isNot(equals(failure3)));
    });
  });
}
