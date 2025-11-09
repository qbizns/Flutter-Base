import 'package:shared_preferences/shared_preferences.dart';
import '../errors/exceptions.dart';
import 'app_storage.dart';

/// Implementation of AppStorage using SharedPreferences
class SharedPrefsStorage implements AppStorage {
  SharedPrefsStorage(this._prefs);

  final SharedPreferences _prefs;

  /// Factory method to create instance asynchronously
  static Future<SharedPrefsStorage> create() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return SharedPrefsStorage(prefs);
    } catch (e) {
      throw const StorageException('Failed to initialize storage');
    }
  }

  @override
  Future<bool> saveString(String key, String value) async {
    try {
      return await _prefs.setString(key, value);
    } catch (e) {
      throw StorageException('Failed to save string for key: $key');
    }
  }

  @override
  Future<String?> getString(String key) async {
    try {
      return _prefs.getString(key);
    } catch (e) {
      throw StorageException('Failed to get string for key: $key');
    }
  }

  @override
  Future<bool> saveInt(String key, int value) async {
    try {
      return await _prefs.setInt(key, value);
    } catch (e) {
      throw StorageException('Failed to save int for key: $key');
    }
  }

  @override
  Future<int?> getInt(String key) async {
    try {
      return _prefs.getInt(key);
    } catch (e) {
      throw StorageException('Failed to get int for key: $key');
    }
  }

  @override
  Future<bool> saveDouble(String key, double value) async {
    try {
      return await _prefs.setDouble(key, value);
    } catch (e) {
      throw StorageException('Failed to save double for key: $key');
    }
  }

  @override
  Future<double?> getDouble(String key) async {
    try {
      return _prefs.getDouble(key);
    } catch (e) {
      throw StorageException('Failed to get double for key: $key');
    }
  }

  @override
  Future<bool> saveBool(String key, bool value) async {
    try {
      return await _prefs.setBool(key, value);
    } catch (e) {
      throw StorageException('Failed to save bool for key: $key');
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      throw StorageException('Failed to get bool for key: $key');
    }
  }

  @override
  Future<bool> saveStringList(String key, List<String> value) async {
    try {
      return await _prefs.setStringList(key, value);
    } catch (e) {
      throw StorageException('Failed to save string list for key: $key');
    }
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    try {
      return _prefs.getStringList(key);
    } catch (e) {
      throw StorageException('Failed to get string list for key: $key');
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      throw StorageException('Failed to check key: $key');
    }
  }

  @override
  Future<bool> remove(String key) async {
    try {
      return await _prefs.remove(key);
    } catch (e) {
      throw StorageException('Failed to remove key: $key');
    }
  }

  @override
  Future<bool> clear() async {
    try {
      return await _prefs.clear();
    } catch (e) {
      throw const StorageException('Failed to clear storage');
    }
  }

  @override
  Future<Set<String>> getKeys() async {
    try {
      return _prefs.getKeys();
    } catch (e) {
      throw const StorageException('Failed to get keys');
    }
  }
}
