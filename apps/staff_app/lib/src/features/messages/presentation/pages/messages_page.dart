import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Messages Page
///
/// Features:
/// - Team announcements
/// - Direct messages
/// - Group chats
/// - Important notices
/// - Read/unread status
class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock announcements
  final List<Announcement> _announcements = [
    Announcement(
      id: '1',
      title: 'New Menu Items',
      message: 'We\'re adding 3 new items to the menu starting next week. Please familiarize yourself with the ingredients and preparation.',
      from: 'Manager',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      priority: AnnouncementPriority.high,
      isRead: false,
    ),
    Announcement(
      id: '2',
      title: 'Staff Meeting',
      message: 'Reminder: Weekly staff meeting tomorrow at 10 AM in the break room.',
      from: 'Admin',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      priority: AnnouncementPriority.medium,
      isRead: true,
    ),
    Announcement(
      id: '3',
      title: 'Holiday Schedule',
      message: 'The schedule for the upcoming holiday weekend has been posted. Please check your shifts.',
      from: 'Manager',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      priority: AnnouncementPriority.low,
      isRead: true,
    ),
  ];

  // Mock messages
  final List<Message> _messages = [
    Message(
      id: '1',
      from: 'Sarah Johnson',
      message: 'Can you cover my shift on Friday?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      isRead: false,
      avatar: '👩',
    ),
    Message(
      id: '2',
      from: 'Kitchen Team',
      message: 'Running low on salmon, adjust menu accordingly',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      avatar: '👨‍🍳',
      isGroup: true,
    ),
    Message(
      id: '3',
      from: 'Mike Chen',
      message: 'Thanks for the help yesterday!',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
      avatar: '👨',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unreadCount = _messages.where((m) => !m.isRead).length +
        _announcements.where((a) => !a.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Messages'),
            if (unreadCount > 0)
              Text(
                '$unreadCount unread',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Messages'),
                  if (_messages.where((m) => !m.isRead).length > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_messages.where((m) => !m.isRead).length}',
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Announcements'),
                  if (_announcements.where((a) => !a.isRead).length > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_announcements.where((a) => !a.isRead).length}',
                        style: TextStyle(
                          color: theme.colorScheme.onError,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMessagesTab(theme),
          _buildAnnouncementsTab(theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewMessageDialog(context),
        icon: const Icon(Icons.edit),
        label: const Text('New Message'),
      ),
    );
  }

  Widget _buildMessagesTab(ThemeData theme) {
    if (_messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      itemCount: _messages.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final message = _messages[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: message.isGroup
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.primaryContainer,
            child: Text(
              message.avatar,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  message.from,
                  style: TextStyle(
                    fontWeight: message.isRead ? FontWeight.normal : FontWeight.bold,
                  ),
                ),
              ),
              if (message.isGroup)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Group',
                    style: TextStyle(
                      fontSize: 10,
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            message.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: message.isRead ? FontWeight.normal : FontWeight.w500,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatTimestamp(message.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (!message.isRead) ...[
                const SizedBox(height: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
          onTap: () => _openMessageThread(context, message),
        );
      },
    );
  }

  Widget _buildAnnouncementsTab(ThemeData theme) {
    if (_announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No announcements',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _announcements.length,
      itemBuilder: (context, index) {
        final announcement = _announcements[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildAnnouncementCard(theme, announcement),
        );
      },
    );
  }

  Widget _buildAnnouncementCard(ThemeData theme, Announcement announcement) {
    final priorityColor = _getPriorityColor(announcement.priority);

    return Card(
      child: InkWell(
        onTap: () => _openAnnouncement(context, announcement),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: priorityColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                announcement.title,
                                style: TextStyle(
                                  fontWeight: announcement.isRead
                                      ? FontWeight.w600
                                      : FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (!announcement.isRead)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'From: ${announcement.from}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatTimestamp(announcement.timestamp),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      announcement.priority.name.toUpperCase(),
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  announcement.message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(AnnouncementPriority priority) {
    switch (priority) {
      case AnnouncementPriority.high:
        return Colors.red;
      case AnnouncementPriority.medium:
        return Colors.orange;
      case AnnouncementPriority.low:
        return Colors.blue;
    }
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
      return DateFormat('MMM dd').format(timestamp);
    }
  }

  void _openMessageThread(BuildContext context, Message message) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(message.from),
          ),
          body: const Center(
            child: Text('Message thread view'),
          ),
        ),
      ),
    );
  }

  void _openAnnouncement(BuildContext context, Announcement announcement) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(announcement.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'From: ${announcement.from}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('MMM dd, yyyy HH:mm').format(announcement.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(announcement.message),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showNewMessageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Message'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'To',
                border: OutlineInputBorder(),
                hintText: 'Select recipient',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          ],
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
                const SnackBar(content: Text('Message sent')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

// Models
class Announcement {
  final String id;
  final String title;
  final String message;
  final String from;
  final DateTime timestamp;
  final AnnouncementPriority priority;
  final bool isRead;

  Announcement({
    required this.id,
    required this.title,
    required this.message,
    required this.from,
    required this.timestamp,
    required this.priority,
    required this.isRead,
  });
}

enum AnnouncementPriority {
  high,
  medium,
  low,
}

class Message {
  final String id;
  final String from;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String avatar;
  final bool isGroup;

  Message({
    required this.id,
    required this.from,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.avatar,
    this.isGroup = false,
  });
}
