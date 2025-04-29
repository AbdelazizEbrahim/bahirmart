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
}

class Address {
  final String? state;
  final String? city;

  Address({this.state, this.city});
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
}

class Account {
  final String? name;
  final String? number;
  final String? bankCode;

  Account({this.name, this.number, this.bankCode});
}

class RejectionReason {
  final String? reason;
  final String? description;

  RejectionReason({this.reason, this.description});
}

class BanReason {
  final String reason;
  final String description;

  BanReason({required this.reason, required this.description});
}