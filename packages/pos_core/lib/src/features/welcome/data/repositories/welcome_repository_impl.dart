import '../../domain/entities/welcome_message.dart';
import '../../domain/repositories/welcome_repository.dart';
import '../sources/local_welcome_source.dart';

/// Implementation of [WelcomeRepository] from the domain layer.
/// Coordinates data sources and transforms data to domain entities.
///
/// This class is part of the data layer and depends on the domain layer
/// interface. It provides the concrete implementation of how to fetch
/// welcome data, while the domain layer defines what operations are needed.
class WelcomeRepositoryImpl implements WelcomeRepository {
  const WelcomeRepositoryImpl({
    required this.localSource,
  });

  final LocalWelcomeSource localSource;

  @override
  Future<WelcomeMessage> getWelcomeMessage() async {
    // In a real app, this might:
    // 1. Try to fetch from remote API
    // 2. Fall back to cache if offline
    // 3. Fall back to local default if no cache
    // For now, we just use the local source
    return localSource.getWelcomeMessage();
  }
}
