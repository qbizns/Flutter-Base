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

// Vodo Design System (New Theme)
export 'src/theme/vodo_colors.dart';
export 'src/theme/vodo_text_styles.dart';
export 'src/theme/vodo_dimensions.dart';
export 'src/theme/vodo_theme.dart';

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

// Features - Products
export 'src/features/products/domain/entities/category.dart';
export 'src/features/products/domain/entities/modifier.dart';
export 'src/features/products/domain/entities/product.dart';
export 'src/features/products/domain/entities/product_price.dart';
export 'src/features/products/domain/repositories/products_repository.dart';
export 'src/features/products/domain/usecases/get_categories.dart';
export 'src/features/products/domain/usecases/get_products.dart';
export 'src/features/products/domain/usecases/search_products.dart';
export 'src/features/products/data/repositories/products_repository_impl.dart';
export 'src/features/products/data/sources/products_remote_source.dart';
export 'src/features/products/application/products_providers.dart';

// Features - Orders
export 'src/features/orders/domain/entities/cart.dart';
export 'src/features/orders/domain/entities/order.dart';
export 'src/features/orders/domain/entities/order_item.dart';
export 'src/features/orders/domain/repositories/orders_repository.dart';
export 'src/features/orders/domain/usecases/cancel_order.dart';
export 'src/features/orders/domain/usecases/create_order.dart';
export 'src/features/orders/domain/usecases/get_active_orders.dart';
export 'src/features/orders/domain/usecases/get_order_by_id.dart';
export 'src/features/orders/domain/usecases/get_orders.dart';
export 'src/features/orders/domain/usecases/update_order.dart';
export 'src/features/orders/domain/usecases/update_order_status.dart';
export 'src/features/orders/data/repositories/orders_repository_impl.dart';
export 'src/features/orders/data/sources/orders_remote_source.dart';
export 'src/features/orders/application/orders_providers.dart';

// Features - Tables
export 'src/features/tables/domain/entities/table.dart';
export 'src/features/tables/domain/entities/zone.dart';
export 'src/features/tables/domain/repositories/tables_repository.dart';
export 'src/features/tables/domain/usecases/assign_order_to_table.dart';
export 'src/features/tables/domain/usecases/clear_table.dart';
export 'src/features/tables/domain/usecases/get_available_tables.dart';
export 'src/features/tables/domain/usecases/get_tables.dart';
export 'src/features/tables/domain/usecases/get_zones.dart';
export 'src/features/tables/domain/usecases/update_table_status.dart';
export 'src/features/tables/data/repositories/tables_repository_impl.dart';
export 'src/features/tables/data/sources/tables_remote_source.dart';
export 'src/features/tables/application/tables_providers.dart';

// Features - Payments
export 'src/features/payments/domain/entities/payment.dart';
export 'src/features/payments/domain/entities/refund.dart';
export 'src/features/payments/domain/repositories/payments_repository.dart';
export 'src/features/payments/domain/usecases/cancel_payment.dart';
export 'src/features/payments/domain/usecases/get_payments.dart';
export 'src/features/payments/domain/usecases/get_payments_by_order.dart';
export 'src/features/payments/domain/usecases/process_payment.dart';
export 'src/features/payments/domain/usecases/process_refund.dart';
export 'src/features/payments/data/repositories/payments_repository_impl.dart';
export 'src/features/payments/data/sources/payments_remote_source.dart';
export 'src/features/payments/application/payments_providers.dart';
