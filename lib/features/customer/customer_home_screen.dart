import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/core/theme/app_typography.dart';
import 'package:savefood/features/authentication/auth_service.dart';
import 'package:savefood/features/authentication/login_screen.dart';
import 'package:savefood/features/food/food_service.dart';
import 'package:savefood/features/food/food_catalog_screen.dart';
import 'package:savefood/features/food/food_detail_screen.dart';
import 'package:savefood/shared/models/food_model.dart';
import 'package:savefood/shared/models/user_model.dart';
import 'package:savefood/shared/widgets/food_card.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final FoodService _foodService = FoodService();
  final AuthService _authService = AuthService();

  List<FoodCategoryModel> _categories = [];
  List<FoodListingModel> _featuredFoods = [];
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _foodService.getCategories(),
        _foodService.getFeatured(),
        _authService.getUser(),
      ]);

      setState(() {
        _categories = results[0] as List<FoodCategoryModel>;
        _featuredFoods = results[1] as List<FoodListingModel>;
        _user = results[2] as UserModel?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load data. Check your connection.';
        _isLoading = false;
      });
    }
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'rice_bowl':
        return Icons.rice_bowl;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'cookie':
        return Icons.cookie;
      case 'nutrition':
        return Icons.eco;
      case 'cake':
        return Icons.cake;
      default:
        return Icons.fastfood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator(color: AppColors.forestGreen))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.forestGreen,
                  child: CustomScrollView(
                    slivers: [
                      _buildHeader(),
                      _buildSearchBar(),
                      _buildCategories(),
                      _buildFeaturedHeader(),
                      _buildFeaturedGrid(),
                      const SliverPadding(
                          padding: EdgeInsets.only(bottom: 24)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: AppColors.secondaryText),
          const SizedBox(height: 16),
          Text(_error!, style: AppTypography.bodyMedium),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${_user?.name.split(' ').first ?? 'there'} 👋',
                  style: AppTypography.headingMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Rescue food near you',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.secondaryText),
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                await _authService.logout();
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.forestGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_outline,
                    color: AppColors.forestGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSearchBar() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const FoodCatalogScreen(),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppColors.secondaryText, size: 20),
              const SizedBox(width: 12),
              Text(
                'Search food...',
                style: AppTypography.bodyMedium
                    .copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildCategories() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text('Categories', style: AppTypography.headingSmall),
          ),
          SizedBox(
            height: 90,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FoodCatalogScreen(
                          initialCategoryId: cat.id,
                          categoryName: cat.name,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_getCategoryIcon(cat.icon),
                            size: 28, color: AppColors.forestGreen),
                        const SizedBox(height: 6),
                        Text(
                          cat.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildFeaturedHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Best Deals 🔥', style: AppTypography.headingSmall),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const FoodCatalogScreen(),
                  ),
                );
              },
              child: Text(
                'See all',
                style: AppTypography.labelSmall
                    .copyWith(color: AppColors.forestGreen),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildFeaturedGrid() {
    if (_featuredFoods.isEmpty) {
      return const SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text('No food available right now'),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.68,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final food = _featuredFoods[index];
            return FoodCard(
              name: food.name,
              merchantName:
                  food.merchant?.businessName ?? food.merchant?.name ?? '',
              originalPrice: food.originalPrice,
              discountedPrice: food.discountedPrice,
              discountPercentage: food.discountPercentage,
              stock: food.stock,
              pickupTimeLeft: food.pickupTimeLeft,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FoodDetailScreen(foodId: food.id),
                  ),
                );
              },
            );
          },
          childCount: _featuredFoods.length,
        ),
      ),
    );
  }
}
