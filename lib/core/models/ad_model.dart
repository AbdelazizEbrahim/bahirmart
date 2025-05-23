import 'package:bahirmart/core/models/product_model.dart';

class Ad {
  final String id;
  final Product product;
  final MerchantDetail merchantDetail;
  final DateTime startsAt;
  final DateTime endsAt;
  final double adPrice;
  final String txRef;
  final String approvalStatus;
  final String paymentStatus;
  final bool isActive;
  final bool isHome;
  final String adRegion;
  final Location location;

  Ad({
    required this.id,
    required this.product,
    required this.merchantDetail,
    required this.startsAt,
    required this.endsAt,
    required this.adPrice,
    required this.txRef,
    required this.approvalStatus,
    required this.paymentStatus,
    required this.isActive,
    required this.isHome,
    required this.adRegion,
    required this.location,
  });
  factory Ad.fromJson(Map<String, dynamic> json) {
    return Ad(
      id: json['_id'] ?? '',
      product: Product.fromJson(json['product'] ?? {}),
      merchantDetail: MerchantDetail.fromJson(json['merchantDetail'] ?? {}),
      startsAt: DateTime.tryParse(json['startsAt'] ?? '') ?? DateTime.now(),
      endsAt: DateTime.tryParse(json['endsAt'] ?? '') ?? DateTime.now(),
      adPrice:
          (json['adPrice'] is num) ? (json['adPrice'] as num).toDouble() : 0.0,
      txRef: json['txRef'] ?? '',
      approvalStatus: json['approvalStatus'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      isActive: json['isActive'] ?? false,
      isHome: json['isHome'] ?? false,
      adRegion: json['adRegion'] ?? '',
      location: Location.fromJson(json['location'] ?? {}),
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

  factory MerchantDetail.fromJson(Map<String, dynamic> json) {
    return MerchantDetail(
      merchantId: json['merchantId'] ?? '',
      merchantName: json['merchantName'] ?? '',
      merchantEmail: json['merchantEmail'] ?? '',
    );
  }
}

class Location {
  final String type;
  final List<double> coordinates;

  Location({
    required this.type,
    required this.coordinates,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      type: json['type'] ?? '',
      coordinates:
          List<double>.from(json['coordinates'].map((x) => x.toDouble())),
    );
  }
}
