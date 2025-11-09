library pos_core;

// Bootstrap
export 'src/bootstrap/app_bootstrap.dart';

// Core - Auth
export 'src/core/auth/auth_providers.dart';
export 'src/core/auth/auth_repository.dart';
export 'src/core/auth/auth_repository_impl.dart';
export 'src/core/auth/auth_state.dart';
export 'src/core/auth/session_manager.dart';

// Core - Context
export 'src/core/context/app_context.dart';
export 'src/core/context/context_providers.dart';

// Core - Config
export 'src/core/config/app_config.dart';
export 'src/core/config/config_loader.dart';
export 'src/core/config/config_providers.dart';
export 'src/core/config/env.dart';
export 'src/core/config/feature_flags.dart';

// Core - Errors
export 'src/core/errors/app_exception.dart';
export 'src/core/errors/failure.dart';
export 'src/core/errors/result.dart';

// Core - Network
export 'src/core/network/api_client.dart';
export 'src/core/network/api_providers.dart';

// Core - Storage
export 'src/core/storage/app_storage.dart';
export 'src/core/storage/shared_prefs_storage.dart';
export 'src/core/storage/storage_providers.dart';

// Core - L10n
export 'src/core/l10n/app_localizations.dart';

// Core - Theme
export 'src/core/theme/app_colors.dart';
export 'src/core/theme/app_sizes.dart';
export 'src/core/theme/app_theme.dart';
export 'src/core/theme/app_typography.dart';

// Core - Routing
export 'src/core/routing/app_router.dart';
export 'src/core/routing/routes.dart';

// Core - Widgets
export 'src/core/widgets/app_scaffold.dart';
export 'src/core/widgets/responsive_layout.dart';

// Core - Utils
export 'src/core/utils/logger.dart';
export 'src/core/utils/platform_info.dart';

// Features - Auth
export 'src/features/auth/presentation/pages/forgot_password_page.dart';
export 'src/features/auth/presentation/pages/sign_in_page.dart';
export 'src/features/auth/presentation/pages/sign_up_page.dart';
export 'src/features/auth/presentation/pages/splash_page.dart';
export 'src/features/auth/presentation/pages/verification_page.dart';

// Features - Onboarding
export 'src/features/onboarding/presentation/pages/onboarding_page.dart';

// Features - Home Shell
export 'src/features/home_shell/presentation/pages/home_shell_page.dart';

// Features - Profile
export 'src/features/profile/presentation/pages/profile_page.dart';
