import 'package:flutter/material.dart';
import 'package:pos_core/pos_core.dart';

import '../../models/staff_models.dart';

/// Simple Role model for API communication.
///
/// This represents custom roles that can be created/managed.
/// Different from RoleTemplate which is for predefined role templates.
class Role {
  final String id;
  final String name;
  final Set<PermissionType> permissions;
  final bool isCustom;

  const Role({
    required this.id,
    required this.name,
    required this.permissions,
    this.isCustom = true,
  });

  Role copyWith({
    String? id,
    String? name,
    Set<PermissionType>? permissions,
    bool? isCustom,
  }) {
    return Role(
      id: id ?? this.id,
      name: name ?? this.name,
      permissions: permissions ?? this.permissions,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}

/// Extended Shift model with staff name for display.
class ShiftWithStaffName extends Shift {
  final String staffName;

  const ShiftWithStaffName({
    required super.id,
    required super.staffId,
    required this.staffName,
    required super.date,
    required super.startTime,
    required super.endTime,
    required super.type,
    super.isConfirmed,
    super.notes,
  });
}

/// Remote data source for staff management.
///
/// This handles API calls for staff members, roles, shifts, and activity logs.
abstract class StaffRemoteSource {
  // Staff Members CRUD
  Future<List<StaffMember>> getStaffMembers();
  Future<StaffMember> getStaffById(String id);
  Future<StaffMember> createStaff(StaffMember staff);
  Future<StaffMember> updateStaff(String id, StaffMember staff);
  Future<void> deleteStaff(String id);

  // Roles Management
  Future<List<Role>> getRoles();
  Future<Role> getRoleById(String id);
  Future<Role> createRole(Role role);
  Future<Role> updateRole(String id, Role role);
  Future<void> deleteRole(String id);

  // Shifts Management
  Future<List<Shift>> getShifts();
  Future<Shift> getShiftById(String id);
  Future<Shift> createShift(Shift shift);
  Future<Shift> updateShift(String id, Shift shift);
  Future<void> deleteShift(String id);

  // Activity Logs
  Future<List<ActivityLog>> getActivityLogs();
}

/// HTTP implementation of StaffRemoteSource.
/// Makes actual API calls to the backend.
class StaffRemoteSourceHttp implements StaffRemoteSource {
  StaffRemoteSourceHttp({
    required ApiClient apiClient,
    required String organizationId,
  })  : _apiClient = apiClient,
        _orgId = organizationId;

  final ApiClient _apiClient;
  final String _orgId;

  String get _staffPath => '/organizations/$_orgId/staff';
  String get _rolesPath => '/organizations/$_orgId/roles';
  String get _shiftsPath => '/organizations/$_orgId/shifts';
  String get _activityLogsPath => '/organizations/$_orgId/activity-logs';

  // ========== Staff Members CRUD ==========

  @override
  Future<List<StaffMember>> getStaffMembers() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _staffPath,
      );

      final data = response.data!['data'] as List;
      return data
          .map((json) => _staffMemberFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StaffMember> getStaffById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_staffPath/$id',
      );

      return _staffMemberFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StaffMember> createStaff(StaffMember staff) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _staffPath,
        data: _staffMemberToJson(staff),
      );

      return _staffMemberFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<StaffMember> updateStaff(String id, StaffMember staff) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '$_staffPath/$id',
        data: _staffMemberToJson(staff),
      );

      return _staffMemberFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteStaff(String id) async {
    try {
      await _apiClient.delete<Map<String, dynamic>>(
        '$_staffPath/$id',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ========== Roles Management ==========

  @override
  Future<List<Role>> getRoles() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _rolesPath,
      );

      final data = response.data!['data'] as List;
      return data
          .map((json) => _roleFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Role> getRoleById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_rolesPath/$id',
      );

      return _roleFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Role> createRole(Role role) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _rolesPath,
        data: _roleToJson(role),
      );

      return _roleFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Role> updateRole(String id, Role role) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '$_rolesPath/$id',
        data: _roleToJson(role),
      );

      return _roleFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteRole(String id) async {
    try {
      await _apiClient.delete<Map<String, dynamic>>(
        '$_rolesPath/$id',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ========== Shifts Management ==========

  @override
  Future<List<Shift>> getShifts() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _shiftsPath,
      );

      final data = response.data!['data'] as List;
      return data
          .map((json) => _shiftFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Shift> getShiftById(String id) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '$_shiftsPath/$id',
      );

      return _shiftFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Shift> createShift(Shift shift) async {
    try {
      final response = await _apiClient.post<Map<String, dynamic>>(
        _shiftsPath,
        data: _shiftToJson(shift),
      );

      return _shiftFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<Shift> updateShift(String id, Shift shift) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '$_shiftsPath/$id',
        data: _shiftToJson(shift),
      );

      return _shiftFromJson(response.data!);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteShift(String id) async {
    try {
      await _apiClient.delete<Map<String, dynamic>>(
        '$_shiftsPath/$id',
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ========== Activity Logs ==========

  @override
  Future<List<ActivityLog>> getActivityLogs() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        _activityLogsPath,
      );

      final data = response.data!['data'] as List;
      return data
          .map((json) => _activityLogFromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  // ========== JSON Serialization Helpers ==========

  StaffMember _staffMemberFromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      role: StaffRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => StaffRole.waiter,
      ),
      status: StaffStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StaffStatus.active,
      ),
      hireDate: DateTime.parse(json['hire_date'] as String),
      avatarUrl: json['avatar_url'] as String?,
      hourlyRate: (json['hourly_rate'] as num?)?.toDouble(),
      permissions: (json['permissions'] as List?)
              ?.map((p) => PermissionType.values.firstWhere(
                    (e) => e.name == p,
                    orElse: () => PermissionType.viewOrders,
                  ))
              .toSet() ??
          {},
      notes: json['notes'] as String?,
      lastActive: json['last_active'] != null
          ? DateTime.parse(json['last_active'] as String)
          : null,
    );
  }

  Map<String, dynamic> _staffMemberToJson(StaffMember staff) {
    return {
      'id': staff.id,
      'first_name': staff.firstName,
      'last_name': staff.lastName,
      'email': staff.email,
      'phone': staff.phone,
      'role': staff.role.name,
      'status': staff.status.name,
      'hire_date': staff.hireDate.toIso8601String(),
      'avatar_url': staff.avatarUrl,
      'hourly_rate': staff.hourlyRate,
      'permissions': staff.permissions.map((p) => p.name).toList(),
      'notes': staff.notes,
      'last_active': staff.lastActive?.toIso8601String(),
    };
  }

  Role _roleFromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'] as String,
      name: json['name'] as String,
      permissions: (json['permissions'] as List?)
              ?.map((p) => PermissionType.values.firstWhere(
                    (e) => e.name == p,
                    orElse: () => PermissionType.viewOrders,
                  ))
              .toSet() ??
          {},
      isCustom: json['is_custom'] as bool? ?? true,
    );
  }

  Map<String, dynamic> _roleToJson(Role role) {
    return {
      'id': role.id,
      'name': role.name,
      'permissions': role.permissions.map((p) => p.name).toList(),
      'is_custom': role.isCustom,
    };
  }

  Shift _shiftFromJson(Map<String, dynamic> json) {
    final startParts = (json['start_time'] as String).split(':');
    final endParts = (json['end_time'] as String).split(':');

    return Shift(
      id: json['id'] as String,
      staffId: json['staff_id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      ),
      endTime: TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      ),
      type: ShiftType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ShiftType.morning,
      ),
      isConfirmed: json['is_confirmed'] as bool? ?? false,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> _shiftToJson(Shift shift) {
    return {
      'id': shift.id,
      'staff_id': shift.staffId,
      'date': shift.date.toIso8601String(),
      'start_time':
          '${shift.startTime.hour.toString().padLeft(2, '0')}:${shift.startTime.minute.toString().padLeft(2, '0')}',
      'end_time':
          '${shift.endTime.hour.toString().padLeft(2, '0')}:${shift.endTime.minute.toString().padLeft(2, '0')}',
      'type': shift.type.name,
      'is_confirmed': shift.isConfirmed,
      'notes': shift.notes,
    };
  }

  ActivityLog _activityLogFromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'] as String,
      staffId: json['staff_id'] as String,
      staffName: json['staff_name'] as String,
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.login,
      ),
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> _activityLogToJson(ActivityLog log) {
    return {
      'id': log.id,
      'staff_id': log.staffId,
      'staff_name': log.staffName,
      'type': log.type.name,
      'description': log.description,
      'timestamp': log.timestamp.toIso8601String(),
      'metadata': log.metadata,
    };
  }
}

/// Mock implementation of StaffRemoteSource for development.
///
/// This provides mock data for testing without a backend.
class StaffRemoteSourceMock implements StaffRemoteSource {
  // Mock data storage
  final List<StaffMember> _staffMembers = _generateMockStaff();
  final List<Role> _roles = _generateMockRoles();
  final List<Shift> _shifts = _generateMockShifts();
  final List<ActivityLog> _activityLogs = _generateMockLogs();

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

  static List<Role> _generateMockRoles() {
    return [
      Role(
        id: '1',
        name: 'Custom Manager',
        permissions: {
          PermissionType.viewOrders,
          PermissionType.createOrders,
          PermissionType.editOrders,
          PermissionType.viewProducts,
          PermissionType.viewStaff,
          PermissionType.viewReports,
        },
        isCustom: true,
      ),
      Role(
        id: '2',
        name: 'Senior Cashier',
        permissions: {
          PermissionType.viewOrders,
          PermissionType.createOrders,
          PermissionType.viewProducts,
          PermissionType.manageCashDrawer,
          PermissionType.processRefunds,
          PermissionType.viewReports,
        },
        isCustom: true,
      ),
    ];
  }

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

  // ========== Staff Members CRUD ==========

  @override
  Future<List<StaffMember>> getStaffMembers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_staffMembers);
  }

  @override
  Future<StaffMember> getStaffById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _staffMembers.firstWhere(
      (staff) => staff.id == id,
      orElse: () => throw Exception('Staff member not found'),
    );
  }

  @override
  Future<StaffMember> createStaff(StaffMember staff) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _staffMembers.add(staff);
    return staff;
  }

  @override
  Future<StaffMember> updateStaff(String id, StaffMember staff) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _staffMembers.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Staff member not found');
    }

    _staffMembers[index] = staff;
    return staff;
  }

  @override
  Future<void> deleteStaff(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _staffMembers.removeWhere((staff) => staff.id == id);
  }

  // ========== Roles Management ==========

  @override
  Future<List<Role>> getRoles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_roles);
  }

  @override
  Future<Role> getRoleById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _roles.firstWhere(
      (role) => role.id == id,
      orElse: () => throw Exception('Role not found'),
    );
  }

  @override
  Future<Role> createRole(Role role) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _roles.add(role);
    return role;
  }

  @override
  Future<Role> updateRole(String id, Role role) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _roles.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw Exception('Role not found');
    }

    _roles[index] = role;
    return role;
  }

  @override
  Future<void> deleteRole(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _roles.removeWhere((role) => role.id == id);
  }

  // ========== Shifts Management ==========

  @override
  Future<List<Shift>> getShifts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_shifts);
  }

  @override
  Future<Shift> getShiftById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));

    return _shifts.firstWhere(
      (shift) => shift.id == id,
      orElse: () => throw Exception('Shift not found'),
    );
  }

  @override
  Future<Shift> createShift(Shift shift) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _shifts.add(shift);
    return shift;
  }

  @override
  Future<Shift> updateShift(String id, Shift shift) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _shifts.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw Exception('Shift not found');
    }

    _shifts[index] = shift;
    return shift;
  }

  @override
  Future<void> deleteShift(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    _shifts.removeWhere((shift) => shift.id == id);
  }

  // ========== Activity Logs ==========

  @override
  Future<List<ActivityLog>> getActivityLogs() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_activityLogs);
  }
}
