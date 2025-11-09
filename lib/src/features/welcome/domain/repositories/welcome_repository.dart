import '../entities/welcome_message.dart';

/// Abstract repository interface for welcome feature.
/// Defines the contract for welcome data operations.
///
/// This interface is part of the domain layer and should be
/// implemented by the data layer. The domain layer defines WHAT
/// operations are needed, while the data layer defines HOW they
/// are implemented.
abstract class WelcomeRepository {
  /// Get welcome message.
  ///
  /// Returns a [WelcomeMessage] containing the content to display
  /// on the welcome screen.
  ///
  /// Throws an exception if the operation fails.
  Future<WelcomeMessage> getWelcomeMessage();
}
