import 'package:savefood/core/network/api_client.dart';
import 'package:savefood/shared/models/food_model.dart';

class FoodService {
  final ApiClient _api = ApiClient();

  Future<List<FoodCategoryModel>> getCategories() async {
    final response = await _api.get('/categories');
    final list = response['categories'] as List;
    return list.map((e) => FoodCategoryModel.fromJson(e)).toList();
  }

  Future<List<FoodListingModel>> getFoods({
    String? search,
    int? categoryId,
  }) async {
    var endpoint = '/foods';
    final params = <String>[];
    if (search != null && search.isNotEmpty) params.add('search=$search');
    if (categoryId != null) params.add('category_id=$categoryId');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';

    final response = await _api.get(endpoint);
    final list = response['foods'] as List;
    return list.map((e) => FoodListingModel.fromJson(e)).toList();
  }

  Future<List<FoodListingModel>> getFeatured() async {
    final response = await _api.get('/foods/featured');
    final list = response['foods'] as List;
    return list.map((e) => FoodListingModel.fromJson(e)).toList();
  }

  Future<FoodListingModel> getFoodDetail(int id) async {
    final response = await _api.get('/foods/$id');
    return FoodListingModel.fromJson(response['food']);
  }
}
