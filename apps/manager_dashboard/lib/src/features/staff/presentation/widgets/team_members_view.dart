import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/staff_models.dart';
import '../../providers/staff_providers.dart';
import 'staff_member_form_dialog.dart';

/// Team Members View - Staff list with CRUD operations
class TeamMembersView extends ConsumerStatefulWidget {
  const TeamMembersView({super.key});

  @override
  ConsumerState<TeamMembersView> createState() => _TeamMembersViewState();
}

class _TeamMembersViewState extends ConsumerState<TeamMembersView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  StaffRole? _selectedRole;
  StaffStatus? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(staffMembersProvider);
    final filteredStaff = _filterStaff(staff);

    return Column(
      children: [
        // Toolbar
        _buildToolbar(filteredStaff.length),

        // Search and Filters
        Container(
          padding: const EdgeInsets.all(OdooSpacing.lg),
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: OdooSpacing.md),
              _buildFilters(staff),
            ],
          ),
        ),

        // Staff Table
        Expanded(
          child: filteredStaff.isEmpty
              ? _buildEmptyState()
              : _buildStaffTable(filteredStaff),
        ),
      ],
    );
  }

  Widget _buildToolbar(int count) {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Row(
        children: [
          Text(
            '$count team members found',
            style: OdooTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _showAddStaffDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Add Team Member'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase();
        });
      },
      decoration: InputDecoration(
        hintText: 'Search by name or email...',
        prefixIcon: Icon(
          Icons.search,
          color: OdooColors.textSecondary,
        ),
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _buildFilters(List<StaffMember> staff) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          // Role filter
          OutlinedButton.icon(
            onPressed: () => _showRoleFilter(),
            icon: const Icon(Icons.work_outline),
            label: Text(
              _selectedRole != null ? _getRoleName(_selectedRole!) : 'All Roles',
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  _selectedRole != null ? OdooColors.primary.withOpacity(0.1) : null,
            ),
          ),
          const SizedBox(width: OdooSpacing.md),

          // Status filter
          OutlinedButton.icon(
            onPressed: () => _showStatusFilter(),
            icon: const Icon(Icons.info_outline),
            label: Text(
              _selectedStatus != null
                  ? _getStatusText(_selectedStatus!)
                  : 'All Statuses',
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  _selectedStatus != null ? OdooColors.primary.withOpacity(0.1) : null,
            ),
          ),

          // Clear filters
          if (_selectedRole != null || _selectedStatus != null) ...[
            const SizedBox(width: OdooSpacing.md),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedRole = null;
                  _selectedStatus = null;
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              style: TextButton.styleFrom(
                foregroundColor: OdooColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStaffTable(List<StaffMember> staff) {
    return Card(
      margin: const EdgeInsets.all(OdooSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.md),
        child: DataTable2(
          columnSpacing: OdooSpacing.lg,
          horizontalMargin: OdooSpacing.lg,
          minWidth: 1000,
          headingRowColor: WidgetStateProperty.all(OdooColors.gray50),
          headingTextStyle: OdooTypography.tableHeader.copyWith(
            color: OdooColors.textPrimary,
          ),
          dataTextStyle: OdooTypography.tableCell,
          columns: const [
            DataColumn2(
              label: Text('NAME'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('ROLE'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('EMAIL'),
              size: ColumnSize.L,
            ),
            DataColumn2(
              label: Text('PHONE'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('HIRE DATE'),
              size: ColumnSize.M,
            ),
            DataColumn2(
              label: Text('STATUS'),
              size: ColumnSize.S,
            ),
            DataColumn2(
              label: Text('ACTIONS'),
              size: ColumnSize.M,
              numeric: true,
            ),
          ],
          rows: staff.map((member) => _buildStaffRow(member)).toList(),
        ),
      ),
    );
  }

  DataRow2 _buildStaffRow(StaffMember member) {
    return DataRow2(
      cells: [
        // Name
        DataCell(
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getRoleColor(member.role),
                child: Text(
                  member.initials,
                  style: OdooTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: OdooSpacing.md),
              Text(
                member.fullName,
                style: OdooTypography.tableCell.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        // Role
        DataCell(
          Row(
            children: [
              Icon(
                _getRoleIcon(member.role),
                size: OdooIconSizes.sm,
                color: _getRoleColor(member.role),
              ),
              const SizedBox(width: OdooSpacing.xs),
              Text(_getRoleName(member.role)),
            ],
          ),
        ),

        // Email
        DataCell(Text(member.email)),

        // Phone
        DataCell(Text(member.phone ?? '-')),

        // Hire Date
        DataCell(
          Text(DateFormat('MMM d, yyyy').format(member.hireDate)),
        ),

        // Status
        DataCell(_buildStatusBadge(member.status)),

        // Actions
        DataCell(
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () => _showEditStaffDialog(member),
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                iconSize: OdooIconSizes.md,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(OdooSpacing.sm),
              ),
              const SizedBox(width: OdooSpacing.xs),
              IconButton(
                onPressed: () => _confirmDeleteStaff(member),
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                iconSize: OdooIconSizes.md,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(OdooSpacing.sm),
                color: OdooColors.danger,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(StaffStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: OdooSpacing.sm,
        vertical: OdooSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
      ),
      child: Text(
        _getStatusText(status),
        style: OdooTypography.labelSmall.copyWith(
          color: _getStatusColor(status),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.lg),
          Text(
            _searchQuery.isNotEmpty || _selectedRole != null || _selectedStatus != null
                ? 'No team members found'
                : 'No team members yet',
            style: OdooTypography.titleLarge.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            _searchQuery.isNotEmpty || _selectedRole != null || _selectedStatus != null
                ? 'Try adjusting your search or filters'
                : 'Add your first team member to get started',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          if (_searchQuery.isEmpty && _selectedRole == null && _selectedStatus == null) ...[
            const SizedBox(height: OdooSpacing.xl),
            FilledButton.icon(
              onPressed: _showAddStaffDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Add First Team Member'),
            ),
          ],
        ],
      ),
    );
  }

  // Filter and Search Logic

  List<StaffMember> _filterStaff(List<StaffMember> staff) {
    return staff.where((member) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesName = member.fullName.toLowerCase().contains(_searchQuery);
        final matchesEmail = member.email.toLowerCase().contains(_searchQuery);

        if (!matchesName && !matchesEmail) {
          return false;
        }
      }

      // Role filter
      if (_selectedRole != null && member.role != _selectedRole) {
        return false;
      }

      // Status filter
      if (_selectedStatus != null && member.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  // Dialog Actions

  Future<void> _showRoleFilter() async {
    final selected = await showDialog<StaffRole?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Role'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('All Roles'),
          ),
          ...StaffRole.values.map((role) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, role),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      _getRoleIcon(role),
                      color: _getRoleColor(role),
                    ),
                    const SizedBox(width: OdooSpacing.md),
                    Text(_getRoleName(role)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );

    setState(() {
      _selectedRole = selected;
    });
  }

  Future<void> _showStatusFilter() async {
    final selected = await showDialog<StaffStatus?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Status'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('All Statuses'),
          ),
          ...StaffStatus.values.map((status) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, status),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: OdooSpacing.sm),
                    Text(_getStatusText(status)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );

    setState(() {
      _selectedStatus = selected;
    });
  }

  Future<void> _showAddStaffDialog() async {
    final result = await showDialog<StaffMember>(
      context: context,
      builder: (context) => const StaffMemberFormDialog(),
    );

    if (result != null) {
      ref.read(staffMembersProvider.notifier).addStaffMember(result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.fullName} added successfully'),
            backgroundColor: OdooColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showEditStaffDialog(StaffMember member) async {
    final result = await showDialog<StaffMember>(
      context: context,
      builder: (context) => StaffMemberFormDialog(member: member),
    );

    if (result != null) {
      ref.read(staffMembersProvider.notifier).updateStaffMember(member.id, result);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.fullName} updated successfully'),
            backgroundColor: OdooColors.success,
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteStaff(StaffMember member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: OdooColors.danger,
            ),
            const SizedBox(width: OdooSpacing.md),
            const Text('Delete Team Member'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete ${member.fullName}?',
              style: OdooTypography.bodyLarge,
            ),
            const SizedBox(height: OdooSpacing.lg),
            Container(
              padding: const EdgeInsets.all(OdooSpacing.md),
              decoration: BoxDecoration(
                color: OdooColors.dangerLight,
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
                border: Border.all(
                  color: OdooColors.danger,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: OdooColors.danger,
                    child: Text(
                      member.initials,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: OdooSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member.fullName,
                          style: OdooTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: OdooColors.danger,
                          ),
                        ),
                        Text(
                          '${_getRoleName(member.role)} • ${member.email}',
                          style: OdooTypography.bodySmall.copyWith(
                            color: OdooColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: OdooSpacing.lg),
            Text(
              'This action cannot be undone.',
              style: OdooTypography.bodySmall.copyWith(
                fontStyle: FontStyle.italic,
                color: OdooColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: OdooColors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(staffMembersProvider.notifier).deleteStaffMember(member.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${member.fullName} deleted'),
            backgroundColor: OdooColors.danger,
          ),
        );
      }
    }
  }

  // Helper Methods

  Color _getStatusColor(StaffStatus status) {
    switch (status) {
      case StaffStatus.active:
        return OdooColors.success;
      case StaffStatus.inactive:
        return OdooColors.gray400;
      case StaffStatus.onLeave:
        return OdooColors.warning;
      case StaffStatus.terminated:
        return OdooColors.danger;
    }
  }

  String _getStatusText(StaffStatus status) {
    switch (status) {
      case StaffStatus.active:
        return 'Active';
      case StaffStatus.inactive:
        return 'Inactive';
      case StaffStatus.onLeave:
        return 'On Leave';
      case StaffStatus.terminated:
        return 'Terminated';
    }
  }

  Color _getRoleColor(StaffRole role) {
    final templates = ref.read(roleTemplatesProvider);
    return templates.firstWhere((t) => t.role == role).color;
  }

  String _getRoleName(StaffRole role) {
    final templates = ref.read(roleTemplatesProvider);
    return templates.firstWhere((t) => t.role == role).name;
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
}
