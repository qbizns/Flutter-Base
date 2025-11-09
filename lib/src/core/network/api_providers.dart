import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/config_providers.dart';
import 'api_client.dart';

part 'api_providers.g.dart';

/// Provides the API client instance.
/// This is the main entry point for making HTTP requests.
/// Uses the app configuration loaded from JSON during bootstrap.
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  final config = ref.watch(appConfigProvider);
  return DioApiClient(config: config);
}
