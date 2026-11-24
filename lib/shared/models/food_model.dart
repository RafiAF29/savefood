class FoodCategoryModel {
  final int id;
  final String name;
  final String? icon;
  final int foodListingsCount;

  FoodCategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.foodListingsCount = 0,
  });

  factory FoodCategoryModel.fromJson(Map<String, dynamic> json) {
    return FoodCategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      foodListingsCount: json['food_listings_count'] ?? 0,
    );
  }
}

class FoodListingModel {
  final int id;
  final int merchantId;
  final int categoryId;
  final String name;
  final String? description;
  final double originalPrice;
  final double discountedPrice;
  final int stock;
  final String? image;
  final String? allergenInfo;
  final DateTime pickupDeadline;
  final bool isActive;
  final FoodCategoryModel? category;
  final FoodMerchantInfo? merchant;

  FoodListingModel({
    required this.id,
    required this.merchantId,
    required this.categoryId,
    required this.name,
    this.description,
    required this.originalPrice,
    required this.discountedPrice,
    required this.stock,
    this.image,
    this.allergenInfo,
    required this.pickupDeadline,
    required this.isActive,
    this.category,
    this.merchant,
  });

  int get discountPercentage {
    if (originalPrice <= 0) return 0;
    return ((1 - discountedPrice / originalPrice) * 100).round();
  }

  bool get isExpired => pickupDeadline.isBefore(DateTime.now());

  String get pickupTimeLeft {
    final diff = pickupDeadline.difference(DateTime.now());
    if (diff.isNegative) return 'Expired';
    if (diff.inHours > 0) return '${diff.inHours}h left';
    return '${diff.inMinutes}m left';
  }

  factory FoodListingModel.fromJson(Map<String, dynamic> json) {
    return FoodListingModel(
      id: json['id'],
      merchantId: json['merchant_id'],
      categoryId: json['category_id'],
      name: json['name'],
      description: json['description'],
      originalPrice: double.parse(json['original_price'].toString()),
      discountedPrice: double.parse(json['discounted_price'].toString()),
      stock: json['stock'],
      image: json['image'],
      allergenInfo: json['allergen_info'],
      pickupDeadline: DateTime.parse(json['pickup_deadline']),
      isActive: json['is_active'] ?? true,
      category: json['category'] != null
          ? FoodCategoryModel.fromJson(json['category'])
          : null,
      merchant: json['merchant'] != null
          ? FoodMerchantInfo.fromJson(json['merchant'])
          : null,
    );
  }
}

class FoodMerchantInfo {
  final int id;
  final String name;
  final String? businessName;
  final String? address;
  final bool isVerified;

  FoodMerchantInfo({
    required this.id,
    required this.name,
    this.businessName,
    this.address,
    this.isVerified = false,
  });

  factory FoodMerchantInfo.fromJson(Map<String, dynamic> json) {
    final profile = json['merchant_profile'];
    return FoodMerchantInfo(
      id: json['id'],
      name: json['name'],
      businessName: profile?['business_name'],
      address: profile?['address'],
      isVerified: profile?['is_verified'] ?? false,
    );
  }
}
