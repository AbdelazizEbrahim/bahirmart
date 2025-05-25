import 'package:flutter/foundation.dart';

class User {
  final String id;
  final String fullName;
  final String email;
  final String password;
  final String role;
  final String? image;
  final bool isBanned;
  final String? bannedBy;
  final bool isEmailVerified;
  final String? phoneNumber;
  final bool isDeleted;
  final DateTime? trashDate;
  final String? otp;
  final DateTime? otpExpires;
  final String? stateName;
  final String? cityName;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.password,
    required this.role,
    this.image,
    required this.isBanned,
    this.bannedBy,
    required this.isEmailVerified,
    this.phoneNumber,
    required this.isDeleted,
    this.trashDate,
    this.otp,
    this.otpExpires,
    this.stateName,
    this.cityName,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      role: json['role'] ?? 'customer',
      image: json['image'] ?? '/default-avatar.png',
      isBanned: json['isBanned'] ?? false,
      bannedBy: json['bannedBy'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      phoneNumber: json['phoneNumber'],
      isDeleted: json['isDeleted'] ?? false,
      trashDate: json['trashDate'] != null ? DateTime.parse(json['trashDate']) : null,
      otp: json['otp'],
      otpExpires: json['otpExpires'] != null ? DateTime.parse(json['otpExpires']) : null,
      stateName: json['stateName'],
      cityName: json['cityName'],
    );
  }

  get address => null;

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
      'image': image,
      'isBanned': isBanned,
      'bannedBy': bannedBy,
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'isDeleted': isDeleted,
      'trashDate': trashDate?.toIso8601String(),
      'otp': otp,
      'otpExpires': otpExpires?.toIso8601String(),
      'stateName': stateName,
      'cityName': cityName,
    };
  }
}
