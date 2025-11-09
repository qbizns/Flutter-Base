import '../../domain/entities/welcome_message.dart';
import '../sources/local_welcome_source.dart';

/// Abstract repository interface for welcome feature.
/// Defines the contract for welcome data operations.
abstract class WelcomeRepository {
  Future<WelcomeMessage> getWelcomeMessage();
}

/// Implementation of WelcomeRepository.
/// Coordinates data sources and transforms data to domain entities.
class WelcomeRepositoryImpl implements WelcomeRepository {
  const WelcomeRepositoryImpl({
    required this.localSource,
  });

  final LocalWelcomeSource localSource;

  @override
  Future<WelcomeMessage> getWelcomeMessage() async {
    try {
      // In a real app, this might:
      // 1. Try to fetch from remote API
      // 2. Fall back to cache if offline
      // 3. Fall back to local default if no cache
      // For now, we just use the local source
      return await localSource.getWelcomeMessage();
    } catch (e) {
      // In a real app, you might want to handle errors differently
      // or return a default message
      rethrow;
    }
  }
}
