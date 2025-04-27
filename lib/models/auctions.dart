class Auction {
  final String id;
  final String? auctionTitle;
  final String merchantName;
  final String category;
  final String? description;
  final String condition;
  final DateTime startTime;
  final DateTime endTime;
  final List<String> itemImg;
  final double startingPrice;
  final double reservedPrice;
  final double bidIncrement;
  final RejectionReason? rejectionReason;
  final String status;
  final String adminApproval;
  final int paymentDuration;
  final int totalQuantity;
  final int remainingQuantity;
  final bool buyByParts;
  final DateTime createdAt;

  Auction({
    required this.id,
    this.auctionTitle,
    required this.merchantName,
    required this.category,
    this.description,
    required this.condition,
    required this.startTime,
    required this.endTime,
    required this.itemImg,
    required this.startingPrice,
    required this.reservedPrice,
    this.bidIncrement = 1.0,
    this.rejectionReason,
    this.status = 'pending',
    this.adminApproval = 'pending',
    this.paymentDuration = 24,
    this.totalQuantity = 1,
    required this.remainingQuantity,
    this.buyByParts = false,
    required this.createdAt,
  });
}

class RejectionReason {
  final String? category;
  final String? description;

  RejectionReason({this.category, this.description});
}