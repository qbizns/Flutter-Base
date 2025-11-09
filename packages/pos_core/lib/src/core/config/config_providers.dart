import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'app_config.dart';
import 'env.dart';

part 'config_providers.g.dart';

/// Global app configuration provider.
/// This is set during app bootstrap and provides config to all modules.
@Riverpod(keepAlive: true)
AppConfig appConfig(AppConfigRef ref) {
  // This will be overridden during bootstrap
  throw UnimplementedError(
    'AppConfig provider must be overridden in bootstrap',
  );
}
