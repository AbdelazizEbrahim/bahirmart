class Notification {
  final String id;
  final String userId;
  final String title;
  final String description;
  final NotificationType type;
  final bool read;
  final NotificationData? data;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.type,
    required this.read,
    this.data,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'],
      userId: json['userId'],
      title: json['title'],
      description: json['description'],
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      read: json['read'] ?? false,
      data:
          json['data'] != null ? NotificationData.fromJson(json['data']) : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

enum NotificationType {
  bid,
  outbid,
  won,
  ending,
  system,
}

class NotificationData {
  final String? auctionId;
  final double? bidAmount;
  final String? bidderName;
  final String? bidderEmail;

  NotificationData({
    this.auctionId,
    this.bidAmount,
    this.bidderName,
    this.bidderEmail,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) {
    return NotificationData(
      auctionId: json['auctionId'],
      bidAmount: json['bidAmount']?.toDouble(),
      bidderName: json['bidderName'],
      bidderEmail: json['bidderEmail'],
    );
  }
}
