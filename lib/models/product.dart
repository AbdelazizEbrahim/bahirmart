class Product {
  final String id;
  final MerchantDetail merchantDetail;
  final String productName;
  final Category category;
  final double price;
  final int quantity;
  final int soldQuantity;
  final String description;
  final List<String> images;
  final List<String> variant;
  final List<String> size;
  final String brand;
  final Location location;
  final List<Review> review;
  final String delivery;
  final double deliveryPrice;
  final bool isBanned;
  final BanReason? banReason;
  final DateTime? bannedAt;
  final bool isDeleted;
  final DateTime? trashDate;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.merchantDetail,
    required this.productName,
    required this.category,
    required this.price,
    required this.quantity,
    this.soldQuantity = 0,
    required this.description,
    this.images = const [],
    this.variant = const [],
    this.size = const [],
    this.brand = 'Hand Made',
    required this.location,
    this.review = const [],
    required this.delivery,
    required this.deliveryPrice,
    this.isBanned = false,
    this.banReason,
    this.bannedAt,
    this.isDeleted = false,
    this.trashDate,
    required this.createdAt,
  });
}

class MerchantDetail {
  final String merchantId;
  final String merchantName;
  final String merchantEmail;

  MerchantDetail({
    required this.merchantId,
    required this.merchantName,
    required this.merchantEmail,
  });
}

class Category {
  final String categoryId;
  final String categoryName;

  Category({required this.categoryId, required this.categoryName});
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({this.type = 'Point', required this.coordinates});
}

class Review {
  final String customerId;
  final String comment;
  final int rating;
  final DateTime createdDate;

  Review({
    required this.customerId,
    required this.comment,
    required this.rating,
    required this.createdDate,
  });
}

class BanReason {
  final String? reason;
  final String? description;

  BanReason({this.reason, this.description});
}