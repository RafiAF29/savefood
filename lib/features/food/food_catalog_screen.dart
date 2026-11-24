import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/core/theme/app_typography.dart';
import 'package:savefood/features/food/food_service.dart';
import 'package:savefood/features/food/food_detail_screen.dart';
import 'package:savefood/shared/models/food_model.dart';
import 'package:savefood/shared/widgets/food_card.dart';

class FoodCatalogScreen extends StatefulWidget {
  final int? initialCategoryId;
  final String? categoryName;

  const FoodCatalogScreen({
    super.key,
    this.initialCategoryId,
    this.categoryName,
  });

  @override
  State<FoodCatalogScreen> createState() => _FoodCatalogScreenState();
}

class _FoodCatalogScreenState extends State<FoodCatalogScreen> {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();

  List<FoodListingModel> _foods = [];
  List<FoodCategoryModel> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _loadCategories();
    _loadFoods();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await _foodService.getCategories();
      setState(() => _categories = cats);
    } catch (_) {}
  }

  Future<void> _loadFoods() async {
    setState(() => _isLoading = true);
    try {
      final foods = await _foodService.getFoods(
        search: _searchController.text.trim().isNotEmpty
            ? _searchController.text.trim()
            : null,
        categoryId: _selectedCategoryId,
      );
      setState(() {
        _foods = foods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        backgroundColor: AppColors.softCream,
        title: Text(
          widget.categoryName ?? 'Food Catalog',
          style: AppTypography.headingMedium,
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: TextField(
              controller: _searchController,
              onSubmitted: (_) => _loadFoods(),
              decoration: InputDecoration(
                hintText: 'Search food...',
                prefixIcon:
                    const Icon(Icons.search, color: AppColors.secondaryText),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _loadFoods();
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Category chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildChip('All', _selectedCategoryId == null, () {
                    setState(() => _selectedCategoryId = null);
                    _loadFoods();
                  });
                }
                final cat = _categories[index - 1];
                return _buildChip(
                  cat.name,
                  _selectedCategoryId == cat.id,
                  () {
                    setState(() => _selectedCategoryId = cat.id);
                    _loadFoods();
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Results
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.forestGreen))
                : _foods.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off,
                                size: 48, color: AppColors.secondaryText),
                            const SizedBox(height: 12),
                            Text('No food found',
                                style: AppTypography.bodyMedium),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.68,
                        ),
                        itemCount: _foods.length,
                        itemBuilder: (context, index) {
                          final food = _foods[index];
                          return FoodCard(
                            name: food.name,
                            merchantName: food.merchant?.businessName ??
                                food.merchant?.name ??
                                '',
                            originalPrice: food.originalPrice,
                            discountedPrice: food.discountedPrice,
                            discountPercentage: food.discountPercentage,
                            stock: food.stock,
                            pickupTimeLeft: food.pickupTimeLeft,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      FoodDetailScreen(foodId: food.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.forestGreen : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.forestGreen : AppColors.border,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? AppColors.white : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }
}
