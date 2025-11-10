/// User Model for Admin Portal
///
/// Represents a system user with role and permissions
class User {
  final String id;
  final String email;
  final String name;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? phoneNumber;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.lastLoginAt,
    this.phoneNumber,
    this.avatarUrl,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    String? phoneNumber,
    String? avatarUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}

/// User Role
enum UserRole {
  admin('Admin', 'Full system access'),
  manager('Manager', 'Manage operations and staff'),
  waiter('Waiter', 'Take orders and serve tables'),
  kitchen('Kitchen', 'Manage kitchen operations'),
  delivery('Delivery', 'Manage deliveries'),
  cashier('Cashier', 'Process payments');

  final String label;
  final String description;

  const UserRole(this.label, this.description);
}
