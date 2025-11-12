import 'package:flutter/material.dart';

/// Staff member status
enum StaffStatus {
  active,
  inactive,
  onLeave,
  terminated,
}

/// Staff member role
enum StaffRole {
  admin,
  manager,
  cashier,
  waiter,
  kitchen,
  bartender,
}

/// Permission type for role-based access control
enum PermissionType {
  // Order Management
  viewOrders,
  createOrders,
  editOrders,
  deleteOrders,
  refundOrders,

  // Product Management
  viewProducts,
  createProducts,
  editProducts,
  deleteProducts,

  // Staff Management
  viewStaff,
  createStaff,
  editStaff,
  deleteStaff,

  // Reports & Analytics
  viewReports,
  exportReports,

  // Settings
  viewSettings,
  editSettings,

  // Financial
  viewFinancials,
  manageCashDrawer,
  processRefunds,
}

/// Shift type
enum ShiftType {
  morning,
  afternoon,
  evening,
  night,
  fullDay,
}

/// Activity type for logs
enum ActivityType {
  login,
  logout,
  orderCreated,
  orderModified,
  orderCancelled,
  refundProcessed,
  productAdded,
  productModified,
  settingsChanged,
  staffAdded,
  staffModified,
  permissionChanged,
}

/// Staff Member Model
class StaffMember {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final StaffRole role;
  final StaffStatus status;
  final DateTime hireDate;
  final String? avatarUrl;
  final double? hourlyRate;
  final Set<PermissionType> permissions;
  final String? notes;
  final DateTime? lastActive;

  const StaffMember({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.role,
    required this.status,
    required this.hireDate,
    this.avatarUrl,
    this.hourlyRate,
    this.permissions = const {},
    this.notes,
    this.lastActive,
  });

  String get fullName => '$firstName $lastName';

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}';

  StaffMember copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    StaffRole? role,
    StaffStatus? status,
    DateTime? hireDate,
    String? avatarUrl,
    double? hourlyRate,
    Set<PermissionType>? permissions,
    String? notes,
    DateTime? lastActive,
  }) {
    return StaffMember(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      hireDate: hireDate ?? this.hireDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      permissions: permissions ?? this.permissions,
      notes: notes ?? this.notes,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'role': role.name,
      'status': status.name,
      'hire_date': hireDate.toIso8601String(),
      'avatar_url': avatarUrl,
      'hourly_rate': hourlyRate,
      'permissions': permissions.map((p) => p.name).toList(),
      'notes': notes,
      'last_active': lastActive?.toIso8601String(),
    };
  }

  factory StaffMember.fromJson(Map<String, dynamic> json) {
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
}

/// Role Template (for permission presets)
class RoleTemplate {
  final StaffRole role;
  final String name;
  final String description;
  final Set<PermissionType> defaultPermissions;
  final Color color;

  const RoleTemplate({
    required this.role,
    required this.name,
    required this.description,
    required this.defaultPermissions,
    required this.color,
  });
}

/// Shift Model
class Shift {
  final String id;
  final String staffId;
  final DateTime date;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final ShiftType type;
  final bool isConfirmed;
  final String? notes;

  const Shift({
    required this.id,
    required this.staffId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.isConfirmed = false,
    this.notes,
  });

  Shift copyWith({
    String? id,
    String? staffId,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    ShiftType? type,
    bool? isConfirmed,
    String? notes,
  }) {
    return Shift(
      id: id ?? this.id,
      staffId: staffId ?? this.staffId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      type: type ?? this.type,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'date': date.toIso8601String(),
      'start_time': '${startTime.hour}:${startTime.minute}',
      'end_time': '${endTime.hour}:${endTime.minute}',
      'type': type.name,
      'is_confirmed': isConfirmed,
      'notes': notes,
    };
  }

  factory Shift.fromJson(Map<String, dynamic> json) {
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
}

/// Activity Log Model
class ActivityLog {
  final String id;
  final String staffId;
  final String staffName;
  final ActivityType type;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ActivityLog({
    required this.id,
    required this.staffId,
    required this.staffName,
    required this.type,
    required this.description,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'staff_id': staffId,
      'staff_name': staffName,
      'type': type.name,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
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
}
