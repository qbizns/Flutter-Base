import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../storage/storage_providers.dart';
import 'auth_repository.dart';
import 'auth_repository_impl.dart';
import 'auth_state.dart';
import 'session_manager.dart';

part 'auth_providers.g.dart';

/// Provides the session manager instance.
@riverpod
SessionManager sessionManager(SessionManagerRef ref) {
  final storage = ref.watch(appStorageProvider).requireValue;
  return SessionManager(storage: storage);
}

/// Provides the auth repository implementation.
@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref: ref);
}

/// Manages the current authentication state.
/// This is the single source of truth for user authentication across the app.
@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  @override
  Future<AuthState> build() async {
    // Try to restore session from storage
    final sessionManager = ref.read(sessionManagerProvider);
    final savedState = await sessionManager.loadSession();

    if (savedState != null && savedState.isAuthenticated) {
      return savedState;
    }

    return AuthState.unauthenticated();
  }

  /// Login with password credentials.
  Future<void> loginWithPassword(LoginCredentials credentials) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.loginWithPassword(credentials);

    result.when(
      success: (authState) async {
        state = AsyncValue.data(authState);
        await _saveSession(authState);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  /// Login with PIN credentials (for POS terminals).
  Future<void> loginWithPin(PinLoginCredentials credentials) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.loginWithPin(credentials);

    result.when(
      success: (authState) async {
        state = AsyncValue.data(authState);
        await _saveSession(authState);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  /// Sign up new user.
  Future<void> signUp(SignUpData data) async {
    state = const AsyncValue.loading();

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.signUp(data);

    result.when(
      success: (authState) async {
        state = AsyncValue.data(authState);
        await _saveSession(authState);
      },
      failure: (failure) {
        state = AsyncValue.error(failure, StackTrace.current);
      },
    );
  }

  /// Refresh the authentication token.
  Future<void> refreshToken() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isAuthenticated) return;

    final refreshToken = currentState.refreshToken;
    if (refreshToken == null) return;

    final repository = ref.read(authRepositoryProvider);
    final result = await repository.refreshToken(refreshToken);

    result.when(
      success: (authState) async {
        state = AsyncValue.data(authState);
        await _saveSession(authState);
      },
      failure: (failure) {
        // Token refresh failed - logout user
        await logout();
      },
    );
  }

  /// Logout the current user.
  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();

    state = AsyncValue.data(AuthState.unauthenticated());
    await _clearSession();
  }

  /// Update user info (after profile edit, etc).
  Future<void> updateUserInfo({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
  }) async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.isAuthenticated) return;

    final updatedState = AuthState.authenticated(
      userId: currentState.userId!,
      tenantId: currentState.tenantId,
      branchId: currentState.branchId,
      email: email ?? currentState.email,
      name: name ?? currentState.name,
      phone: phone ?? currentState.phone,
      avatarUrl: avatarUrl ?? currentState.avatarUrl,
      roles: currentState.roles,
      permissions: currentState.permissions,
      authToken: currentState.authToken!,
      refreshToken: currentState.refreshToken,
    );

    state = AsyncValue.data(updatedState);
    await _saveSession(updatedState);
  }

  Future<void> _saveSession(AuthState authState) async {
    final sessionManager = ref.read(sessionManagerProvider);
    await sessionManager.saveSession(authState);
  }

  Future<void> _clearSession() async {
    final sessionManager = ref.read(sessionManagerProvider);
    await sessionManager.clearSession();
  }
}
