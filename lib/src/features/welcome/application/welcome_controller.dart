import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/entities/welcome_message.dart';
import '../domain/usecases/load_welcome_content.dart';
import '../data/repositories/welcome_repository_impl.dart';
import '../data/sources/local_welcome_source.dart';

part 'welcome_controller.g.dart';

/// Provider for LocalWelcomeSource.
@riverpod
LocalWelcomeSource localWelcomeSource(LocalWelcomeSourceRef ref) {
  return const LocalWelcomeSource();
}

/// Provider for WelcomeRepository.
@riverpod
WelcomeRepository welcomeRepository(WelcomeRepositoryRef ref) {
  final localSource = ref.watch(localWelcomeSourceProvider);
  return WelcomeRepositoryImpl(localSource: localSource);
}

/// Provider for LoadWelcomeContent use case.
@riverpod
LoadWelcomeContent loadWelcomeContent(LoadWelcomeContentRef ref) {
  final repository = ref.watch(welcomeRepositoryProvider);
  return LoadWelcomeContent(repository: repository);
}

/// State for the welcome controller.
class WelcomeState {
  const WelcomeState({
    this.message,
    this.isLoading = false,
    this.error,
  });

  final WelcomeMessage? message;
  final bool isLoading;
  final String? error;

  WelcomeState copyWith({
    WelcomeMessage? message,
    bool? isLoading,
    String? error,
  }) {
    return WelcomeState(
      message: message ?? this.message,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Welcome controller that manages welcome screen state.
/// Handles loading welcome content and user interactions.
@riverpod
class WelcomeController extends _$WelcomeController {
  @override
  WelcomeState build() {
    loadWelcomeMessage();
    return const WelcomeState(isLoading: true);
  }

  /// Load welcome message.
  Future<void> loadWelcomeMessage() async {
    state = const WelcomeState(isLoading: true);

    try {
      final useCase = ref.read(loadWelcomeContentProvider);
      final message = await useCase.execute();

      state = WelcomeState(
        message: message,
        isLoading: false,
      );
    } catch (e) {
      state = WelcomeState(
        isLoading: false,
        error: 'Failed to load welcome content: ${e.toString()}',
      );
    }
  }

  /// Handle "Get Started" button press.
  void onGetStarted() {
    // In a real app, this might navigate to the next screen
    // For now, it's just a placeholder
    // Example: ref.read(routerProvider).push(Routes.onboarding);
  }

  /// Handle "Learn More" button press.
  void onLearnMore() {
    // In a real app, this might navigate to an info/about screen
    // For now, it's just a placeholder
    // Example: ref.read(routerProvider).push(Routes.about);
  }
}
