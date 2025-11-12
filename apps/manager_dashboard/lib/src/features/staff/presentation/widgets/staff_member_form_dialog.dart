import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/staff_models.dart';
import '../../providers/staff_providers.dart';

/// Staff Member Form Dialog - Add or edit team members
class StaffMemberFormDialog extends ConsumerStatefulWidget {
  const StaffMemberFormDialog({this.member, super.key});

  final StaffMember? member;

  @override
  ConsumerState<StaffMemberFormDialog> createState() =>
      _StaffMemberFormDialogState();
}

class _StaffMemberFormDialogState extends ConsumerState<StaffMemberFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _notesController = TextEditingController();

  late StaffRole _selectedRole;
  late StaffStatus _selectedStatus;
  late Set<PermissionType> _selectedPermissions;

  bool get isEditing => widget.member != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      _firstNameController.text = widget.member!.firstName;
      _lastNameController.text = widget.member!.lastName;
      _emailController.text = widget.member!.email;
      _phoneController.text = widget.member!.phone ?? '';
      _hourlyRateController.text = widget.member!.hourlyRate?.toString() ?? '';
      _notesController.text = widget.member!.notes ?? '';
      _selectedRole = widget.member!.role;
      _selectedStatus = widget.member!.status;
      _selectedPermissions = Set.from(widget.member!.permissions);
    } else {
      _selectedRole = StaffRole.waiter;
      _selectedStatus = StaffStatus.active;
      _selectedPermissions = _getDefaultPermissions(StaffRole.waiter);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _hourlyRateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 700,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(OdooSpacing.xl),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Personal Information
                      Text(
                        'Personal Information',
                        style: OdooTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.md),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name *',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: OdooSpacing.md),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name *',
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email *',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Required';
                          }
                          if (!value.contains('@')) {
                            return 'Invalid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: OdooSpacing.xl),

                      // Employment Details
                      Text(
                        'Employment Details',
                        style: OdooTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: OdooColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: OdooSpacing.md),

                      DropdownButtonFormField<StaffRole>(
                        value: _selectedRole,
                        decoration: const InputDecoration(
                          labelText: 'Role *',
                          prefixIcon: Icon(Icons.work_outline),
                        ),
                        items: StaffRole.values.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(_getRoleName(role)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRole = value;
                              _selectedPermissions = _getDefaultPermissions(value);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      DropdownButtonFormField<StaffStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          prefixIcon: Icon(Icons.info_outline),
                        ),
                        items: StaffStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(_getStatusText(status)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedStatus = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      TextFormField(
                        controller: _hourlyRateController,
                        decoration: const InputDecoration(
                          labelText: 'Hourly Rate (\$)',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: OdooSpacing.lg),

                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          prefixIcon: Icon(Icons.notes),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: OdooColors.gray50,
        border: Border(
          bottom: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(OdooSpacing.md),
            decoration: BoxDecoration(
              color: OdooColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
            ),
            child: Icon(
              Icons.person,
              color: OdooColors.primary,
              size: OdooIconSizes.lg,
            ),
          ),
          const SizedBox(width: OdooSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit Team Member' : 'Add Team Member',
                  style: OdooTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    color: OdooColors.textPrimary,
                  ),
                ),
                Text(
                  isEditing
                      ? 'Update team member information'
                      : 'Add a new team member',
                  style: OdooTypography.bodySmall.copyWith(
                    color: OdooColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      decoration: BoxDecoration(
        color: OdooColors.gray50,
        border: Border(
          top: BorderSide(
            color: OdooColors.border,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: OdooSpacing.md),
          FilledButton.icon(
            onPressed: _saveStaffMember,
            icon: const Icon(Icons.check),
            label: Text(isEditing ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _saveStaffMember() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final member = StaffMember(
      id: isEditing ? widget.member!.id : DateTime.now().toString(),
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      role: _selectedRole,
      status: _selectedStatus,
      hireDate: isEditing ? widget.member!.hireDate : DateTime.now(),
      hourlyRate: _hourlyRateController.text.isEmpty
          ? null
          : double.tryParse(_hourlyRateController.text),
      permissions: _selectedPermissions,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      lastActive: isEditing ? widget.member!.lastActive : null,
    );

    Navigator.of(context).pop(member);
  }

  Set<PermissionType> _getDefaultPermissions(StaffRole role) {
    final templates = ref.read(roleTemplatesProvider);
    return templates.firstWhere((t) => t.role == role).defaultPermissions;
  }

  String _getRoleName(StaffRole role) {
    final templates = ref.read(roleTemplatesProvider);
    return templates.firstWhere((t) => t.role == role).name;
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
}
