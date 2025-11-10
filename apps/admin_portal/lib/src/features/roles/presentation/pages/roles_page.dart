import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Permission
class Permission {
  final String id;
  final String name;
  final String description;
  final String category;

  const Permission({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
  });
}

/// Role with Permissions
class Role {
  final String id;
  final String name;
  final String description;
  final List<String> permissions;
  final int userCount;

  const Role({
    required this.id,
    required this.name,
    required this.description,
    required this.permissions,
    required this.userCount,
  });
}

/// Roles and Permissions Management Page
///
/// Features:
/// - Role list with permissions
/// - Create/edit/delete roles
/// - Assign permissions to roles
/// - View users per role
class RolesPage extends ConsumerStatefulWidget {
  const RolesPage({super.key});

  @override
  ConsumerState<RolesPage> createState() => _RolesPageState();
}

class _RolesPageState extends ConsumerState<RolesPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = _getMockRoles();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles & Permissions'),
      ),
      body: Row(
        children: [
          // Roles list
          Expanded(
            flex: 1,
            child: _buildRolesList(theme, roles),
          ),

          // Role details
          Expanded(
            flex: 2,
            child: _buildRoleDetails(theme, roles.first),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showRoleDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Role'),
      ),
    );
  }

  Widget _buildRolesList(ThemeData theme, List<Role> roles) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Roles',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: roles.length,
              itemBuilder: (context, index) {
                final role = roles[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.shield,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  title: Text(role.name),
                  subtitle: Text('${role.userCount} users'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete),
                          title: Text('Delete'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showRoleDialog(context, role: role);
                      } else if (value == 'delete') {
                        _showDeleteDialog(context, role);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDetails(ThemeData theme, Role role) {
    final permissions = _getMockPermissions();
    final rolePermissions = permissions.where(
      (p) => role.permissions.contains(p.id),
    ).toList();

    // Group permissions by category
    final groupedPermissions = <String, List<Permission>>{};
    for (final permission in rolePermissions) {
      groupedPermissions.putIfAbsent(permission.category, () => []);
      groupedPermissions[permission.category]!.add(permission);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.icon(
                  onPressed: () {
                    _showPermissionsDialog(context, role);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Permissions'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: groupedPermissions.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        entry.key,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...entry.value.map((permission) {
                      return Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          ),
                          title: Text(permission.name),
                          subtitle: Text(permission.description),
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleDialog(BuildContext context, {Role? role}) {
    final isEdit = role != null;
    final nameController = TextEditingController(text: role?.name);
    final descriptionController = TextEditingController(text: role?.description);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEdit ? 'Edit Role' : 'Add New Role'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Role Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(isEdit ? 'Role updated' : 'Role created')),
              );
              Navigator.pop(context);
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showPermissionsDialog(BuildContext context, Role role) {
    final permissions = _getMockPermissions();
    final selectedPermissions = Set<String>.from(role.permissions);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Edit Permissions: ${role.name}'),
          content: SizedBox(
            width: 600,
            height: 500,
            child: ListView.builder(
              itemCount: permissions.length,
              itemBuilder: (context, index) {
                final permission = permissions[index];
                final isSelected = selectedPermissions.contains(permission.id);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedPermissions.add(permission.id);
                      } else {
                        selectedPermissions.remove(permission.id);
                      }
                    });
                  },
                  title: Text(permission.name),
                  subtitle: Text(permission.description),
                  secondary: Chip(
                    label: Text(permission.category),
                    labelStyle: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Permissions updated')),
                );
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content: Text(
          'Are you sure you want to delete the "${role.name}" role? '
          '${role.userCount} users will need to be reassigned.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${role.name} deleted')),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  List<Role> _getMockRoles() {
    return [
      const Role(
        id: '1',
        name: 'Administrator',
        description: 'Full system access with all permissions',
        permissions: ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10'],
        userCount: 2,
      ),
      const Role(
        id: '2',
        name: 'Manager',
        description: 'Manage operations, staff, and reports',
        permissions: ['1', '2', '5', '6', '7', '8'],
        userCount: 5,
      ),
      const Role(
        id: '3',
        name: 'Staff',
        description: 'Basic operational access',
        permissions: ['1', '5', '6'],
        userCount: 15,
      ),
    ];
  }

  List<Permission> _getMockPermissions() {
    return const [
      Permission(
        id: '1',
        name: 'View Orders',
        description: 'View order information',
        category: 'Orders',
      ),
      Permission(
        id: '2',
        name: 'Manage Orders',
        description: 'Create, edit, and delete orders',
        category: 'Orders',
      ),
      Permission(
        id: '3',
        name: 'View Users',
        description: 'View user information',
        category: 'Users',
      ),
      Permission(
        id: '4',
        name: 'Manage Users',
        description: 'Create, edit, and delete users',
        category: 'Users',
      ),
      Permission(
        id: '5',
        name: 'View Products',
        description: 'View product catalog',
        category: 'Products',
      ),
      Permission(
        id: '6',
        name: 'Manage Products',
        description: 'Create, edit, and delete products',
        category: 'Products',
      ),
      Permission(
        id: '7',
        name: 'View Reports',
        description: 'Access reports and analytics',
        category: 'Reports',
      ),
      Permission(
        id: '8',
        name: 'Manage Settings',
        description: 'Configure system settings',
        category: 'Settings',
      ),
      Permission(
        id: '9',
        name: 'View Audit Logs',
        description: 'Access system audit logs',
        category: 'Security',
      ),
      Permission(
        id: '10',
        name: 'Manage Roles',
        description: 'Create and edit roles and permissions',
        category: 'Security',
      ),
    ];
  }
}
