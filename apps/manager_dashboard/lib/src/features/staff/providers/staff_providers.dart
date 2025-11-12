import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../ui/theme/odoo_colors.dart';
import '../models/staff_models.dart';

/// Provider for staff members
///
/// TODO: Replace with real API integration
/// GET /api/v1/staff - List all staff
/// POST /api/v1/staff - Create staff member
/// PATCH /api/v1/staff/:id - Update staff member
/// DELETE /api/v1/staff/:id - Delete staff member
final staffMembersProvider =
    StateNotifierProvider<StaffMembersNotifier, List<StaffMember>>((ref) {
  return StaffMembersNotifier();
});

class StaffMembersNotifier extends StateNotifier<List<StaffMember>> {
  StaffMembersNotifier() : super(_generateMockStaff());

  static List<StaffMember> _generateMockStaff() {
    final now = DateTime.now();
    return [
      StaffMember(
        id: '1',
        firstName: 'John',
        lastName: 'Smith',
        email: 'john.smith@smartpos.com',
        phone: '+1 555-0101',
        role: StaffRole.admin,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 1, 15),
        hourlyRate: 25.00,
        permissions: PermissionType.values.toSet(),
        lastActive: now.subtract(const Duration(minutes: 5)),
      ),
      StaffMember(
        id: '2',
        firstName: 'Sarah',
        lastName: 'Johnson',
        email: 'sarah.j@smartpos.com',
        phone: '+1 555-0102',
        role: StaffRole.manager,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 3, 1),
        hourlyRate: 22.00,
        permissions: {
          PermissionType.viewOrders,
          PermissionType.createOrders,
          PermissionType.editOrders,
          PermissionType.viewStaff,
          PermissionType.viewReports,
          PermissionType.exportReports,
        },
        lastActive: now.subtract(const Duration(minutes: 15)),
      ),
      StaffMember(
        id: '3',
        firstName: 'Michael',
        lastName: 'Brown',
        email: 'mike.b@smartpos.com',
        phone: '+1 555-0103',
        role: StaffRole.cashier,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 5, 10),
        hourlyRate: 18.00,
        permissions: {
          PermissionType.viewOrders,
          PermissionType.createOrders,
          PermissionType.viewProducts,
          PermissionType.manageCashDrawer,
        },
        lastActive: now.subtract(const Duration(hours: 2)),
      ),
      StaffMember(
        id: '4',
        firstName: 'Emily',
        lastName: 'Davis',
        email: 'emily.d@smartpos.com',
        phone: '+1 555-0104',
        role: StaffRole.waiter,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 6, 1),
        hourlyRate: 15.00,
        permissions: {
          PermissionType.viewOrders,
          PermissionType.createOrders,
          PermissionType.viewProducts,
        },
        lastActive: now.subtract(const Duration(minutes: 30)),
      ),
      StaffMember(
        id: '5',
        firstName: 'David',
        lastName: 'Martinez',
        email: 'david.m@smartpos.com',
        phone: '+1 555-0105',
        role: StaffRole.kitchen,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 4, 15),
        hourlyRate: 20.00,
        permissions: {
          PermissionType.viewOrders,
          PermissionType.viewProducts,
        },
        lastActive: now.subtract(const Duration(minutes: 45)),
      ),
      StaffMember(
        id: '6',
        firstName: 'Jessica',
        lastName: 'Wilson',
        email: 'jessica.w@smartpos.com',
        phone: '+1 555-0106',
        role: StaffRole.waiter,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 7, 1),
        hourlyRate: 15.00,
        permissions: {
          PermissionType.viewOrders,
          PermissionType.createOrders,
          PermissionType.viewProducts,
        },
        lastActive: now.subtract(const Duration(hours: 1)),
      ),
      StaffMember(
        id: '7',
        firstName: 'Robert',
        lastName: 'Taylor',
        email: 'robert.t@smartpos.com',
        phone: '+1 555-0107',
        role: StaffRole.bartender,
        status: StaffStatus.active,
        hireDate: DateTime(2023, 5, 20),
        hourlyRate: 17.00,
        permissions: {
          PermissionType.viewOrders,
          PermissionType.createOrders,
          PermissionType.viewProducts,
        },
        lastActive: now.subtract(const Duration(hours: 3)),
      ),
      StaffMember(
        id: '8',
        firstName: 'Lisa',
        lastName: 'Anderson',
        email: 'lisa.a@smartpos.com',
        role: StaffRole.cashier,
        status: StaffStatus.onLeave,
        hireDate: DateTime(2023, 2, 1),
        hourlyRate: 18.00,
        notes: 'On vacation until next week',
      ),
    ];
  }

  void addStaffMember(StaffMember member) {
    state = [...state, member];
  }

  void updateStaffMember(String id, StaffMember updatedMember) {
    state = [
      for (final member in state)
        if (member.id == id) updatedMember else member,
    ];
  }

  void deleteStaffMember(String id) {
    state = state.where((member) => member.id != id).toList();
  }

  void updateStatus(String id, StaffStatus status) {
    state = [
      for (final member in state)
        if (member.id == id) member.copyWith(status: status) else member,
    ];
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
  return ShiftsNotifier();
});

class ShiftsNotifier extends StateNotifier<List<Shift>> {
  ShiftsNotifier() : super(_generateMockShifts());

  static List<Shift> _generateMockShifts() {
    final today = DateTime.now();
    final shifts = <Shift>[];

    // Generate shifts for the next 7 days
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = DateTime(today.year, today.month, today.day + dayOffset);

      // Morning shift (9 AM - 5 PM)
      shifts.addAll([
        Shift(
          id: 'shift-${dayOffset}-1',
          staffId: '3', // Michael (Cashier)
          date: date,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 17, minute: 0),
          type: ShiftType.morning,
          isConfirmed: dayOffset < 2,
        ),
        Shift(
          id: 'shift-${dayOffset}-2',
          staffId: '4', // Emily (Waiter)
          date: date,
          startTime: const TimeOfDay(hour: 9, minute: 0),
          endTime: const TimeOfDay(hour: 17, minute: 0),
          type: ShiftType.morning,
          isConfirmed: dayOffset < 2,
        ),
      ]);

      // Evening shift (5 PM - 11 PM)
      shifts.addAll([
        Shift(
          id: 'shift-${dayOffset}-3',
          staffId: '6', // Jessica (Waiter)
          date: date,
          startTime: const TimeOfDay(hour: 17, minute: 0),
          endTime: const TimeOfDay(hour: 23, minute: 0),
          type: ShiftType.evening,
          isConfirmed: dayOffset < 2,
        ),
        Shift(
          id: 'shift-${dayOffset}-4',
          staffId: '7', // Robert (Bartender)
          date: date,
          startTime: const TimeOfDay(hour: 17, minute: 0),
          endTime: const TimeOfDay(hour: 23, minute: 0),
          type: ShiftType.evening,
          isConfirmed: dayOffset < 2,
        ),
      ]);

      // Kitchen staff (full day)
      shifts.add(
        Shift(
          id: 'shift-${dayOffset}-5',
          staffId: '5', // David (Kitchen)
          date: date,
          startTime: const TimeOfDay(hour: 8, minute: 0),
          endTime: const TimeOfDay(hour: 20, minute: 0),
          type: ShiftType.fullDay,
          isConfirmed: dayOffset < 2,
        ),
      );
    }

    return shifts;
  }

  void addShift(Shift shift) {
    state = [...state, shift];
  }

  void updateShift(String id, Shift updatedShift) {
    state = [
      for (final shift in state)
        if (shift.id == id) updatedShift else shift,
    ];
  }

  void deleteShift(String id) {
    state = state.where((shift) => shift.id != id).toList();
  }

  void confirmShift(String id) {
    state = [
      for (final shift in state)
        if (shift.id == id) shift.copyWith(isConfirmed: true) else shift,
    ];
  }
}

/// Provider for activity logs
final activityLogsProvider =
    StateNotifierProvider<ActivityLogsNotifier, List<ActivityLog>>((ref) {
  return ActivityLogsNotifier();
});

class ActivityLogsNotifier extends StateNotifier<List<ActivityLog>> {
  ActivityLogsNotifier() : super(_generateMockLogs());

  static List<ActivityLog> _generateMockLogs() {
    final now = DateTime.now();
    return [
      ActivityLog(
        id: '1',
        staffId: '1',
        staffName: 'John Smith',
        type: ActivityType.login,
        description: 'Logged into the system',
        timestamp: now.subtract(const Duration(minutes: 5)),
      ),
      ActivityLog(
        id: '2',
        staffId: '4',
        staffName: 'Emily Davis',
        type: ActivityType.orderCreated,
        description: 'Created order #1234 for Table 5',
        timestamp: now.subtract(const Duration(minutes: 15)),
        metadata: {'order_id': '1234', 'table': '5'},
      ),
      ActivityLog(
        id: '3',
        staffId: '3',
        staffName: 'Michael Brown',
        type: ActivityType.refundProcessed,
        description: 'Processed refund for order #1220 (\$45.00)',
        timestamp: now.subtract(const Duration(minutes: 30)),
        metadata: {'order_id': '1220', 'amount': 45.00},
      ),
      ActivityLog(
        id: '4',
        staffId: '2',
        staffName: 'Sarah Johnson',
        type: ActivityType.staffModified,
        description: 'Updated staff member: Emily Davis',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      ActivityLog(
        id: '5',
        staffId: '4',
        staffName: 'Emily Davis',
        type: ActivityType.orderModified,
        description: 'Modified order #1235 - Added 2 items',
        timestamp: now.subtract(const Duration(hours: 2)),
        metadata: {'order_id': '1235'},
      ),
      ActivityLog(
        id: '6',
        staffId: '1',
        staffName: 'John Smith',
        type: ActivityType.settingsChanged,
        description: 'Updated system settings - Tax rate changed',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      ActivityLog(
        id: '7',
        staffId: '6',
        staffName: 'Jessica Wilson',
        type: ActivityType.orderCreated,
        description: 'Created order #1236 for Table 12',
        timestamp: now.subtract(const Duration(hours: 4)),
        metadata: {'order_id': '1236', 'table': '12'},
      ),
      ActivityLog(
        id: '8',
        staffId: '3',
        staffName: 'Michael Brown',
        type: ActivityType.login,
        description: 'Logged into the system',
        timestamp: now.subtract(const Duration(hours: 5)),
      ),
      ActivityLog(
        id: '9',
        staffId: '2',
        staffName: 'Sarah Johnson',
        type: ActivityType.productModified,
        description: 'Updated product: Margherita Pizza',
        timestamp: now.subtract(const Duration(hours: 6)),
        metadata: {'product_id': 'prod-123'},
      ),
      ActivityLog(
        id: '10',
        staffId: '4',
        staffName: 'Emily Davis',
        type: ActivityType.orderCancelled,
        description: 'Cancelled order #1230',
        timestamp: now.subtract(const Duration(hours: 7)),
        metadata: {'order_id': '1230'},
      ),
    ];
  }

  void addLog(ActivityLog log) {
    state = [log, ...state];
  }
}
