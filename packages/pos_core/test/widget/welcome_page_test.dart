import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter/src/features/welcome/presentation/pages/welcome_page.dart';
import 'package:flutter_starter/src/features/welcome/application/welcome_controller.dart';
import 'package:flutter_starter/src/features/welcome/domain/entities/welcome_message.dart';

/// Widget tests for WelcomePage.
void main() {
  group('WelcomePage', () {
    testWidgets('displays loading indicator initially', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: WelcomePage(),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays welcome content after loading', (tester) async {
      // Arrange
      const testMessage = WelcomeMessage(
        title: 'Test App',
        tagline: 'Test Tagline',
        description: 'Test Description',
        primaryButtonText: 'Test Primary',
        secondaryButtonText: 'Test Secondary',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            welcomeControllerProvider.overrideWith((ref) {
              return TestWelcomeController(testMessage);
            }),
          ],
          child: const MaterialApp(
            home: WelcomePage(),
          ),
        ),
      );

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test App'), findsOneWidget);
      expect(find.text('Test Tagline'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.text('Test Primary'), findsOneWidget);
      expect(find.text('Test Secondary'), findsOneWidget);
    });

    testWidgets('primary button is tappable', (tester) async {
      // Arrange
      const testMessage = WelcomeMessage(
        title: 'Test App',
        tagline: 'Test Tagline',
        description: 'Test Description',
        primaryButtonText: 'Test Primary',
        secondaryButtonText: 'Test Secondary',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            welcomeControllerProvider.overrideWith((ref) {
              return TestWelcomeController(testMessage);
            }),
          ],
          child: const MaterialApp(
            home: WelcomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      final primaryButton = find.widgetWithText(ElevatedButton, 'Test Primary');
      expect(primaryButton, findsOneWidget);

      await tester.tap(primaryButton);
      await tester.pumpAndSettle();

      // Assert - button tap doesn't throw error
      expect(primaryButton, findsOneWidget);
    });

    testWidgets('secondary button is tappable', (tester) async {
      // Arrange
      const testMessage = WelcomeMessage(
        title: 'Test App',
        tagline: 'Test Tagline',
        description: 'Test Description',
        primaryButtonText: 'Test Primary',
        secondaryButtonText: 'Test Secondary',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            welcomeControllerProvider.overrideWith((ref) {
              return TestWelcomeController(testMessage);
            }),
          ],
          child: const MaterialApp(
            home: WelcomePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Act
      final secondaryButton = find.widgetWithText(TextButton, 'Test Secondary');
      expect(secondaryButton, findsOneWidget);

      await tester.tap(secondaryButton);
      await tester.pumpAndSettle();

      // Assert - button tap doesn't throw error
      expect(secondaryButton, findsOneWidget);
    });
  });
}

/// Test implementation of WelcomeController for testing.
class TestWelcomeController extends WelcomeController {
  TestWelcomeController(this.testMessage);

  final WelcomeMessage testMessage;

  @override
  WelcomeState build() {
    return WelcomeState(
      message: testMessage,
      isLoading: false,
    );
  }
}
