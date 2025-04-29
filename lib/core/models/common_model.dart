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