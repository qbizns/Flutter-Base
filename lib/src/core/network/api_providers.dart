import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../config/app_config.dart';
import '../config/env.dart';
import 'api_client.dart';

part 'api_providers.g.dart';

/// Provides the API client instance.
/// This is the main entry point for making HTTP requests.
@riverpod
ApiClient apiClient(ApiClientRef ref) {
  final config = AppConfig.fromEnvironment(currentEnvironment);
  return DioApiClient(config: config);
}
