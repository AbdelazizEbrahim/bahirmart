class User {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String image;
  final bool isBanned;
  final BanReason? banReason;
  final DateTime? bannedAt;
  final String? bannedBy;
  final bool isEmailVerified;
  final Address? address;
  final String? phoneNumber;
  final bool isDeleted;
  final DateTime? trashDate;
  final String approvalStatus;
  final RejectionReason? rejectionReason;
  final String? approvedBy;
  final MerchantDetails? merchantDetails;
  final String? otp;
  final DateTime? otpExpires;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    required this.image,
    required this.isBanned,
    this.banReason,
    this.bannedAt,
    this.bannedBy,
    required this.isEmailVerified,
    this.address,
    this.phoneNumber,
    required this.isDeleted,
    this.trashDate,
    required this.approvalStatus,
    this.rejectionReason,
    this.approvedBy,
    this.merchantDetails,
    this.otp,
    this.otpExpires,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'customer',
      image: json['image'] ?? '',
      isBanned: json['isBanned'] ?? false,
      banReason: json['banReason'] != null ? BanReason.fromJson(json['banReason']) : null,
      bannedAt: json['bannedAt'] != null ? DateTime.parse(json['bannedAt']) : null,
      bannedBy: json['bannedBy'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      phoneNumber: json['phoneNumber'],
      isDeleted: json['isDeleted'] ?? false,
      trashDate: json['trashDate'] != null ? DateTime.parse(json['trashDate']) : null,
      approvalStatus: json['approvalStatus'] ?? 'pending',
      rejectionReason: json['rejectionReason'] != null ? RejectionReason.fromJson(json['rejectionReason']) : null,
      approvedBy: json['approvedBy'],
      merchantDetails: json['merchantDetails'] != null ? MerchantDetails.fromJson(json['merchantDetails']) : null,
      otp: json['otp'],
      otpExpires: json['otpExpires'] != null ? DateTime.parse(json['otpExpires']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
      'image': image,
      'isBanned': isBanned,
      'banReason': banReason?.toJson(),
      'bannedAt': bannedAt?.toIso8601String(),
      'bannedBy': bannedBy,
      'isEmailVerified': isEmailVerified,
      'address': address?.toJson(),
      'phoneNumber': phoneNumber,
      'isDeleted': isDeleted,
      'trashDate': trashDate?.toIso8601String(),
      'approvalStatus': approvalStatus,
      'rejectionReason': rejectionReason?.toJson(),
      'approvedBy': approvedBy,
      'merchantDetails': merchantDetails?.toJson(),
      'otp': otp,
      'otpExpires': otpExpires?.toIso8601String(),
    };
  }
}

class Address {
  final String? state;
  final String? city;

  Address({this.state, this.city});

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

class MerchantDetails {
  final String? tinNumber;
  final String? uniqueTinNumber;
  final String? nationalId;
  final Account? account;

  MerchantDetails({
    this.tinNumber,
    this.uniqueTinNumber,
    this.nationalId,
    this.account,
  });

  factory MerchantDetails.fromJson(Map<String, dynamic> json) {
    return MerchantDetails(
      tinNumber: json['tinNumber'],
      uniqueTinNumber: json['uniqueTinNumber'],
      nationalId: json['nationalId'],
      account: json['account'] != null ? Account.fromJson(json['account']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tinNumber': tinNumber,
      'uniqueTinNumber': uniqueTinNumber,
      'nationalId': nationalId,
      'account': account?.toJson(),
    };
  }
}

class Account {
  final String? name;
  final String? number;
  final String? bankCode;

  Account({this.name, this.number, this.bankCode});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      name: json['name'],
      number: json['number'],
      bankCode: json['bankCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'number': number,
      'bankCode': bankCode,
    };
  }
}

class RejectionReason {
  final String? reason;
  final String? description;

  RejectionReason({this.reason, this.description});

  factory RejectionReason.fromJson(Map<String, dynamic> json) {
    return RejectionReason(
      reason: json['reason'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'description': description,
    };
  }
}

class BanReason {
  final String reason;
  final String description;

  BanReason({required this.reason, required this.description});

  factory BanReason.fromJson(Map<String, dynamic> json) {
    return BanReason(
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reason': reason,
      'description': description,
    };
  }
}