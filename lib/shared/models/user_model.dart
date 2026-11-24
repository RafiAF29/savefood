class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final MerchantProfileModel? merchantProfile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.merchantProfile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      merchantProfile: json['merchant_profile'] != null
          ? MerchantProfileModel.fromJson(json['merchant_profile'])
          : null,
    );
  }

  bool get isCustomer => role == 'customer';
  bool get isMerchant => role == 'merchant';
  bool get isAdmin => role == 'admin';
}

class MerchantProfileModel {
  final int id;
  final String businessName;
  final String? businessDescription;
  final String? address;
  final String? phone;
  final bool isVerified;

  MerchantProfileModel({
    required this.id,
    required this.businessName,
    this.businessDescription,
    this.address,
    this.phone,
    required this.isVerified,
  });

  factory MerchantProfileModel.fromJson(Map<String, dynamic> json) {
    return MerchantProfileModel(
      id: json['id'],
      businessName: json['business_name'],
      businessDescription: json['business_description'],
      address: json['address'],
      phone: json['phone'],
      isVerified: json['is_verified'] ?? false,
    );
  }
}

class AuthResponse {
  final String message;
  final UserModel user;
  final String token;

  AuthResponse({
    required this.message,
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      message: json['message'],
      user: UserModel.fromJson(json['user']),
      token: json['token'],
    );
  }
}
