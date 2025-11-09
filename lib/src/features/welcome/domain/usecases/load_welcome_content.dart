import '../entities/welcome_message.dart';
import '../repositories/welcome_repository.dart';

/// Use case for loading welcome content.
/// Encapsulates the business logic for retrieving welcome screen data.
///
/// This use case depends only on the domain layer interface [WelcomeRepository],
/// not on any specific implementation. This follows the Dependency Inversion
/// Principle - the domain layer defines the interface, and the data layer
/// provides the implementation.
class LoadWelcomeContent {
  const LoadWelcomeContent({
    required this.repository,
  });

  final WelcomeRepository repository;

  /// Execute the use case to load welcome content.
  Future<WelcomeMessage> execute() async {
    return repository.getWelcomeMessage();
  }
}
