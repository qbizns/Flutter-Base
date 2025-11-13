import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';

import '../../../ui/theme/odoo_colors.dart';
import '../models/staff_models.dart';
import '../data/sources/staff_remote_source.dart';

/// Provider for staff remote data source.
///
/// Switches between HTTP and Mock implementation based on configuration.
final staffRemoteSourceProvider = Provider<StaffRemoteSource>((ref) {
  final config = ref.watch(appConfigProvider);
  final context = ref.watch(appContextProvider);

  // Use HTTP implementation if API URL is configured and we have tenant ID
  if (config.apiBaseUrl.isNotEmpty && context.tenantId != null) {
    final apiClient = ref.watch(apiClientProvider);
    return StaffRemoteSourceHttp(
      apiClient: apiClient,
      organizationId: context.tenantId!,
    );
  }

  // Fall back to mock for development/testing
  return StaffRemoteSourceMock();
});

/// Provider for staff members
final staffMembersProvider =
    StateNotifierProvider<StaffMembersNotifier, List<StaffMember>>((ref) {
  final remoteSource = ref.watch(staffRemoteSourceProvider);
  return StaffMembersNotifier(remoteSource);
});

class StaffMembersNotifier extends StateNotifier<List<StaffMember>> {
  StaffMembersNotifier(this._remoteSource) : super([]) {
    _loadStaffMembers();
  }

  final StaffRemoteSource _remoteSource;

  Future<void> _loadStaffMembers() async {
    try {
      final staffMembers = await _remoteSource.getStaffMembers();
      state = staffMembers;
    } catch (e) {
      // Handle error - in production, you might want to show a snackbar or error state
      print('Error loading staff members: $e');
    }
  }

  Future<void> addStaffMember(StaffMember member) async {
    try {
      final newMember = await _remoteSource.createStaff(member);
      state = [...state, newMember];
    } catch (e) {
      print('Error adding staff member: $e');
      rethrow;
    }
  }

  Future<void> updateStaffMember(String id, StaffMember updatedMember) async {
    try {
      final updated = await _remoteSource.updateStaff(id, updatedMember);
      state = [
        for (final member in state)
          if (member.id == id) updated else member,
      ];
    } catch (e) {
      print('Error updating staff member: $e');
      rethrow;
    }
  }

  Future<void> deleteStaffMember(String id) async {
    try {
      await _remoteSource.deleteStaff(id);
      state = state.where((member) => member.id != id).toList();
    } catch (e) {
      print('Error deleting staff member: $e');
      rethrow;
    }
  }

  void updateStatus(String id, StaffStatus status) {
    // Update status locally first for smooth UX
    state = [
      for (final member in state)
        if (member.id == id) member.copyWith(status: status) else member,
    ];

    // Then sync with backend
    final member = state.firstWhere((m) => m.id == id);
    updateStaffMember(id, member).catchError((e) {
      print('Error syncing staff status: $e');
    });
  }

  Future<void> refresh() async {
    await _loadStaffMembers();
  }
}

/// Role templates with default permissions
final roleTemplatesProvider = Provider<List<RoleTemplate>>((ref) {
  return [
    RoleTemplate(
      role: StaffRole.admin,
      name: 'Administrator',
      description: 'Full system access and control',
      defaultPermissions: PermissionType.values.toSet(),
      color: OdooColors.danger,
    ),
    RoleTemplate(
      role: StaffRole.manager,
      name: 'Manager',
      description: 'Manage staff, reports, and operations',
      defaultPermissions: {
        PermissionType.viewOrders,
        PermissionType.createOrders,
        PermissionType.editOrders,
        PermissionType.deleteOrders,
        PermissionType.viewProducts,
        PermissionType.viewStaff,
        PermissionType.viewReports,
        PermissionType.exportReports,
        PermissionType.viewFinancials,
      },
      color: OdooColors.primary,
    ),
    RoleTemplate(
      role: StaffRole.cashier,
      name: 'Cashier',
      description: 'Handle transactions and cash drawer',
      defaultPermissions: {
        PermissionType.viewOrders,
        PermissionType.createOrders,
        PermissionType.viewProducts,
        PermissionType.manageCashDrawer,
        PermissionType.processRefunds,
      },
      color: OdooColors.success,
    ),
    RoleTemplate(
      role: StaffRole.waiter,
      name: 'Waiter',
      description: 'Take orders and serve customers',
      defaultPermissions: {
        PermissionType.viewOrders,
        PermissionType.createOrders,
        PermissionType.viewProducts,
      },
      color: OdooColors.secondary,
    ),
    RoleTemplate(
      role: StaffRole.kitchen,
      name: 'Kitchen Staff',
      description: 'Prepare food and manage kitchen orders',
      defaultPermissions: {
        PermissionType.viewOrders,
        PermissionType.viewProducts,
      },
      color: OdooColors.warning,
    ),
    RoleTemplate(
      role: StaffRole.bartender,
      name: 'Bartender',
      description: 'Prepare beverages and manage bar orders',
      defaultPermissions: {
        PermissionType.viewOrders,
        PermissionType.createOrders,
        PermissionType.viewProducts,
      },
      color: OdooColors.info,
    ),
  ];
});

/// Provider for shifts
final shiftsProvider = StateNotifierProvider<ShiftsNotifier, List<Shift>>((ref) {
  final remoteSource = ref.watch(staffRemoteSourceProvider);
  return ShiftsNotifier(remoteSource);
});

class ShiftsNotifier extends StateNotifier<List<Shift>> {
  ShiftsNotifier(this._remoteSource) : super([]) {
    _loadShifts();
  }

  final StaffRemoteSource _remoteSource;

  Future<void> _loadShifts() async {
    try {
      final shifts = await _remoteSource.getShifts();
      state = shifts;
    } catch (e) {
      print('Error loading shifts: $e');
    }
  }

  Future<void> addShift(Shift shift) async {
    try {
      final newShift = await _remoteSource.createShift(shift);
      state = [...state, newShift];
    } catch (e) {
      print('Error adding shift: $e');
      rethrow;
    }
  }

  Future<void> updateShift(String id, Shift updatedShift) async {
    try {
      final updated = await _remoteSource.updateShift(id, updatedShift);
      state = [
        for (final shift in state)
          if (shift.id == id) updated else shift,
      ];
    } catch (e) {
      print('Error updating shift: $e');
      rethrow;
    }
  }

  Future<void> deleteShift(String id) async {
    try {
      await _remoteSource.deleteShift(id);
      state = state.where((shift) => shift.id != id).toList();
    } catch (e) {
      print('Error deleting shift: $e');
      rethrow;
    }
  }

  void confirmShift(String id) {
    // Update locally first for smooth UX
    state = [
      for (final shift in state)
        if (shift.id == id) shift.copyWith(isConfirmed: true) else shift,
    ];

    // Then sync with backend
    final shift = state.firstWhere((s) => s.id == id);
    updateShift(id, shift).catchError((e) {
      print('Error syncing shift confirmation: $e');
    });
  }

  Future<void> refresh() async {
    await _loadShifts();
  }
}

/// Provider for activity logs
final activityLogsProvider =
    StateNotifierProvider<ActivityLogsNotifier, List<ActivityLog>>((ref) {
  final remoteSource = ref.watch(staffRemoteSourceProvider);
  return ActivityLogsNotifier(remoteSource);
});

class ActivityLogsNotifier extends StateNotifier<List<ActivityLog>> {
  ActivityLogsNotifier(this._remoteSource) : super([]) {
    _loadActivityLogs();
  }

  final StaffRemoteSource _remoteSource;

  Future<void> _loadActivityLogs() async {
    try {
      final logs = await _remoteSource.getActivityLogs();
      state = logs;
    } catch (e) {
      print('Error loading activity logs: $e');
    }
  }

  void addLog(ActivityLog log) {
    // Add log locally for immediate display
    state = [log, ...state];
  }

  Future<void> refresh() async {
    await _loadActivityLogs();
  }
}
