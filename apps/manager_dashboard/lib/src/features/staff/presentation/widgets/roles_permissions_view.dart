import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/staff_models.dart';
import '../../providers/staff_providers.dart';

/// Roles & Permissions View - Permission matrix
class RolesPermissionsView extends ConsumerWidget {
  const RolesPermissionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roleTemplates = ref.watch(roleTemplatesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Role Permissions Matrix',
            style: OdooTypography.titleLarge.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            'Default permissions for each role. Individual members can have custom permissions.',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.xl),

          // Roles Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: OdooSpacing.lg,
              mainAxisSpacing: OdooSpacing.lg,
              childAspectRatio: 1.2,
            ),
            itemCount: roleTemplates.length,
            itemBuilder: (context, index) {
              return _buildRoleCard(context, roleTemplates[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, RoleTemplate template) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: template.color,
              width: 4,
            ),
          ),
          borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
        ),
        child: Padding(
          padding: const EdgeInsets.all(OdooSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(OdooSpacing.sm),
                    decoration: BoxDecoration(
                      color: template.color.withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(OdooSpacing.radiusStandard),
                    ),
                    child: Icon(
                      _getRoleIcon(template.role),
                      color: template.color,
                      size: OdooIconSizes.lg,
                    ),
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template.name,
                          style: OdooTypography.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${template.defaultPermissions.length} permissions',
                          style: OdooTypography.bodySmall.copyWith(
                            color: OdooColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: OdooSpacing.md),
              Text(
                template.description,
                style: OdooTypography.bodySmall.copyWith(
                  color: OdooColors.textSecondary,
                ),
              ),
              const SizedBox(height: OdooSpacing.lg),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: OdooSpacing.xs,
                    runSpacing: OdooSpacing.xs,
                    children: template.defaultPermissions.map((permission) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OdooSpacing.sm,
                          vertical: OdooSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: template.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            OdooSpacing.radiusStandard,
                          ),
                        ),
                        child: Text(
                          _getPermissionText(permission),
                          style: OdooTypography.bodySmall.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getRoleIcon(StaffRole role) {
    switch (role) {
      case StaffRole.admin:
        return Icons.admin_panel_settings;
      case StaffRole.manager:
        return Icons.business;
      case StaffRole.cashier:
        return Icons.point_of_sale;
      case StaffRole.waiter:
        return Icons.restaurant;
      case StaffRole.kitchen:
        return Icons.restaurant_menu;
      case StaffRole.bartender:
        return Icons.local_bar;
    }
  }

  String _getPermissionText(PermissionType permission) {
    return permission.name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim();
  }
}
