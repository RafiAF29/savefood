import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/core/theme/app_typography.dart';
import 'package:savefood/features/food/food_service.dart';
import 'package:savefood/shared/models/food_model.dart';
import 'package:savefood/shared/widgets/food_card.dart';

class FoodDetailScreen extends StatefulWidget {
  final int foodId;

  const FoodDetailScreen({super.key, required this.foodId});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  final FoodService _foodService = FoodService();
  FoodListingModel? _food;
  bool _isLoading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadFood();
  }

  Future<void> _loadFood() async {
    try {
      final food = await _foodService.getFoodDetail(widget.foodId);
      setState(() {
        _food = food;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.softCream,
        appBar: AppBar(backgroundColor: AppColors.softCream),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.forestGreen),
        ),
      );
    }

    if (_food == null) {
      return Scaffold(
        backgroundColor: AppColors.softCream,
        appBar: AppBar(backgroundColor: AppColors.softCream),
        body: Center(
          child: Text('Food not found', style: AppTypography.bodyMedium),
        ),
      );
    }

    final food = _food!;

    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: CustomScrollView(
        slivers: [
          // Image header
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.forestGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.forestGreen.withValues(alpha: 0.1),
                child: const Icon(Icons.restaurant,
                    size: 80, color: AppColors.forestGreen),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & discount
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.forestGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          food.category?.name ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${food.discountPercentage}%',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Name
                  Text(food.name, style: AppTypography.headingLarge),
                  const SizedBox(height: 8),

                  // Merchant
                  Row(
                    children: [
                      const Icon(Icons.store, size: 16, color: AppColors.secondaryText),
                      const SizedBox(width: 6),
                      Text(
                        food.merchant?.businessName ?? food.merchant?.name ?? '',
                        style: AppTypography.bodyMedium
                            .copyWith(color: AppColors.secondaryText),
                      ),
                      if (food.merchant?.isVerified == true) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.verified, size: 14, color: AppColors.forestGreen),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        PriceFormatter.format(food.discountedPrice),
                        style: AppTypography.headingLarge
                            .copyWith(color: AppColors.forestGreen),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          PriceFormatter.format(food.originalPrice),
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.secondaryText,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Info row
                  Row(
                    children: [
                      _infoChip(Icons.schedule, food.pickupTimeLeft),
                      const SizedBox(width: 12),
                      _infoChip(Icons.inventory_2, '${food.stock} left'),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  if (food.description != null && food.description!.isNotEmpty) ...[
                    Text('Description', style: AppTypography.headingSmall),
                    const SizedBox(height: 8),
                    Text(
                      food.description!,
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.secondaryText, height: 1.6),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Allergen info
                  if (food.allergenInfo != null && food.allergenInfo!.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber, size: 18, color: AppColors.accentOrange),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              food.allergenInfo!,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Pickup address
                  if (food.merchant?.address != null) ...[
                    Text('Pickup Location', style: AppTypography.headingSmall),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: AppColors.forestGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            food.merchant!.address!,
                            style: AppTypography.bodyMedium
                                .copyWith(color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom bar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Row(
          children: [
            // Quantity selector
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Text('$_quantity', style: AppTypography.labelLarge),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: _quantity < (food.stock)
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Order button
            Expanded(
              child: ElevatedButton(
                onPressed: food.stock > 0 && !food.isExpired
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Order feature coming in Phase 6!'),
                            backgroundColor: AppColors.forestGreen,
                          ),
                        );
                      }
                    : null,
                child: Text(
                  food.stock > 0 && !food.isExpired
                      ? 'Order • ${PriceFormatter.format(food.discountedPrice * _quantity)}'
                      : 'Unavailable',
                  style: AppTypography.button.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.forestGreen),
          const SizedBox(width: 6),
          Text(text, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}
