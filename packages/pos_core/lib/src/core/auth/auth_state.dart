import 'package:equatable/equatable.dart';

/// Authentication state representing the current user session.
class AuthState extends Equatable {
  const AuthState({
    this.userId,
    this.tenantId,
    this.branchId,
    this.email,
    this.name,
    this.phone,
    this.avatarUrl,
    this.roles = const [],
    this.permissions = const [],
    this.authToken,
    this.refreshToken,
    this.isAuthenticated = false,
  });

  final String? userId;
  final String? tenantId;
  final String? branchId;
  final String? email;
  final String? name;
  final String? phone;
  final String? avatarUrl;
  final List<String> roles;
  final List<String> permissions;
  final String? authToken;
  final String? refreshToken;
  final bool isAuthenticated;

  /// Empty/unauthenticated state
  factory AuthState.unauthenticated() => const AuthState();

  /// Authenticated state
  factory AuthState.authenticated({
    required String userId,
    required String authToken,
    String? tenantId,
    String? branchId,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    String? refreshToken,
    List<String> roles = const [],
    List<String> permissions = const [],
  }) {
    return AuthState(
      userId: userId,
      tenantId: tenantId,
      branchId: branchId,
      email: email,
      name: name,
      phone: phone,
      avatarUrl: avatarUrl,
      roles: roles,
      permissions: permissions,
      authToken: authToken,
      refreshToken: refreshToken,
      isAuthenticated: true,
    );
  }

  AuthState copyWith({
    String? userId,
    String? tenantId,
    String? branchId,
    String? email,
    String? name,
    String? phone,
    String? avatarUrl,
    List<String>? roles,
    List<String>? permissions,
    String? authToken,
    String? refreshToken,
    bool? isAuthenticated,
  }) {
    return AuthState(
      userId: userId ?? this.userId,
      tenantId: tenantId ?? this.tenantId,
      branchId: branchId ?? this.branchId,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roles: roles ?? this.roles,
      permissions: permissions ?? this.permissions,
      authToken: authToken ?? this.authToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        tenantId,
        branchId,
        email,
        name,
        phone,
        avatarUrl,
        roles,
        permissions,
        authToken,
        refreshToken,
        isAuthenticated,
      ];

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'tenantId': tenantId,
      'branchId': branchId,
      'email': email,
      'name': name,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'roles': roles,
      'permissions': permissions,
      'authToken': authToken,
      'refreshToken': refreshToken,
      'isAuthenticated': isAuthenticated,
    };
  }

  /// Create from JSON storage
  factory AuthState.fromJson(Map<String, dynamic> json) {
    return AuthState(
      userId: json['userId'] as String?,
      tenantId: json['tenantId'] as String?,
      branchId: json['branchId'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      roles: (json['roles'] as List<dynamic>?)?.cast<String>() ?? [],
      permissions:
          (json['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
      authToken: json['authToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
    );
  }
}
