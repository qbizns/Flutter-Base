import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Staff Management - Manage staff across all store locations
class StaffManagementPage extends ConsumerStatefulWidget {
  const StaffManagementPage({super.key});

  @override
  ConsumerState<StaffManagementPage> createState() => _StaffManagementPageState();
}

class _StaffManagementPageState extends ConsumerState<StaffManagementPage> {
  String _selectedStore = 'All';
  String _selectedRole = 'All';
  String _selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Mock staff data
    final staff = [
      StaffMember('EMP001', 'John Smith', 'Manager', 'Downtown', StaffStatus.active, 'john.smith@smartpos.com', '+1 (555) 111-2222', 85000, DateTime(2020, 3, 15)),
      StaffMember('EMP002', 'Sarah Johnson', 'Cashier', 'Downtown', StaffStatus.active, 'sarah.j@smartpos.com', '+1 (555) 222-3333', 45000, DateTime(2021, 6, 20)),
      StaffMember('EMP003', 'Mike Wilson', 'Kitchen Staff', 'Westside', StaffStatus.active, 'mike.w@smartpos.com', '+1 (555) 333-4444', 42000, DateTime(2019, 8, 10)),
      StaffMember('EMP004', 'Emily Davis', 'Server', 'Airport', StaffStatus.onLeave, 'emily.d@smartpos.com', '+1 (555) 444-5555', 38000, DateTime(2022, 1, 5)),
      StaffMember('EMP005', 'David Brown', 'Manager', 'Westside', StaffStatus.active, 'david.b@smartpos.com', '+1 (555) 555-6666', 82000, DateTime(2018, 11, 25)),
      StaffMember('EMP006', 'Lisa Anderson', 'Cashier', 'Airport', StaffStatus.active, 'lisa.a@smartpos.com', '+1 (555) 666-7777', 43000, DateTime(2021, 9, 12)),
      StaffMember('EMP007', 'Robert Taylor', 'Kitchen Staff', 'Brooklyn', StaffStatus.inactive, 'robert.t@smartpos.com', '+1 (555) 777-8888', 40000, DateTime(2020, 4, 18)),
      StaffMember('EMP008', 'Jennifer White', 'Server', 'Downtown', StaffStatus.active, 'jennifer.w@smartpos.com', '+1 (555) 888-9999', 39000, DateTime(2022, 7, 3)),
    ];

    // Apply filters
    final filteredStaff = staff.where((s) {
      if (_selectedStore != 'All' && s.store != _selectedStore) return false;
      if (_selectedRole != 'All' && s.role != _selectedRole) return false;
      if (_selectedStatus != 'All' && s.status.name != _selectedStatus.toLowerCase()) return false;
      return true;
    }).toList();

    final activeStaff = staff.where((s) => s.status == StaffStatus.active).length;
    final onLeave = staff.where((s) => s.status == StaffStatus.onLeave).length;
    final inactive = staff.where((s) => s.status == StaffStatus.inactive).length;
    final avgSalary = staff.where((s) => s.status == StaffStatus.active).fold<double>(0, (sum, s) => sum + s.salary) / activeStaff;

    return Scaffold(
      appBar: AppBar(title: const Text('Staff Management')),
      body: Column(
        children: [
          // Summary cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    color: theme.colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.people, color: theme.colorScheme.onPrimaryContainer, size: 20),
                              const SizedBox(width: 8),
                              Text('Active Staff', style: TextStyle(color: theme.colorScheme.onPrimaryContainer)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$activeStaff',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onPrimaryContainer),
                          ),
                          Text('Total employees', style: TextStyle(fontSize: 12, color: theme.colorScheme.onPrimaryContainer.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.orange.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.beach_access, color: Colors.orange.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('On Leave', style: TextStyle(color: Colors.orange.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$onLeave',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange.shade700),
                          ),
                          Text('Currently away', style: TextStyle(fontSize: 12, color: Colors.orange.shade700.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_off, color: Colors.grey.shade700, size: 20),
                              const SizedBox(width: 8),
                              Text('Inactive', style: TextStyle(color: Colors.grey.shade700)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$inactive',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                          ),
                          Text('Former employees', style: TextStyle(fontSize: 12, color: Colors.grey.shade700.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Card(
                    color: theme.colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.attach_money, color: theme.colorScheme.onSecondaryContainer, size: 20),
                              const SizedBox(width: 8),
                              Text('Avg Salary', style: TextStyle(color: theme.colorScheme.onSecondaryContainer)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${(avgSalary / 1000).toStringAsFixed(0)}k',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: theme.colorScheme.onSecondaryContainer),
                          ),
                          Text('Per year', style: TextStyle(fontSize: 12, color: theme.colorScheme.onSecondaryContainer.withOpacity(0.7))),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStore,
                    decoration: const InputDecoration(
                      labelText: 'Store',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Downtown', 'Westside', 'Airport', 'Brooklyn', 'Staten Is.']
                        .map((store) => DropdownMenuItem(value: store, child: Text(store)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStore = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Manager', 'Cashier', 'Kitchen Staff', 'Server']
                        .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: ['All', 'Active', 'OnLeave', 'Inactive']
                        .map((status) => DropdownMenuItem(value: status, child: Text(status.replaceAll('OnLeave', 'On Leave'))))
                        .toList(),
                    onChanged: (value) => setState(() => _selectedStatus = value!),
                  ),
                ),
              ],
            ),
          ),

          // Staff list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredStaff.length,
              itemBuilder: (context, index) {
                final member = filteredStaff[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: _getStatusColor(member.status).withOpacity(0.2),
                      child: Text(
                        member.name.split(' ').map((n) => n[0]).take(2).join(),
                        style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(member.status)),
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(member.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(member.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            member.status.name.toUpperCase().replaceAll('_', ' '),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(member.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text('${member.role} • ${member.store} • ${member.id}'),
                    trailing: Text(
                      '\$${(member.salary / 1000).toStringAsFixed(0)}k/yr',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildInfoRow(Icons.badge, 'Employee ID', member.id),
                            _buildInfoRow(Icons.person, 'Name', member.name),
                            _buildInfoRow(Icons.work, 'Role', member.role),
                            _buildInfoRow(Icons.store, 'Store', member.store),
                            _buildInfoRow(Icons.email, 'Email', member.email),
                            _buildInfoRow(Icons.phone, 'Phone', member.phone),
                            _buildInfoRow(Icons.attach_money, 'Salary', '\$${member.salary.toStringAsFixed(0)}/year'),
                            _buildInfoRow(Icons.calendar_today, 'Hire Date', '${member.hireDate.month}/${member.hireDate.day}/${member.hireDate.year}'),
                            _buildInfoRow(Icons.access_time, 'Tenure', '${DateTime.now().difference(member.hireDate).inDays ~/ 365} years'),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.schedule, size: 18),
                                    label: const Text('Schedule'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.history, size: 18),
                                    label: const Text('History'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add),
        label: const Text('Add Staff'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            flex: 2,
            child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(StaffStatus status) {
    switch (status) {
      case StaffStatus.active: return Colors.green;
      case StaffStatus.onLeave: return Colors.orange;
      case StaffStatus.inactive: return Colors.grey;
    }
  }
}

// Models
class StaffMember {
  final String id;
  final String name;
  final String role;
  final String store;
  final StaffStatus status;
  final String email;
  final String phone;
  final double salary;
  final DateTime hireDate;

  StaffMember(this.id, this.name, this.role, this.store, this.status, this.email, this.phone, this.salary, this.hireDate);
}

enum StaffStatus { active, onLeave, inactive }
