
class Auction {
  final String? id;
  final String? auctionTitle;
  final String? merchantName;
  final String? category;
  final String? description;
  final String? condition;
  final DateTime? startTime;
  final DateTime? endTime;
  final List<String>? itemImg;
  final double? startingPrice;
  final double? reservedPrice;
  final double? bidIncrement;
  final Map<String, String>? rejectionReason;
  final String? status;
  final String? adminApproval;
  final int? paymentDuration;
  final int? totalQuantity;
  final int? remainingQuantity;
  final bool? buyByParts;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Auction({
    this.id,
    this.auctionTitle,
    this.merchantName,
    this.category,
    this.description,
    this.condition,
    this.startTime,
    this.endTime,
    this.itemImg,
    this.startingPrice,
    this.reservedPrice,
    this.bidIncrement,
    this.rejectionReason,
    this.status,
    this.adminApproval,
    this.paymentDuration,
    this.totalQuantity,
    this.remainingQuantity,
    this.buyByParts,
    this.createdAt,
    this.updatedAt,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      id: json['_id'] as String? ?? '',
      auctionTitle: json['auctionTitle'] as String? ?? '',
      merchantName: json['merchantName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      condition: json['condition'] as String? ?? '',
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'] as String)
          : null,
      endTime: json['endTime'] != null
          ? DateTime.tryParse(json['endTime'] as String)
          : null,
      itemImg: () {
        final img = json['itemImg'];
        if (img == null) return <String>[];
        if (img is String) return [img];
        if (img is List) return List<String>.from(img);
        return <String>[];
      }(),
      startingPrice: (json['startingPrice'] as num?)?.toDouble() ?? 0.0,
      reservedPrice: (json['reservedPrice'] as num?)?.toDouble() ?? 0.0,
      bidIncrement: (json['bidIncrement'] as num?)?.toDouble() ?? 1.0,
      rejectionReason: json['rejectionReason'] != null
          ? Map<String, String>.from(json['rejectionReason'] as Map)
          : null,
      status: json['status'] as String? ?? 'pending',
      adminApproval: json['adminApproval'] as String? ?? 'pending',
      paymentDuration: json['paymentDuration'] as int? ?? 24,
      totalQuantity: json['totalQuantity'] as int? ?? 1,
      remainingQuantity: json['remainingQuantity'] as int? ?? 1,
      buyByParts: json['buyByParts'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
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
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
    if (isEnded || endTime == null || startTime == null) return Duration.zero;
    final now = DateTime.now();
    if (now.isBefore(startTime!)) {
      return startTime!.difference(now);
    }
    return endTime!.difference(now);
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
