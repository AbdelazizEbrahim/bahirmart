class Product {
  final String id;
  final MerchantDetail merchantDetail;
  final String productName;
  final ProductCategory category;
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
    required this.soldQuantity,
    required this.description,
    required this.images,
    required this.variant,
    required this.size,
    required this.brand,
    required this.location,
    required this.review,
    required this.delivery,
    required this.deliveryPrice,
    required this.isBanned,
    this.banReason,
    this.bannedAt,
    required this.isDeleted,
    this.trashDate,
    required this.createdAt,
  });
}

class ProductCategory {
  final String categoryId;
  final String categoryName;

  ProductCategory({required this.categoryId, required this.categoryName});
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
  final String reason;
  final String description;

  BanReason({required this.reason, required this.description});
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

class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});
}