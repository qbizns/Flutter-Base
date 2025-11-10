import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:notification_service/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(const ProviderScope(child: NotificationCenterApp()));
}

class NotificationCenterApp extends StatelessWidget {
  const NotificationCenterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartPOS Notification Center',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const NotificationCenterHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotificationCenterHome extends ConsumerStatefulWidget {
  const NotificationCenterHome({super.key});

  @override
  ConsumerState<NotificationCenterHome> createState() => _NotificationCenterHomeState();
}

class _NotificationCenterHomeState extends ConsumerState<NotificationCenterHome> {
  final NotificationService _notificationService = NotificationService();
  
  @override
  void initState() {
    super.initState();
    // Listen to notification stream
    _notificationService.notificationStream.listen((notification) {
      // Handle new notifications
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final notifications = _notificationService.notifications;
    final unreadCount = _notificationService.unreadCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Center'),
        actions: [
          if (unreadCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text('$unreadCount unread', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () async {
              await _notificationService.markAllAsRead();
              setState(() {});
            },
            tooltip: 'Mark all as read',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await _notificationService.clearAll();
              setState(() {});
            },
            tooltip: 'Clear all',
          ),
        ],
      ),
      body: notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No notifications', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: notification.isRead ? null : Colors.blue.shade50,
                  child: ListTile(
                    leading: _getNotificationIcon(notification.type),
                    title: Text(notification.title, style: TextStyle(fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold)),
                    subtitle: Text(notification.body),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        await _notificationService.deleteNotification(notification.id);
                        setState(() {});
                      },
                    ),
                    onTap: () async {
                      if (!notification.isRead) {
                        await _notificationService.markAsRead(notification.id);
                        setState(() {});
                      }
                    },
                  ),
                );
              },
            ),
    );
  }

  Icon _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return const Icon(Icons.shopping_cart, color: Colors.orange);
      case NotificationType.kitchen:
        return const Icon(Icons.restaurant, color: Colors.red);
      case NotificationType.delivery:
        return const Icon(Icons.local_shipping, color: Colors.blue);
      case NotificationType.reservation:
        return const Icon(Icons.event_seat, color: Colors.green);
      case NotificationType.inventory:
        return const Icon(Icons.inventory, color: Colors.purple);
      case NotificationType.staff:
        return const Icon(Icons.people, color: Colors.indigo);
      case NotificationType.customer:
        return const Icon(Icons.person, color: Colors.pink);
      case NotificationType.payment:
        return const Icon(Icons.payment, color: Colors.teal);
      case NotificationType.loyalty:
        return const Icon(Icons.star, color: Colors.amber);
      case NotificationType.marketing:
        return const Icon(Icons.campaign, color: Colors.deepPurple);
      case NotificationType.system:
        return const Icon(Icons.settings, color: Colors.grey);
      case NotificationType.alert:
        return const Icon(Icons.warning, color: Colors.red);
    }
  }
}
