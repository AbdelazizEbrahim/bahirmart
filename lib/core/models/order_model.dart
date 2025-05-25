
class Order {
  final String id;
  final CustomerDetail customerDetail;
  final MerchantDetail merchantDetail;
  final List<OrderProduct> products;
  final Auction? auction;
  final double totalPrice;
  String status;
  final String paymentStatus;
  final Location location;
  final String transactionRef;
  final DateTime orderDate;
  final String? refundReason;

  Order({
    required this.id,
    required this.customerDetail,
    required this.merchantDetail,
    required this.products,
    this.auction,
    required this.totalPrice,
    required this.status,
    required this.paymentStatus,
    required this.location,
    required this.transactionRef,
    required this.orderDate,
    this.refundReason,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'],
      customerDetail: CustomerDetail.fromJson(json['customerDetail']),
      merchantDetail: MerchantDetail.fromJson(json['merchantDetail']),
      products: (json['products'] as List)
          .map((product) => OrderProduct.fromJson(product))
          .toList(),
      auction: json['auction'] != null ? Auction.fromJson(json['auction']) : null,
      totalPrice: json['totalPrice'].toDouble(),
      status: json['status'],
      paymentStatus: json['paymentStatus'],
      location: Location.fromJson(json['location']),
      transactionRef: json['transactionRef'],
      orderDate: DateTime.parse(json['orderDate']),
      refundReason: json['refundReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerDetail': customerDetail.toJson(),
      'merchantDetail': merchantDetail.toJson(),
      'products': products.map((product) => product.toJson()).toList(),
      'auction': auction?.toJson(),
      'totalPrice': totalPrice,
      'status': status,
      'paymentStatus': paymentStatus,
      'location': location.toJson(),
      'transactionRef': transactionRef,
      'orderDate': orderDate.toIso8601String(),
      'refundReason': refundReason,
    };
  }
}

class CustomerDetail {
  final String customerId;
  final String customerName;
  final String phoneNumber;
  final String customerEmail;
  final Address address;

  CustomerDetail({
    required this.customerId,
    required this.customerName,
    required this.phoneNumber,
    required this.customerEmail,
    required this.address,
  });

  factory CustomerDetail.fromJson(Map<String, dynamic> json) {
    return CustomerDetail(
      customerId: json['customerId'],
      customerName: json['customerName'],
      phoneNumber: json['phoneNumber'],
      customerEmail: json['customerEmail'],
      address: Address.fromJson(json['address']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customerId': customerId,
      'customerName': customerName,
      'phoneNumber': phoneNumber,
      'customerEmail': customerEmail,
      'address': address.toJson(),
    };
  }
}

class Address {
  final String state;
  final String city;

  Address({
    required this.state,
    required this.city,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      state: json['state'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'city': city,
    };
  }
}

class MerchantDetail {
  final String merchantId;
  final String merchantName;
  final String merchantEmail;
  final String phoneNumber;
  final String accountName;
  final String accountNumber;
  final String? merchantReference;
  final String bankCode;

  MerchantDetail({
    required this.merchantId,
    required this.merchantName,
    required this.merchantEmail,
    required this.phoneNumber,
    required this.accountName,
    required this.accountNumber,
    this.merchantReference,
    required this.bankCode,
  });

  factory MerchantDetail.fromJson(Map<String, dynamic> json) {
    return MerchantDetail(
      merchantId: json['merchantId'],
      merchantName: json['merchantName'],
      merchantEmail: json['merchantEmail'],
      phoneNumber: json['phoneNumber'],
      accountName: json['account_name'],
      accountNumber: json['account_number'],
      merchantReference: json['merchantRefernce'],
      bankCode: json['bank_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchantId': merchantId,
      'merchantName': merchantName,
      'merchantEmail': merchantEmail,
      'phoneNumber': phoneNumber,
      'account_name': accountName,
      'account_number': accountNumber,
      'merchantRefernce': merchantReference,
      'bank_code': bankCode,
    };
  }
}

class OrderProduct {
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  final String delivery;
  final double deliveryPrice;

  OrderProduct({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.delivery,
    required this.deliveryPrice,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json) {
    return OrderProduct(
      productId: json['productId'],
      productName: json['productName'],
      quantity: json['quantity'],
      price: json['price'].toDouble(),
      delivery: json['delivery'],
      deliveryPrice: json['deliveryPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'delivery': delivery,
      'deliveryPrice': deliveryPrice,
    };
  }
}

class Auction {
  final String auctionId;
  final String delivery;
  final double deliveryPrice;

  Auction({
    required this.auctionId,
    required this.delivery,
    required this.deliveryPrice,
  });

  factory Auction.fromJson(Map<String, dynamic> json) {
    return Auction(
      auctionId: json['auctionId'],
      delivery: json['delivery'],
      deliveryPrice: json['deliveryPrice'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auctionId': auctionId,
      'delivery': delivery,
      'deliveryPrice': deliveryPrice,
    };
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
    final List<dynamic> rawCoordinates = json['coordinates'] as List<dynamic>;
    final List<double> coordinates = rawCoordinates.map((e) => (e as num).toDouble()).toList();
    
    return Location(
      type: json['type'],
      coordinates: coordinates,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
    };
  }
} 