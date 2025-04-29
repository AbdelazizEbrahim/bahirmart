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