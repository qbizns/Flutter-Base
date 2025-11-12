/// Session History Page
/// Vodo-style page for viewing past POS sessions with Odoo-inspired list view
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_core/pos_core.dart';
import '../../application/session_providers.dart';
import '../../domain/models/pos_session.dart';
import 'session_details_page.dart';

/// Session history page with list of all past sessions
class SessionHistoryPage extends ConsumerStatefulWidget {
  const SessionHistoryPage({super.key});

  @override
  ConsumerState<SessionHistoryPage> createState() => _SessionHistoryPageState();
}

class _SessionHistoryPageState extends ConsumerState<SessionHistoryPage> {
  // Filter states
  SessionStatus? _statusFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // Sort state
  _SortColumn _sortColumn = _SortColumn.startedAt;
  bool _sortAscending = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _statusFilter = null;
      _startDate = null;
      _endDate = null;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: VodoColors.primary,
              onPrimary: VodoColors.textOnPrimary,
              surface: VodoColors.backgroundPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  List<PosSession> _filterAndSortSessions(List<PosSession> sessions) {
    var filtered = sessions;

    // Apply status filter
    if (_statusFilter != null) {
      filtered = filtered.where((s) => s.status == _statusFilter).toList();
    }

    // Apply date range filter
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((s) {
        return s.startedAt.isAfter(_startDate!) &&
            s.startedAt.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((s) {
        return s.number.toLowerCase().contains(query) ||
            s.userName.toLowerCase().contains(query) ||
            s.registerId.toLowerCase().contains(query);
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison;
      switch (_sortColumn) {
        case _SortColumn.number:
          comparison = a.number.compareTo(b.number);
          break;
        case _SortColumn.startedAt:
          comparison = a.startedAt.compareTo(b.startedAt);
          break;
        case _SortColumn.userName:
          comparison = a.userName.compareTo(b.userName);
          break;
        case _SortColumn.totalSales:
          comparison = a.totalSales.compareTo(b.totalSales);
          break;
        case _SortColumn.difference:
          final aDiff = a.actualClosingCash - a.expectedClosingCash;
          final bDiff = b.actualClosingCash - b.expectedClosingCash;
          comparison = aDiff.compareTo(bDiff);
          break;
      }
      return _sortAscending ? comparison : -comparison;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(sessionHistoryProvider);

    return Scaffold(
      backgroundColor: VodoColors.backgroundSecondary,
      appBar: AppBar(
        backgroundColor: VodoColors.primary,
        foregroundColor: VodoColors.textOnPrimary,
        title: const Text(
          'Session History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          // Refresh button
          IconButton(
            onPressed: () {
              ref.read(sessionHistoryProvider.notifier).refresh();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters section (Odoo-style)
          Container(
            color: VodoColors.backgroundPrimary,
            padding: VodoDimensions.paddingMd,
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by session number, cashier, or register...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                                _searchController.clear();
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: VodoColors.backgroundSecondary,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
                const SizedBox(height: VodoDimensions.spacingMd),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Date range filter
                      FilterChip(
                        label: Text(
                          _startDate != null && _endDate != null
                              ? '${_startDate!.month}/${_startDate!.day} - ${_endDate!.month}/${_endDate!.day}'
                              : 'Date Range',
                        ),
                        selected: _startDate != null,
                        onSelected: (_) => _selectDateRange(),
                        avatar: Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: _startDate != null
                              ? VodoColors.textOnPrimary
                              : VodoColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: VodoDimensions.spacingSm),

                      // Status filters
                      _buildStatusFilterChip(SessionStatus.open, 'Open'),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      _buildStatusFilterChip(SessionStatus.closed, 'Closed'),
                      const SizedBox(width: VodoDimensions.spacingSm),
                      _buildStatusFilterChip(SessionStatus.closing, 'Closing'),
                      const SizedBox(width: VodoDimensions.spacingSm),

                      // Clear filters button
                      if (_statusFilter != null ||
                          _startDate != null ||
                          _searchQuery.isNotEmpty)
                        TextButton.icon(
                          onPressed: _clearFilters,
                          icon: const Icon(Icons.clear_all, size: 16),
                          label: const Text('Clear Filters'),
                          style: TextButton.styleFrom(
                            foregroundColor: VodoColors.danger,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sessions list
          Expanded(
            child: historyState.when(
              data: (sessions) {
                final filteredSessions = _filterAndSortSessions(sessions);

                if (filteredSessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          size: 64,
                          color: VodoColors.textTertiary.withOpacity(0.5),
                        ),
                        const SizedBox(height: VodoDimensions.spacingMd),
                        Text(
                          sessions.isEmpty
                              ? 'No sessions found'
                              : 'No sessions match your filters',
                          style: VodoTextStyles.bodyLarge.copyWith(
                            color: VodoColors.textSecondary,
                          ),
                        ),
                        if (sessions.isNotEmpty) ...[
                          const SizedBox(height: VodoDimensions.spacingMd),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: VodoDimensions.paddingMd,
                  itemCount: filteredSessions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: VodoDimensions.spacingMd),
                  itemBuilder: (context, index) {
                    final session = filteredSessions[index];
                    return _SessionListItem(
                      session: session,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => SessionDetailsPage(
                              sessionId: session.id,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: VodoColors.danger,
                    ),
                    const SizedBox(height: VodoDimensions.spacingMd),
                    Text(
                      'Error loading session history',
                      style: VodoTextStyles.bodyLarge.copyWith(
                        color: VodoColors.danger,
                      ),
                    ),
                    const SizedBox(height: VodoDimensions.spacingSm),
                    Text(
                      error.toString(),
                      style: VodoTextStyles.bodySmall.copyWith(
                        color: VodoColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: VodoDimensions.spacingMd),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(sessionHistoryProvider.notifier).refresh();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilterChip(SessionStatus status, String label) {
    return FilterChip(
      label: Text(label),
      selected: _statusFilter == status,
      onSelected: (selected) {
        setState(() {
          _statusFilter = selected ? status : null;
        });
      },
      avatar: Icon(
        _getStatusIcon(status),
        size: 16,
        color: _statusFilter == status
            ? VodoColors.textOnPrimary
            : _getStatusColor(status),
      ),
    );
  }

  IconData _getStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.draft:
        return Icons.edit_note;
      case SessionStatus.open:
        return Icons.lock_open;
      case SessionStatus.closing:
        return Icons.pending;
      case SessionStatus.closed:
        return Icons.lock;
      case SessionStatus.cancelled:
        return Icons.cancel;
    }
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.draft:
        return VodoColors.textSecondary;
      case SessionStatus.open:
        return VodoColors.success;
      case SessionStatus.closing:
        return VodoColors.warning;
      case SessionStatus.closed:
        return VodoColors.info;
      case SessionStatus.cancelled:
        return VodoColors.danger;
    }
  }
}

/// Session list item widget (Odoo-style)
class _SessionListItem extends StatelessWidget {
  final PosSession session;
  final VoidCallback onTap;

  const _SessionListItem({
    required this.session,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (session.status) {
      case SessionStatus.draft:
        return VodoColors.textSecondary;
      case SessionStatus.open:
        return VodoColors.success;
      case SessionStatus.closing:
        return VodoColors.warning;
      case SessionStatus.closed:
        return VodoColors.info;
      case SessionStatus.cancelled:
        return VodoColors.danger;
    }
  }

  String _getStatusLabel() {
    switch (session.status) {
      case SessionStatus.draft:
        return 'DRAFT';
      case SessionStatus.open:
        return 'OPEN';
      case SessionStatus.closing:
        return 'CLOSING';
      case SessionStatus.closed:
        return 'CLOSED';
      case SessionStatus.cancelled:
        return 'CANCELLED';
    }
  }

  IconData _getStatusIcon() {
    switch (session.status) {
      case SessionStatus.draft:
        return Icons.edit_note;
      case SessionStatus.open:
        return Icons.lock_open;
      case SessionStatus.closing:
        return Icons.pending;
      case SessionStatus.closed:
        return Icons.lock;
      case SessionStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(DateTime start, DateTime? end) {
    final duration = (end ?? DateTime.now()).difference(start);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final difference = session.actualClosingCash - session.expectedClosingCash;
    final hasDifference = difference.abs() > 0.01;

    return Card(
      elevation: VodoDimensions.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: VodoDimensions.borderRadiusMd,
        side: BorderSide(
          color: session.status == SessionStatus.open
              ? VodoColors.success.withOpacity(0.3)
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: VodoDimensions.borderRadiusMd,
        child: Padding(
          padding: VodoDimensions.cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row: Session number + Status badge
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(),
                          color: _getStatusColor(),
                          size: VodoDimensions.iconSizeMd,
                        ),
                        const SizedBox(width: VodoDimensions.spacingSm),
                        Text(
                          session.number,
                          style: VodoTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      borderRadius: VodoDimensions.borderRadiusSm,
                    ),
                    child: Text(
                      _getStatusLabel(),
                      style: VodoTextStyles.badge,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: VodoDimensions.spacingSm),

              // Cashier and time info
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 14,
                    color: VodoColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.userName,
                    style: VodoTextStyles.bodySmall.copyWith(
                      color: VodoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: VodoDimensions.spacingMd),
                  Icon(
                    Icons.desktop_windows,
                    size: 14,
                    color: VodoColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    session.registerId,
                    style: VodoTextStyles.bodySmall.copyWith(
                      color: VodoColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: VodoDimensions.spacingXs),

              // Date and duration
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: VodoColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateTime(session.startedAt),
                    style: VodoTextStyles.bodySmall.copyWith(
                      color: VodoColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: VodoDimensions.spacingMd),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: VodoColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(session.startedAt, session.closedAt),
                    style: VodoTextStyles.bodySmall.copyWith(
                      color: VodoColors.textSecondary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: VodoDimensions.spacingMd),

              const Divider(),

              const SizedBox(height: VodoDimensions.spacingSm),

              // Financial summary (Odoo-style metrics)
              Row(
                children: [
                  // Sales
                  Expanded(
                    child: _buildMetric(
                      icon: Icons.attach_money,
                      label: 'Sales',
                      value: '\$${session.totalSales.toStringAsFixed(2)}',
                      color: VodoColors.success,
                    ),
                  ),

                  // Orders
                  Expanded(
                    child: _buildMetric(
                      icon: Icons.receipt,
                      label: 'Orders',
                      value: session.totalOrders.toString(),
                      color: VodoColors.info,
                    ),
                  ),

                  // Cash difference (if closed)
                  if (session.status == SessionStatus.closed)
                    Expanded(
                      child: _buildMetric(
                        icon: hasDifference
                            ? (difference > 0
                                ? Icons.trending_up
                                : Icons.trending_down)
                            : Icons.check_circle,
                        label: 'Difference',
                        value: difference == 0
                            ? 'Balanced'
                            : '\$${difference.toStringAsFixed(2)}',
                        color: hasDifference
                            ? (difference > 0
                                ? VodoColors.success
                                : VodoColors.danger)
                            : VodoColors.textSecondary,
                      ),
                    ),
                ],
              ),

              // Cash reconciliation summary (for closed sessions)
              if (session.status == SessionStatus.closed) ...[
                const SizedBox(height: VodoDimensions.spacingSm),
                Container(
                  padding: VodoDimensions.paddingSm,
                  decoration: BoxDecoration(
                    color: hasDifference
                        ? (difference > 0
                            ? VodoColors.success.withOpacity(0.1)
                            : VodoColors.danger.withOpacity(0.1))
                        : VodoColors.backgroundSecondary,
                    borderRadius: VodoDimensions.borderRadiusSm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Expected: \$${session.expectedClosingCash.toStringAsFixed(2)}',
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: VodoColors.textSecondary,
                        ),
                      ),
                      Text(
                        'Actual: \$${session.actualClosingCash.toStringAsFixed(2)}',
                        style: VodoTextStyles.bodySmall.copyWith(
                          color: VodoColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: VodoTextStyles.titleSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: VodoTextStyles.caption.copyWith(
            color: VodoColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Sort column enum
enum _SortColumn {
  number,
  startedAt,
  userName,
  totalSales,
  difference,
}
