import '../../domain/entities/welcome_message.dart';

/// Local data source for welcome content.
/// In a real app, this could fetch from local storage, cache, or embedded assets.
class LocalWelcomeSource {
  const LocalWelcomeSource();

  /// Get welcome message from local source.
  /// This is a simple implementation that returns hardcoded data.
  /// In a production app, this might read from a JSON file or local database.
  Future<WelcomeMessage> getWelcomeMessage() async {
    // Simulate network/storage delay
    await Future.delayed(const Duration(milliseconds: 300));

    return const WelcomeMessage(
      title: 'Flutter Starter',
      tagline: 'Your Production-Ready Flutter Foundation',
      description:
          'Build beautiful, cross-platform applications with this production-grade '
          'Flutter starter template. Featuring clean architecture, Material 3 design, '
          'and scalable foundation ready for your next big project.',
      primaryButtonText: 'Get Started',
      secondaryButtonText: 'Learn More',
    );
  }
}
