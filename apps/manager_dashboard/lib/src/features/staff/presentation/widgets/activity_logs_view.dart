import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../ui/theme/odoo_colors.dart';
import '../../../../ui/theme/odoo_typography.dart';
import '../../models/staff_models.dart';
import '../../providers/staff_providers.dart';

/// Activity Logs View - Audit trail of staff activities
class ActivityLogsView extends ConsumerStatefulWidget {
  const ActivityLogsView({super.key});

  @override
  ConsumerState<ActivityLogsView> createState() => _ActivityLogsViewState();
}

class _ActivityLogsViewState extends ConsumerState<ActivityLogsView> {
  ActivityType? _selectedActivityType;

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(activityLogsProvider);
    final filteredLogs = _filterLogs(logs);

    return Column(
      children: [
        // Filters
        _buildFilters(),

        // Logs List
        Expanded(
          child: filteredLogs.isEmpty
              ? _buildEmptyState()
              : _buildLogsList(filteredLogs),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      child: Row(
        children: [
          Text(
            '${_filterLogs(ref.read(activityLogsProvider)).length} activities',
            style: OdooTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _showActivityTypeFilter,
            icon: const Icon(Icons.filter_list),
            label: Text(
              _selectedActivityType != null
                  ? _getActivityTypeText(_selectedActivityType!)
                  : 'All Activities',
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: _selectedActivityType != null
                  ? OdooColors.primary.withOpacity(0.1)
                  : null,
            ),
          ),
          if (_selectedActivityType != null) ...[
            const SizedBox(width: OdooSpacing.md),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedActivityType = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Clear Filter'),
              style: TextButton.styleFrom(
                foregroundColor: OdooColors.danger,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogsList(List<ActivityLog> logs) {
    return ListView.builder(
      padding: const EdgeInsets.all(OdooSpacing.lg),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        return _buildLogCard(log);
      },
    );
  }

  Widget _buildLogCard(ActivityLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: OdooSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(OdooSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(OdooSpacing.sm),
              decoration: BoxDecoration(
                color: _getActivityTypeColor(log.type).withOpacity(0.1),
                borderRadius: BorderRadius.circular(OdooSpacing.radiusStandard),
              ),
              child: Icon(
                _getActivityTypeIcon(log.type),
                color: _getActivityTypeColor(log.type),
                size: OdooIconSizes.md,
              ),
            ),
            const SizedBox(width: OdooSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          log.description,
                          style: OdooTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: OdooSpacing.sm,
                          vertical: OdooSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: _getActivityTypeColor(log.type).withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(OdooSpacing.radiusStandard),
                        ),
                        child: Text(
                          _getActivityTypeText(log.type),
                          style: OdooTypography.labelSmall.copyWith(
                            color: _getActivityTypeColor(log.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: OdooSpacing.xs),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: OdooIconSizes.sm,
                        color: OdooColors.textSecondary,
                      ),
                      const SizedBox(width: OdooSpacing.xs),
                      Text(
                        log.staffName,
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: OdooSpacing.md),
                      Icon(
                        Icons.access_time,
                        size: OdooIconSizes.sm,
                        color: OdooColors.textSecondary,
                      ),
                      const SizedBox(width: OdooSpacing.xs),
                      Text(
                        _formatTimestamp(log.timestamp),
                        style: OdooTypography.bodySmall.copyWith(
                          color: OdooColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (log.metadata != null && log.metadata!.isNotEmpty) ...[
                    const SizedBox(height: OdooSpacing.sm),
                    Container(
                      padding: const EdgeInsets.all(OdooSpacing.sm),
                      decoration: BoxDecoration(
                        color: OdooColors.gray100,
                        borderRadius:
                            BorderRadius.circular(OdooSpacing.radiusStandard),
                      ),
                      child: Text(
                        'Details: ${log.metadata!.entries.map((e) => '${e.key}: ${e.value}').join(', ')}',
                        style: OdooTypography.bodySmall.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: OdooColors.gray400,
          ),
          const SizedBox(height: OdooSpacing.lg),
          Text(
            'No activity logs found',
            style: OdooTypography.titleLarge.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
          const SizedBox(height: OdooSpacing.sm),
          Text(
            'Activity logs will appear here',
            style: OdooTypography.bodyMedium.copyWith(
              color: OdooColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Filter Logic

  List<ActivityLog> _filterLogs(List<ActivityLog> logs) {
    if (_selectedActivityType == null) {
      return logs;
    }
    return logs.where((log) => log.type == _selectedActivityType).toList();
  }

  Future<void> _showActivityTypeFilter() async {
    final selected = await showDialog<ActivityType?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Filter by Activity Type'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('All Activities'),
          ),
          ...ActivityType.values.map((type) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, type),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: OdooSpacing.sm),
                child: Row(
                  children: [
                    Icon(
                      _getActivityTypeIcon(type),
                      color: _getActivityTypeColor(type),
                    ),
                    const SizedBox(width: OdooSpacing.md),
                    Text(_getActivityTypeText(type)),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );

    setState(() {
      _selectedActivityType = selected;
    });
  }

  // Helper Methods

  IconData _getActivityTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.login:
        return Icons.login;
      case ActivityType.logout:
        return Icons.logout;
      case ActivityType.orderCreated:
        return Icons.add_shopping_cart;
      case ActivityType.orderModified:
        return Icons.edit;
      case ActivityType.orderCancelled:
        return Icons.cancel;
      case ActivityType.refundProcessed:
        return Icons.undo;
      case ActivityType.productAdded:
        return Icons.add_box;
      case ActivityType.productModified:
        return Icons.edit_note;
      case ActivityType.settingsChanged:
        return Icons.settings;
      case ActivityType.staffAdded:
        return Icons.person_add;
      case ActivityType.staffModified:
        return Icons.person;
      case ActivityType.permissionChanged:
        return Icons.security;
    }
  }

  Color _getActivityTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.login:
      case ActivityType.staffAdded:
      case ActivityType.productAdded:
        return OdooColors.success;
      case ActivityType.logout:
      case ActivityType.orderCancelled:
        return OdooColors.warning;
      case ActivityType.refundProcessed:
      case ActivityType.permissionChanged:
        return OdooColors.danger;
      case ActivityType.orderCreated:
      case ActivityType.orderModified:
      case ActivityType.productModified:
      case ActivityType.staffModified:
      case ActivityType.settingsChanged:
        return OdooColors.primary;
    }
  }

  String _getActivityTypeText(ActivityType type) {
    return type.name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim();
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}
