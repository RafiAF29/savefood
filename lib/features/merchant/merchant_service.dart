import 'package:savefood/core/network/api_client.dart';
import 'package:savefood/shared/models/food_model.dart';

class MerchantDashboardStats {
  final int activeListings;
  final int totalListings;
  final int expiredListings;
  final int outOfStock;

  MerchantDashboardStats({
    required this.activeListings,
    required this.totalListings,
    required this.expiredListings,
    required this.outOfStock,
  });

  factory MerchantDashboardStats.fromJson(Map<String, dynamic> json) {
    return MerchantDashboardStats(
      activeListings: json['active_listings'] ?? 0,
      totalListings: json['total_listings'] ?? 0,
      expiredListings: json['expired_listings'] ?? 0,
      outOfStock: json['out_of_stock'] ?? 0,
    );
  }
}

class MerchantProfileData {
  final int id;
  final String? businessName;
  final String? businessDescription;
  final String? address;
  final String? phone;
  final bool isVerified;

  MerchantProfileData({
    required this.id,
    this.businessName,
    this.businessDescription,
    this.address,
    this.phone,
    required this.isVerified,
  });

  factory MerchantProfileData.fromJson(Map<String, dynamic> json) {
    return MerchantProfileData(
      id: json['id'],
      businessName: json['business_name'],
      businessDescription: json['business_description'],
      address: json['address'],
      phone: json['phone'],
      isVerified: json['is_verified'] ?? false,
    );
  }
}

class MerchantService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> getDashboard() async {
    return await _api.get('/merchant/dashboard', auth: true);
  }

  Future<List<FoodListingModel>> getMyListings({String? status, int page = 1}) async {
    var endpoint = '/merchant/foods?page=$page';
    if (status != null) {
      endpoint += '&status=$status';
    }

    final response = await _api.get(endpoint, auth: true);
    final List foods = response['foods'];
    return foods.map((f) => FoodListingModel.fromJson(f)).toList();
  }

  Future<Map<String, dynamic>> createFood({
    required int categoryId,
    required String name,
    required String description,
    required double originalPrice,
    required double discountedPrice,
    required int stock,
    String? allergenInfo,
    required String pickupDeadline,
    String? imagePath,
  }) async {
    final fields = {
      'category_id': categoryId.toString(),
      'name': name,
      'description': description,
      'original_price': originalPrice.toString(),
      'discounted_price': discountedPrice.toString(),
      'stock': stock.toString(),
      'pickup_deadline': pickupDeadline,
    };

    if (allergenInfo != null && allergenInfo.isNotEmpty) {
      fields['allergen_info'] = allergenInfo;
    }

    return await _api.multipart(
      '/merchant/foods',
      fields: fields,
      filePath: imagePath,
      fileField: 'image',
    );
  }

  Future<Map<String, dynamic>> updateFood({
    required int id,
    int? categoryId,
    String? name,
    String? description,
    double? originalPrice,
    double? discountedPrice,
    int? stock,
    String? allergenInfo,
    String? pickupDeadline,
    bool? isActive,
    String? imagePath,
  }) async {
    final fields = <String, String>{};

    if (categoryId != null) fields['category_id'] = categoryId.toString();
    if (name != null) fields['name'] = name;
    if (description != null) fields['description'] = description;
    if (originalPrice != null) fields['original_price'] = originalPrice.toString();
    if (discountedPrice != null) fields['discounted_price'] = discountedPrice.toString();
    if (stock != null) fields['stock'] = stock.toString();
    if (allergenInfo != null) fields['allergen_info'] = allergenInfo;
    if (pickupDeadline != null) fields['pickup_deadline'] = pickupDeadline;
    if (isActive != null) fields['is_active'] = isActive ? '1' : '0';

    return await _api.multipart(
      '/merchant/foods/$id',
      fields: fields,
      filePath: imagePath,
      fileField: 'image',
    );
  }

  Future<Map<String, dynamic>> deleteFood(int id) async {
    return await _api.delete('/merchant/foods/$id', auth: true);
  }

  Future<Map<String, dynamic>> toggleActive(int id) async {
    return await _api.patch('/merchant/foods/$id/toggle', auth: true);
  }

  Future<Map<String, dynamic>> getProfile() async {
    return await _api.get('/merchant/profile', auth: true);
  }

  Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? businessName,
    String? businessDescription,
    String? address,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (phone != null) body['phone'] = phone;
    if (businessName != null) body['business_name'] = businessName;
    if (businessDescription != null) body['business_description'] = businessDescription;
    if (address != null) body['address'] = address;

    return await _api.put('/merchant/profile', body: body, auth: true);
  }
}
