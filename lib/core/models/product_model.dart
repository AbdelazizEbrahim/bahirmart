class Product {
  final String id;
  final MerchantDetail merchantDetail;
  final String productName;
  final ProductCategory category;
  final double price;
  final int quantity;
  final int soldQuantity;
  final String description;
  final List<String>? images;
  final List<String>? variant;
  final List<String>? size;
  final String? brand;
  final Location location;
  final List<Review>? review;
  final String delivery;
  final double deliveryPrice;
  final double? kilogramPerPrice;
  final double? kilometerPerPrice;
  final bool isBanned;
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
    this.soldQuantity = 0,
    required this.description,
    this.images,
    this.variant,
    this.size,
    this.brand = 'Hand Made',
    required this.location,
    this.review,
    required this.delivery,
    required this.deliveryPrice,
    this.kilogramPerPrice,
    this.kilometerPerPrice,
    this.isBanned = false,
    this.isDeleted = false,
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
        return deliveryPrice * quantity * (kilogramPerPrice ?? 1);
      case 'PERKM':
        return deliveryPrice * quantity * (kilometerPerPrice ?? 20);
      case 'FREE':
        return 0;
      default:
        return 0;
    }
  }

  bool get hasActiveOffer => offer != null && offer!.isActive;

  double get discountPercentage {
    if (hasActiveOffer) {
      return ((price - offer!.price) / price) * 100;
    }
    return 0;
  }

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
      'review': review?.map((r) => r.toJson()).toList(),
      'delivery': delivery,
      'deliveryPrice': deliveryPrice,
      'kilogramPerPrice': kilogramPerPrice,
      'kilometerPerPrice': kilometerPerPrice,
      'isBanned': isBanned,
      'isDeleted': isDeleted,
      'trashDate': trashDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'offer': offer?.toJson(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? json['id'],
      merchantDetail: MerchantDetail.fromJson(json['merchantDetail']),
      productName: json['productName'],
      category: ProductCategory.fromJson(json['category']),
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      soldQuantity: json['soldQuantity'] ?? 0,
      description: json['description'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      variant:
          json['variant'] != null ? List<String>.from(json['variant']) : null,
      size: json['size'] != null ? List<String>.from(json['size']) : null,
      brand: json['brand'] ?? 'Hand Made',
      location: Location.fromJson(json['location']),
      review: json['review'] != null
          ? (json['review'] as List).map((r) => Review.fromJson(r)).toList()
          : null,
      delivery: json['delivery'],
      deliveryPrice: json['deliveryPrice'].toDouble(),
      kilogramPerPrice: json['kilogramPerPrice']?.toDouble(),
      kilometerPerPrice: json['kilometerPerPrice']?.toDouble(),
      isBanned: json['isBanned'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      trashDate:
          json['trashDate'] != null ? DateTime.parse(json['trashDate']) : null,
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

  Map<String, dynamic> toJson() {
    return {
      'price': price,
      'offerEndDate': offerEndDate?.toIso8601String(),
    };
  }

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      price: json['price'].toDouble(),
      offerEndDate: json['offerEndDate'] != null
          ? DateTime.parse(json['offerEndDate'])
          : null,
    );
  }
}

class ProductCategory {
  final String categoryId;
  final String categoryName;

  ProductCategory({required this.categoryId, required this.categoryName});

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
    };
  }

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

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'comment': comment,
      'rating': rating,
      'createdDate': createdDate.toIso8601String(),
    };
  }

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      customerId: json['customerId'],
      comment: json['comment'],
      rating: json['rating'],
      createdDate: DateTime.parse(json['createdDate']),
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

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'merchantName': merchantName,
      'merchantEmail': merchantEmail,
    };
  }

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

  Location({this.type = 'Point', required this.coordinates});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? 'Point',
      coordinates: List<double>.from(json['coordinates']),
    );
  }
}
