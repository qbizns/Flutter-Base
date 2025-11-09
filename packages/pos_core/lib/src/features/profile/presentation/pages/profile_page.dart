import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/auth_providers.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_sizes.dart';

/// Profile page showing user information and settings.
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: authState.when(
        data: (state) {
          if (!state.isAuthenticated) {
            return const Center(
              child: Text('Not authenticated'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(Sizes.p24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 60,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: state.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            state.avatarUrl!,
                            fit: BoxFit.cover,
                            width: 120,
                            height: 120,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: theme.colorScheme.onPrimaryContainer,
                              );
                            },
                          ),
                        )
                      : Icon(
                          Icons.person,
                          size: 60,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                ),
                const SizedBox(height: Sizes.p16),

                // Name
                Text(
                  state.name ?? 'User',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: Sizes.p8),

                // Email
                if (state.email != null)
                  Text(
                    state.email!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                // Phone
                if (state.phone != null) ...[
                  const SizedBox(height: Sizes.p4),
                  Text(
                    state.phone!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: Sizes.p32),

                // Info cards
                _InfoCard(
                  title: 'Account Information',
                  children: [
                    _InfoRow(
                      label: 'User ID',
                      value: state.userId ?? 'N/A',
                    ),
                    if (state.tenantId != null)
                      _InfoRow(
                        label: 'Tenant ID',
                        value: state.tenantId!,
                      ),
                    if (state.branchId != null)
                      _InfoRow(
                        label: 'Branch ID',
                        value: state.branchId!,
                      ),
                  ],
                ),
                const SizedBox(height: Sizes.p16),

                // Roles
                if (state.roles.isNotEmpty)
                  _InfoCard(
                    title: 'Roles',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.roles.map((role) {
                          return Chip(
                            label: Text(role),
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: Sizes.p16),

                // Permissions
                if (state.permissions.isNotEmpty)
                  _InfoCard(
                    title: 'Permissions',
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.permissions.map((permission) {
                          return Chip(
                            label: Text(permission),
                            backgroundColor:
                                theme.colorScheme.tertiaryContainer,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                const SizedBox(height: Sizes.p32),

                // Actions
                FilledButton.tonal(
                  onPressed: () {
                    // TODO: Navigate to edit profile
                  },
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(height: Sizes.p8),
                OutlinedButton(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Logout'),
                        content: const Text(
                          'Are you sure you want to logout?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed == true) {
                      await ref
                          .read(authStateNotifierProvider.notifier)
                          .logout();
                      if (context.mounted) {
                        context.go(Routes.signIn);
                      }
                    }
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Sizes.p16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Sizes.p12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
