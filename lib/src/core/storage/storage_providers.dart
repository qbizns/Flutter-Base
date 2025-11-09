import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_storage.dart';
import 'shared_prefs_storage.dart';

part 'storage_providers.g.dart';

/// Provides the app storage instance.
/// This should be initialized during app bootstrap.
@riverpod
Future<AppStorage> appStorage(AppStorageRef ref) async {
  return await SharedPrefsStorage.create();
}
