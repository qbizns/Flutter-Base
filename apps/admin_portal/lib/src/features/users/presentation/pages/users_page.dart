import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/models/user.dart';

/// Users Management Page
///
/// Features:
/// - User list with search and filters
/// - Create/edit/delete users
/// - Role assignment
/// - Active/inactive status
/// - User details view
class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  String _searchQuery = '';
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final users = _getMockUsers();
    final filteredUsers = _filterUsers(users);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh users
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filters
          _buildSearchBar(theme),

          // Statistics cards
          _buildStatisticsCards(theme, users),

          const SizedBox(height: 16),

          // Users table
          Expanded(
            child: _buildUsersTable(theme, filteredUsers),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showUserDialog(context);
        },
        icon: const Icon(Icons.add),
        label: const Text('Add User'),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            value: _selectedRole,
            hint: const Text('Filter by Role'),
            items: [
              const DropdownMenuItem(value: null, child: Text('All Roles')),
              ...UserRole.values.map((role) {
                return DropdownMenuItem(
                  value: role.label,
                  child: Text(role.label),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedRole = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(ThemeData theme, List<User> users) {
    final totalUsers = users.length;
    final activeUsers = users.where((u) => u.isActive).length;
    final adminUsers = users.where((u) => u.role == 'Admin').length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              theme,
              'Total Users',
              '$totalUsers',
              Icons.people,
              theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Active Users',
              '$activeUsers',
              Icons.person,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              theme,
              'Admins',
              '$adminUsers',
              Icons.admin_panel_settings,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const Spacer(),
                Text(
                  value,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTable(ThemeData theme, List<User> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: theme.colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text('No users found'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Role')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Last Login')),
            DataColumn(label: Text('Actions')),
          ],
          rows: users.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(user.name),
                    ],
                  ),
                ),
                DataCell(Text(user.email)),
                DataCell(
                  Chip(
                    label: Text(user.role),
                    backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _getRoleColor(user.role),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Chip(
                    label: Text(user.isActive ? 'Active' : 'Inactive'),
                    backgroundColor: user.isActive
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: user.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    user.lastLoginAt != null
                        ? DateFormat('MMM d, y HH:mm').format(user.lastLoginAt!)
                        : 'Never',
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 20),
                        onPressed: () {
                          _showUserDialog(context, user: user);
                        },
                        tooltip: 'Edit',
                      ),
                      IconButton(
                        icon: Icon(
                          user.isActive ? Icons.block : Icons.check_circle,
                          size: 20,
                        ),
                        onPressed: () {
                          _toggleUserStatus(user);
                        },
                        tooltip: user.isActive ? 'Deactivate' : 'Activate',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 20),
                        onPressed: () {
                          _showDeleteDialog(context, user);
                        },
                        tooltip: 'Delete',
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showUserDialog(BuildContext context, {User? user}) {
    final isEdit = user != null;
    final nameController = TextEditingController(text: user?.name);
    final emailController = TextEditingController(text: user?.email);
    final phoneController = TextEditingController(text: user?.phoneNumber);
    String selectedRole = user?.role ?? UserRole.waiter.label;
    bool isActive = user?.isActive ?? true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(isEdit ? 'Edit User' : 'Add New User'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role.label,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(role.label),
                            Text(
                              role.description,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Active'),
                    subtitle: const Text('User can log in and access the system'),
                    value: isActive,
                    onChanged: (value) {
                      setState(() {
                        isActive = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Save user
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'User updated' : 'User created'),
                  ),
                );
                Navigator.pop(context);
              },
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${user.name} deleted')),
              );
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleUserStatus(User user) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          user.isActive
              ? '${user.name} deactivated'
              : '${user.name} activated',
        ),
      ),
    );
  }

  List<User> _filterUsers(List<User> users) {
    var filtered = users;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (_selectedRole != null) {
      filtered = filtered.where((user) => user.role == _selectedRole).toList();
    }

    return filtered;
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Admin':
        return Colors.red;
      case 'Manager':
        return Colors.orange;
      case 'Waiter':
        return Colors.blue;
      case 'Kitchen':
        return Colors.green;
      case 'Delivery':
        return Colors.purple;
      case 'Cashier':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  List<User> _getMockUsers() {
    final now = DateTime.now();
    return [
      User(
        id: '1',
        name: 'John Smith',
        email: 'john.smith@smartpos.com',
        role: 'Admin',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 365)),
        lastLoginAt: now.subtract(const Duration(hours: 2)),
        phoneNumber: '+1 234 567 8901',
      ),
      User(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah.j@smartpos.com',
        role: 'Manager',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 180)),
        lastLoginAt: now.subtract(const Duration(days: 1)),
        phoneNumber: '+1 234 567 8902',
      ),
      User(
        id: '3',
        name: 'Mike Wilson',
        email: 'mike.w@smartpos.com',
        role: 'Waiter',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 90)),
        lastLoginAt: now.subtract(const Duration(hours: 5)),
        phoneNumber: '+1 234 567 8903',
      ),
      User(
        id: '4',
        name: 'Emily Davis',
        email: 'emily.d@smartpos.com',
        role: 'Kitchen',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 60)),
        lastLoginAt: now.subtract(const Duration(minutes: 30)),
        phoneNumber: '+1 234 567 8904',
      ),
      User(
        id: '5',
        name: 'Tom Brown',
        email: 'tom.b@smartpos.com',
        role: 'Delivery',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 45)),
        lastLoginAt: now.subtract(const Duration(hours: 3)),
        phoneNumber: '+1 234 567 8905',
      ),
      User(
        id: '6',
        name: 'Lisa Anderson',
        email: 'lisa.a@smartpos.com',
        role: 'Cashier',
        isActive: true,
        createdAt: now.subtract(const Duration(days: 30)),
        lastLoginAt: now.subtract(const Duration(days: 2)),
        phoneNumber: '+1 234 567 8906',
      ),
      User(
        id: '7',
        name: 'David Martinez',
        email: 'david.m@smartpos.com',
        role: 'Waiter',
        isActive: false,
        createdAt: now.subtract(const Duration(days: 120)),
        lastLoginAt: now.subtract(const Duration(days: 30)),
        phoneNumber: '+1 234 567 8907',
      ),
    ];
  }
}
