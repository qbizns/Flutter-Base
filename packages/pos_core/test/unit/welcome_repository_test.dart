import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/src/features/welcome/data/repositories/welcome_repository_impl.dart';
import 'package:flutter_starter/src/features/welcome/data/sources/local_welcome_source.dart';
import 'package:flutter_starter/src/features/welcome/domain/entities/welcome_message.dart';

/// Unit tests for WelcomeRepositoryImpl.
void main() {
  group('WelcomeRepositoryImpl', () {
    late WelcomeRepositoryImpl repository;
    late LocalWelcomeSource localSource;

    setUp(() {
      localSource = const LocalWelcomeSource();
      repository = WelcomeRepositoryImpl(localSource: localSource);
    });

    test('getWelcomeMessage returns WelcomeMessage', () async {
      // Act
      final result = await repository.getWelcomeMessage();

      // Assert
      expect(result, isA<WelcomeMessage>());
      expect(result.title, isNotEmpty);
      expect(result.tagline, isNotEmpty);
      expect(result.description, isNotEmpty);
      expect(result.primaryButtonText, isNotEmpty);
      expect(result.secondaryButtonText, isNotEmpty);
    });

    test('getWelcomeMessage returns correct default values', () async {
      // Act
      final result = await repository.getWelcomeMessage();

      // Assert
      expect(result.title, equals('Flutter Starter'));
      expect(
        result.tagline,
        equals('Your Production-Ready Flutter Foundation'),
      );
      expect(result.primaryButtonText, equals('Get Started'));
      expect(result.secondaryButtonText, equals('Learn More'));
    });
  });

  group('LocalWelcomeSource', () {
    late LocalWelcomeSource source;

    setUp(() {
      source = const LocalWelcomeSource();
    });

    test('getWelcomeMessage completes successfully', () async {
      // Act & Assert
      expect(
        source.getWelcomeMessage(),
        completes,
      );
    });

    test('getWelcomeMessage returns valid WelcomeMessage', () async {
      // Act
      final result = await source.getWelcomeMessage();

      // Assert
      expect(result, isA<WelcomeMessage>());
      expect(result.title, isNotEmpty);
    });
  });

  group('WelcomeMessage entity', () {
    test('copyWith creates new instance with updated values', () {
      // Arrange
      const original = WelcomeMessage(
        title: 'Title 1',
        tagline: 'Tagline 1',
        description: 'Description 1',
        primaryButtonText: 'Primary 1',
        secondaryButtonText: 'Secondary 1',
      );

      // Act
      final updated = original.copyWith(
        title: 'Title 2',
        tagline: 'Tagline 2',
      );

      // Assert
      expect(updated.title, equals('Title 2'));
      expect(updated.tagline, equals('Tagline 2'));
      expect(updated.description, equals('Description 1'));
      expect(updated.primaryButtonText, equals('Primary 1'));
      expect(updated.secondaryButtonText, equals('Secondary 1'));
    });

    test('equality comparison works correctly', () {
      // Arrange
      const message1 = WelcomeMessage(
        title: 'Title',
        tagline: 'Tagline',
        description: 'Description',
        primaryButtonText: 'Primary',
        secondaryButtonText: 'Secondary',
      );

      const message2 = WelcomeMessage(
        title: 'Title',
        tagline: 'Tagline',
        description: 'Description',
        primaryButtonText: 'Primary',
        secondaryButtonText: 'Secondary',
      );

      const message3 = WelcomeMessage(
        title: 'Different',
        tagline: 'Tagline',
        description: 'Description',
        primaryButtonText: 'Primary',
        secondaryButtonText: 'Secondary',
      );

      // Assert
      expect(message1, equals(message2));
      expect(message1, isNot(equals(message3)));
    });
  });
}
