import '../entities/welcome_message.dart';
import '../../data/repositories/welcome_repository_impl.dart';

/// Use case for loading welcome content.
/// Encapsulates the business logic for retrieving welcome screen data.
class LoadWelcomeContent {
  const LoadWelcomeContent({
    required this.repository,
  });

  final WelcomeRepository repository;

  /// Execute the use case to load welcome content.
  Future<WelcomeMessage> execute() async {
    try {
      return await repository.getWelcomeMessage();
    } catch (e) {
      rethrow;
    }
  }
}
