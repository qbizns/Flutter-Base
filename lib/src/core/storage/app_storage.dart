/// Abstract storage interface for key-value persistence.
/// Provides a clean abstraction over the underlying storage mechanism.
abstract class AppStorage {
  /// Saves a string value
  Future<bool> saveString(String key, String value);

  /// Gets a string value
  Future<String?> getString(String key);

  /// Saves an integer value
  Future<bool> saveInt(String key, int value);

  /// Gets an integer value
  Future<int?> getInt(String key);

  /// Saves a double value
  Future<bool> saveDouble(String key, double value);

  /// Gets a double value
  Future<double?> getDouble(String key);

  /// Saves a boolean value
  Future<bool> saveBool(String key, bool value);

  /// Gets a boolean value
  Future<bool?> getBool(String key);

  /// Saves a list of strings
  Future<bool> saveStringList(String key, List<String> value);

  /// Gets a list of strings
  Future<List<String>?> getStringList(String key);

  /// Checks if a key exists
  Future<bool> containsKey(String key);

  /// Removes a key
  Future<bool> remove(String key);

  /// Clears all data
  Future<bool> clear();

  /// Gets all keys
  Future<Set<String>> getKeys();
}

/// Common storage keys used throughout the app
class StorageKeys {
  const StorageKeys._();

  /// Authentication token
  static const String authToken = 'auth_token';

  /// Refresh token
  static const String refreshToken = 'refresh_token';

  /// User ID
  static const String userId = 'user_id';

  /// Theme mode (light/dark/system)
  static const String themeMode = 'theme_mode';

  /// Language code
  static const String languageCode = 'language_code';

  /// First time launch flag
  static const String isFirstLaunch = 'is_first_launch';

  /// Onboarding completed flag
  static const String onboardingCompleted = 'onboarding_completed';
}
