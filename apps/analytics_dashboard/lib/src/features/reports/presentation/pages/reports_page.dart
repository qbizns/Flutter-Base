import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Reports Generation Page
///
/// Features:
/// - Report template selection
/// - Date range picker
/// - Export options (PDF, Excel, CSV)
/// - Scheduled reports
/// - Report history
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Default to last 30 days
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Generate Report'),
            Tab(text: 'Report History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGenerateTab(theme),
          _buildHistoryTab(theme),
        ],
      ),
    );
  }

  Widget _buildGenerateTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Date Range Selection
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.date_range,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Report Period',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _selectDateRange(context),
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _selectedDateRange != null
                        ? '${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}'
                        : 'Select Date Range',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Today'),
                      onSelected: (selected) => _setQuickRange(0),
                    ),
                    FilterChip(
                      label: const Text('Last 7 Days'),
                      onSelected: (selected) => _setQuickRange(7),
                    ),
                    FilterChip(
                      label: const Text('Last 30 Days'),
                      selected: true,
                      onSelected: (selected) => _setQuickRange(30),
                    ),
                    FilterChip(
                      label: const Text('This Month'),
                      onSelected: (selected) => _setQuickRange(-1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Report Templates
        Text(
          'Report Templates',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildReportTemplate(
          theme,
          'Sales Report',
          'Comprehensive sales analysis with revenue, orders, and trends',
          Icons.attach_money,
          Colors.green,
          ['PDF', 'Excel', 'CSV'],
        ),
        const SizedBox(height: 12),
        _buildReportTemplate(
          theme,
          'Product Performance',
          'Best sellers, category breakdown, and profitability analysis',
          Icons.inventory,
          Colors.blue,
          ['PDF', 'Excel', 'CSV'],
        ),
        const SizedBox(height: 12),
        _buildReportTemplate(
          theme,
          'Customer Insights',
          'Customer segments, lifetime value, and behavior patterns',
          Icons.people,
          Colors.purple,
          ['PDF', 'Excel'],
        ),
        const SizedBox(height: 12),
        _buildReportTemplate(
          theme,
          'Inventory Report',
          'Stock levels, low stock alerts, and reorder suggestions',
          Icons.warehouse,
          Colors.orange,
          ['PDF', 'Excel', 'CSV'],
        ),
        const SizedBox(height: 12),
        _buildReportTemplate(
          theme,
          'Financial Summary',
          'Revenue, expenses, profit margins, and financial metrics',
          Icons.account_balance,
          Colors.indigo,
          ['PDF', 'Excel'],
        ),
        const SizedBox(height: 12),
        _buildReportTemplate(
          theme,
          'Employee Performance',
          'Staff productivity, sales by employee, and attendance',
          Icons.badge,
          Colors.teal,
          ['PDF', 'Excel'],
        ),
        const SizedBox(height: 24),

        // Scheduled Reports
        Text(
          'Scheduled Reports',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.green),
                ),
                title: const Text('Weekly Sales Report'),
                subtitle: const Text('Every Monday at 9:00 AM'),
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.blue),
                ),
                title: const Text('Monthly Financial Summary'),
                subtitle: const Text('First day of month at 8:00 AM'),
                trailing: Switch(value: true, onChanged: (value) {}),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.schedule, color: Colors.orange),
                ),
                title: const Text('Daily Inventory Report'),
                subtitle: const Text('Every day at 6:00 PM'),
                trailing: Switch(value: false, onChanged: (value) {}),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _showScheduleDialog(context),
          icon: const Icon(Icons.add),
          label: const Text('Add Scheduled Report'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab(ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Quick Stats
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.description, size: 32, color: Colors.blue),
                      const SizedBox(height: 8),
                      Text(
                        '42',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        'Total Reports',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.calendar_today, size: 32, color: Colors.green),
                      const SizedBox(height: 8),
                      Text(
                        '8',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        'This Month',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Report History
        Text(
          'Recent Reports',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildReportHistoryItem(
          theme,
          'Sales Report',
          'Nov 01 - Nov 10, 2025',
          DateTime.now().subtract(const Duration(hours: 2)),
          'PDF',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildReportHistoryItem(
          theme,
          'Product Performance',
          'Oct 01 - Oct 31, 2025',
          DateTime.now().subtract(const Duration(days: 1)),
          'Excel',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildReportHistoryItem(
          theme,
          'Customer Insights',
          'Oct 01 - Oct 31, 2025',
          DateTime.now().subtract(const Duration(days: 2)),
          'PDF',
          Colors.purple,
        ),
        const SizedBox(height: 12),
        _buildReportHistoryItem(
          theme,
          'Financial Summary',
          'Sep 01 - Sep 30, 2025',
          DateTime.now().subtract(const Duration(days: 8)),
          'PDF',
          Colors.indigo,
        ),
        const SizedBox(height: 12),
        _buildReportHistoryItem(
          theme,
          'Inventory Report',
          'Nov 01 - Nov 10, 2025',
          DateTime.now().subtract(const Duration(days: 3)),
          'CSV',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildReportHistoryItem(
          theme,
          'Sales Report',
          'Oct 24 - Oct 31, 2025',
          DateTime.now().subtract(const Duration(days: 10)),
          'PDF',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildReportTemplate(
    ThemeData theme,
    String title,
    String description,
    IconData icon,
    Color color,
    List<String> exportFormats,
  ) {
    return Card(
      child: InkWell(
        onTap: () => _showExportDialog(context, title, exportFormats),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: exportFormats
                          .map((format) => Chip(
                                label: Text(format),
                                labelStyle: const TextStyle(fontSize: 11),
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportHistoryItem(
    ThemeData theme,
    String title,
    String period,
    DateTime generatedAt,
    String format,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            format == 'PDF' ? Icons.picture_as_pdf :
            format == 'Excel' ? Icons.table_chart : Icons.text_snippet,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(period),
            Text(
              'Generated ${_formatTimeAgo(generatedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Downloading $title...')),
                );
              },
              tooltip: 'Download',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share options...')),
                );
              },
              tooltip: 'Share',
            ),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _setQuickRange(int days) {
    setState(() {
      if (days == 0) {
        // Today
        _selectedDateRange = DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now(),
        );
      } else if (days == -1) {
        // This month
        final now = DateTime.now();
        _selectedDateRange = DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: now,
        );
      } else {
        // Last N days
        _selectedDateRange = DateTimeRange(
          start: DateTime.now().subtract(Duration(days: days)),
          end: DateTime.now(),
        );
      }
    });
  }

  void _showExportDialog(
    BuildContext context,
    String reportTitle,
    List<String> formats,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export $reportTitle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Period: ${_selectedDateRange != null ? '${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}' : 'Not selected'}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            const Text('Select export format:'),
            const SizedBox(height: 16),
            ...formats.map((format) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Generating $reportTitle as $format...'),
                        ),
                      );
                    },
                    icon: Icon(
                      format == 'PDF' ? Icons.picture_as_pdf :
                      format == 'Excel' ? Icons.table_chart : Icons.text_snippet,
                    ),
                    label: Text('Export as $format'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Report'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Report Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'sales', child: Text('Sales Report')),
                  DropdownMenuItem(value: 'product', child: Text('Product Performance')),
                  DropdownMenuItem(value: 'customer', child: Text('Customer Insights')),
                  DropdownMenuItem(value: 'inventory', child: Text('Inventory Report')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                ],
                onChanged: (value) {},
              ),
              const SizedBox(height: 16),
              const TextField(
                decoration: InputDecoration(
                  labelText: 'Email Recipients',
                  border: OutlineInputBorder(),
                  hintText: 'email@example.com',
                ),
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
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report scheduled successfully')),
              );
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inHours < 1) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(dateTime);
    }
  }
}
