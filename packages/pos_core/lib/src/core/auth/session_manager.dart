import 'dart:convert';

import '../storage/app_storage.dart';
import 'auth_state.dart';

/// Manages user session persistence and restoration.
/// Handles saving/loading auth state from local storage.
class SessionManager {
  SessionManager({required AppStorage storage}) : _storage = storage;

  final AppStorage _storage;

  static const String _authStateKey = 'auth_state';

  /// Save the current auth state to local storage.
  Future<void> saveSession(AuthState authState) async {
    if (authState.isAuthenticated) {
      final json = authState.toJson();
      await _storage.saveString(_authStateKey, jsonEncode(json));
    } else {
      await clearSession();
    }
  }

  /// Load the saved auth state from local storage.
  /// Returns null if no session exists or if it's invalid.
  Future<AuthState?> loadSession() async {
    try {
      final jsonString = await _storage.getString(_authStateKey);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthState.fromJson(json);
    } catch (e) {
      // If deserialization fails, clear the corrupted session
      await clearSession();
      return null;
    }
  }

  /// Clear the saved session from local storage.
  Future<void> clearSession() async {
    await _storage.remove(_authStateKey);
  }

  /// Check if a valid session exists.
  Future<bool> hasSession() async {
    final state = await loadSession();
    return state?.isAuthenticated ?? false;
  }
}
