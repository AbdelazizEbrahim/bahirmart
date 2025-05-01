import 'package:flutter/material.dart';

class Auction {
  final String id;
  final String auctionTitle;
  final String merchantName;
  final String category;
  final String description;
  final String condition;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> itemImg;
  final double startingPrice;
  final double reservedPrice;
  final double bidIncrement;
  final Map<String, String>? rejectionReason;
  final String status;
  final String adminApproval;
  final int paymentDuration;
  final int totalQuantity;
  final int remainingQuantity;
  final bool buyByParts;
  final DateTime createdAt;
  final DateTime updatedAt;

  Auction({
    required this.id,
    required this.auctionTitle,
    required this.merchantName,
    required this.category,
    required this.description,
    required this.condition,
    required this.startTime,
    required this.endTime,
    required this.itemImg,
    required this.startingPrice,
    required this.reservedPrice,
    required this.bidIncrement,
    this.rejectionReason,
    required this.status,
    required this.adminApproval,
    required this.paymentDuration,
    required this.totalQuantity,
    required this.remainingQuantity,
    required this.buyByParts,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['_id'] ?? '',
      auctionTitle: json['auctionTitle'] ?? '',
      merchantName: json['merchantName'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      condition: json['condition'] ?? '',
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      itemImg: List<String>.from(json['itemImg'] ?? []),
      startingPrice: (json['startingPrice'] ?? 0).toDouble(),
      reservedPrice: (json['reservedPrice'] ?? 0).toDouble(),
      bidIncrement: (json['bidIncrement'] ?? 1).toDouble(),
      rejectionReason: json['rejectionReason'] != null
          ? Map<String, String>.from(json['rejectionReason'])
          : null,
      status: json['status'] ?? 'pending',
      adminApproval: json['adminApproval'] ?? 'pending',
      paymentDuration: json['paymentDuration'] ?? 24,
      totalQuantity: json['totalQuantity'] ?? 1,
      remainingQuantity: json['remainingQuantity'] ?? 1,
      buyByParts: json['buyByParts'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'auctionTitle': auctionTitle,
      'merchantName': merchantName,
      'category': category,
      'description': description,
      'condition': condition,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'itemImg': itemImg,
      'startingPrice': startingPrice,
      'reservedPrice': reservedPrice,
      'bidIncrement': bidIncrement,
      'rejectionReason': rejectionReason,
      'status': status,
      'adminApproval': adminApproval,
      'paymentDuration': paymentDuration,
      'totalQuantity': totalQuantity,
      'remainingQuantity': remainingQuantity,
      'buyByParts': buyByParts,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isActive => status == 'active';
  bool get isEnded => status == 'ended';
  bool get isPending => status == 'pending';
  bool get isCancelled => status == 'cancelled';
  bool get isApproved => adminApproval == 'approved';
  bool get isRejected => adminApproval == 'rejected';
  bool get isPendingApproval => adminApproval == 'pending';

  Duration get timeRemaining {
    if (isEnded) return Duration.zero;
    final now = DateTime.now();
    if (now.isBefore(startTime)) {
      return startTime.difference(now);
    }
    return endTime.difference(now);
  }

  String get formattedTimeRemaining {
    final duration = timeRemaining;
    if (duration.inDays > 0) {
      return '${duration.inDays}d ${duration.inHours % 24}h';
    } else if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
} 