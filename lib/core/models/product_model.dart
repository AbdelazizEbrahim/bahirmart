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
  final double? kilogramPerPrice;
  final double? kilometerPerPrice;
  final bool isBanned;
  final BanReason? banReason;
  final DateTime? bannedAt;
  final bool isDeleted;
  final DateTime? trashDate;
  final DateTime createdAt;
  final Offer? offer;

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
    this.kilogramPerPrice,
    this.kilometerPerPrice,
    required this.isBanned,
    this.banReason,
    this.bannedAt,
    required this.isDeleted,
    this.trashDate,
    required this.createdAt,
    this.offer,
  });

  // Helper method to get the current price (considering offers)
  double get currentPrice {
    if (offer != null && offer!.isActive) {
      return offer!.price;
    }
    return price;
  }

  // Helper method to calculate delivery cost based on quantity
  double calculateDeliveryCost(int quantity) {
    switch (delivery) {
      case 'PERPIECE':
        return deliveryPrice * quantity;
      case 'PERKG':
        return kilogramPerPrice != null ? kilogramPerPrice! * quantity : deliveryPrice * quantity;
      case 'PERKM':
        return kilometerPerPrice != null ? kilometerPerPrice! * quantity : deliveryPrice * quantity;
      case 'FREE':
      default:
        return 0;
    }
  }

  // Helper method to check if there's an active offer
  bool get hasActiveOffer => offer != null && offer!.isActive;

  // Helper method to get the discount percentage
  double get discountPercentage {
    if (hasActiveOffer) {
      return ((price - offer!.price) / price) * 100;
    }
    return 0;
  }
  
  // Convert Product to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'merchantDetail': merchantDetail.toJson(),
      'productName': productName,
      'category': category.toJson(),
      'price': price,
      'quantity': quantity,
      'soldQuantity': soldQuantity,
      'description': description,
      'images': images,
      'variant': variant,
      'size': size,
      'brand': brand,
      'location': location.toJson(),
      'review': review.map((r) => r.toJson()).toList(),
      'delivery': delivery,
      'deliveryPrice': deliveryPrice,
      'kilogramPerPrice': kilogramPerPrice,
      'kilometerPerPrice': kilometerPerPrice,
      'isBanned': isBanned,
      'banReason': banReason?.toJson(),
      'bannedAt': bannedAt?.toIso8601String(),
      'isDeleted': isDeleted,
      'trashDate': trashDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'offer': offer?.toJson(),
    };
  }
  
  // Create Product from JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      merchantDetail: MerchantDetail.fromJson(json['merchantDetail']),
      productName: json['productName'],
      category: ProductCategory.fromJson(json['category']),
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      soldQuantity: json['soldQuantity'],
      description: json['description'],
      images: List<String>.from(json['images']),
      variant: List<String>.from(json['variant']),
      size: List<String>.from(json['size']),
      brand: json['brand'],
      location: Location.fromJson(json['location']),
      review: (json['review'] as List).map((r) => Review.fromJson(r)).toList(),
      delivery: json['delivery'],
      deliveryPrice: json['deliveryPrice'].toDouble(),
      kilogramPerPrice: json['kilogramPerPrice']?.toDouble(),
      kilometerPerPrice: json['kilometerPerPrice']?.toDouble(),
      isBanned: json['isBanned'],
      banReason: json['banReason'] != null ? BanReason.fromJson(json['banReason']) : null,
      bannedAt: json['bannedAt'] != null ? DateTime.parse(json['bannedAt']) : null,
      isDeleted: json['isDeleted'],
      trashDate: json['trashDate'] != null ? DateTime.parse(json['trashDate']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      offer: json['offer'] != null ? Offer.fromJson(json['offer']) : null,
    );
  }
}

class Offer {
  final double price;
  final DateTime? offerEndDate;

  Offer({required this.price, this.offerEndDate});

  bool get isActive {
    if (offerEndDate == null) return true;
    return DateTime.now().isBefore(offerEndDate!);
  }
  
  // Convert Offer to JSON
  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'offerEndDate': offerEndDate?.toIso8601String(),
    };
  }
  
  // Create Offer from JSON
  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      price: json['price'].toDouble(),
      offerEndDate: json['offerEndDate'] != null ? DateTime.parse(json['offerEndDate']) : null,
    );
  }
}

class ProductCategory {
  final String categoryId;
  final String categoryName;

  ProductCategory({required this.categoryId, required this.categoryName});
  
  // Convert ProductCategory to JSON
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }
  
  // Create ProductCategory from JSON
  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
    );
  }
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
  
  // Convert Review to JSON
  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'comment': comment,
      'rating': rating,
      'createdDate': createdDate.toIso8601String(),
    };
  }
  
  // Create Review from JSON
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      customerId: json['customerId'],
      comment: json['comment'],
      rating: json['rating'],
      createdDate: DateTime.parse(json['createdDate']),
    );
  }
}

class BanReason {
  final String reason;
  final String description;

  BanReason({required this.reason, required this.description});
  
  // Convert BanReason to JSON
  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'description': description,
    };
  }
  
  // Create BanReason from JSON
  factory BanReason.fromJson(Map<String, dynamic> json) {
    return BanReason(
      reason: json['reason'],
      description: json['description'],
    );
  }
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
  
  // Convert MerchantDetail to JSON
  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'merchantName': merchantName,
      'merchantEmail': merchantEmail,
    };
  }
  
  // Create MerchantDetail from JSON
  factory MerchantDetail.fromJson(Map<String, dynamic> json) {
    return MerchantDetail(
      merchantId: json['merchantId'],
      merchantName: json['merchantName'],
      merchantEmail: json['merchantEmail'],
    );
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({required this.type, required this.coordinates});
  
  // Convert Location to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
  
  // Create Location from JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'],
      coordinates: List<double>.from(json['coordinates']),
    );
  }
}