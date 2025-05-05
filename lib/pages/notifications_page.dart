import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bahirmart/core/models/notification_model.dart' as models;
import 'package:bahirmart/core/constants/app_colors.dart';
import 'package:bahirmart/main.dart';
import 'package:intl/intl.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<models.Notification> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    // Demo notifications
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    setState(() {
      notifications = [
        models.Notification(
          id: '1',
          userId: 'user1',
          title: 'New Bid Received',
          description: 'Someone placed a bid of \$120 on your auction',
          type: models.NotificationType.bid,
          read: false,
          data: models.NotificationData(
            auctionId: 'auction1',
            bidAmount: 120.0,
            bidderName: 'John Doe',
            bidderEmail: 'john@example.com',
          ),
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        models.Notification(
          id: '2',
          userId: 'user1',
          title: 'Auction Ending Soon',
          description: 'Your auction "Vintage Watch" ends in 1 hour',
          type: models.NotificationType.ending,
          read: true,
          data: models.NotificationData(
            auctionId: 'auction2',
          ),
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        ),
        models.Notification(
          id: '3',
          userId: 'user1',
          title: 'You Won!',
          description: 'Congratulations! You won the auction for "Rare Coin"',
          type: models.NotificationType.won,
          read: false,
          data: models.NotificationData(
            auctionId: 'auction3',
            bidAmount: 500.0,
          ),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];
      isLoading = false;
    });
  }

  Future<void> _markAsRead(String notificationId) async {
    setState(() {
      notifications = notifications.map((notification) {
        if (notification.id == notificationId) {
          return models.Notification(
            id: notification.id,
            userId: notification.userId,
            title: notification.title,
            description: notification.description,
            type: notification.type,
            read: true,
            data: notification.data,
            createdAt: notification.createdAt,
          );
        }
        return notification;
      }).toList();
    });
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      notifications = notifications.map((notification) {
        return models.Notification(
          id: notification.id,
          userId: notification.userId,
          title: notification.title,
          description: notification.description,
          type: notification.type,
          read: true,
          data: notification.data,
          createdAt: notification.createdAt,
        );
      }).toList();
    });
  }

  void _handleNotificationTap(models.Notification notification) {
    if (!notification.read) {
      _markAsRead(notification.id);
    }
    // TODO: Navigate to the relevant auction or content
    if (notification.data?.auctionId != null) {
      // Navigator.pushNamed(context, '/auction/${notification.data!.auctionId}');
    }
  }

  IconData _getNotificationIcon(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.bid:
        return Icons.gavel;
      case models.NotificationType.outbid:
        return Icons.arrow_upward;
      case models.NotificationType.won:
        return Icons.emoji_events;
      case models.NotificationType.ending:
        return Icons.timer;
      case models.NotificationType.system:
        return Icons.info;
    }
  }

  Color _getNotificationColor(models.NotificationType type) {
    switch (type) {
      case models.NotificationType.bid:
        return AppColors.primary;
      case models.NotificationType.outbid:
        return Colors.orange;
      case models.NotificationType.won:
        return Colors.green;
      case models.NotificationType.ending:
        return Colors.red;
      case models.NotificationType.system:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (userProvider.user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Notifications'),
        ),
        body: const Center(
          child: Text('Please sign in to view notifications'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_email_read),
            onPressed: _markAllAsRead,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(
                  child: Text('No notifications yet'),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              _getNotificationColor(notification.type),
                          child: Icon(
                            _getNotificationIcon(notification.type),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: notification.read
                                ? FontWeight.normal
                                : FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(notification.description),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('MMM d, y • h:mm a')
                                  .format(notification.createdAt),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        onTap: () => _handleNotificationTap(notification),
                      ),
                    );
                  },
                ),
    );
  }
}
