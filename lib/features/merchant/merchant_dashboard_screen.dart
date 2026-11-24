import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/core/network/token_storage.dart';
import 'package:savefood/features/authentication/login_screen.dart';
import 'package:savefood/features/merchant/merchant_service.dart';
import 'package:savefood/features/merchant/merchant_food_form_screen.dart';
import 'package:savefood/features/merchant/merchant_profile_screen.dart';
import 'package:savefood/shared/models/food_model.dart';
import 'package:savefood/shared/models/user_model.dart';
import 'package:savefood/shared/widgets/food_card.dart';

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  final MerchantService _service = MerchantService();

  bool _isLoading = true;
  String? _error;

  UserModel? _merchant;
  MerchantDashboardStats? _stats;
  MerchantProfileData? _profile;
  List<FoodListingModel> _listings = [];
  String _statusFilter = 'active';

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final dashData = await _service.getDashboard();

      _merchant = UserModel.fromJson(dashData['merchant']);
      _stats = MerchantDashboardStats.fromJson(dashData['stats']);
      if (dashData['profile'] != null) {
        _profile = MerchantProfileData.fromJson(dashData['profile']);
      }

      await _loadListings();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadListings() async {
    try {
      final listings = await _service.getMyListings(status: _statusFilter);
      setState(() => _listings = listings);
    } catch (e) {
      // Silently fail for listings, dashboard still shows
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await TokenStorage.clear();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _deleteFood(FoodListingModel food) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Listing'),
        content: Text('Delete "${food.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.deleteFood(food.id);
        _loadDashboard();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  Future<void> _toggleActive(FoodListingModel food) async {
    try {
      await _service.toggleActive(food.id);
      _loadDashboard();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.forestGreen))
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  color: AppColors.forestGreen,
                  child: CustomScrollView(
                    slivers: [
                      _buildAppBar(),
                      SliverToBoxAdapter(child: _buildStatsCards()),
                      SliverToBoxAdapter(child: _buildFilterChips()),
                      _buildListingsGrid(),
                      const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
                    ],
                  ),
                ),
      floatingActionButton: !_isLoading && _error == null
          ? FloatingActionButton.extended(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MerchantFoodFormScreen(),
                  ),
                );
                if (result == true) _loadDashboard();
              },
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Food'),
            )
          : null,
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDashboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestGreen,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    final businessName = _profile?.businessName ?? _merchant?.name ?? 'Merchant';

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.forestGreen,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              businessName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (_profile?.isVerified == true)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 12, color: Colors.white.withValues(alpha: 0.9)),
                  const SizedBox(width: 4),
                  Text(
                    'Verified Merchant',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.person_outline, color: Colors.white),
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MerchantProfileScreen(),
              ),
            );
            if (result == true) _loadDashboard();
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    if (_stats == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.check_circle_outline,
                  label: 'Active',
                  value: _stats!.activeListings.toString(),
                  color: AppColors.forestGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.inventory_2_outlined,
                  label: 'Total',
                  value: _stats!.totalListings.toString(),
                  color: AppColors.accentOrange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.timer_off_outlined,
                  label: 'Expired',
                  value: _stats!.expiredListings.toString(),
                  color: Colors.red[400]!,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.remove_shopping_cart_outlined,
                  label: 'Out of Stock',
                  value: _stats!.outOfStock.toString(),
                  color: Colors.grey[600]!,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['active', 'expired', 'out_of_stock', 'inactive'];
    final labels = ['Active', 'Expired', 'Out of Stock', 'Inactive'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Listings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.deepGreen,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = _statusFilter == filters[index];
                return ChoiceChip(
                  label: Text(labels[index]),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _statusFilter = filters[index]);
                      _loadListings();
                    }
                  },
                  selectedColor: AppColors.forestGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppColors.deepGreen,
                    fontSize: 12,
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.forestGreen
                        : Colors.grey[300]!,
                  ),
                  showCheckmark: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  SliverPadding _buildListingsGrid() {
    if (_listings.isEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.all(24),
        sliver: SliverToBoxAdapter(
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Icon(Icons.restaurant_menu, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No $_statusFilter listings',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add food',
                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final food = _listings[index];
            return _MerchantFoodTile(
              food: food,
              onEdit: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MerchantFoodFormScreen(food: food),
                  ),
                );
                if (result == true) _loadDashboard();
              },
              onDelete: () => _deleteFood(food),
              onToggle: () => _toggleActive(food),
            );
          },
          childCount: _listings.length,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MerchantFoodTile extends StatelessWidget {
  final FoodListingModel food;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  const _MerchantFoodTile({
    required this.food,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = food.pickupDeadline.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food image placeholder
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.forestGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: food.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        food.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.restaurant,
                          color: AppColors.forestGreen,
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.restaurant,
                      color: AppColors.forestGreen,
                      size: 28,
                    ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          food.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.deepGreen,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Expired',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${PriceFormatter.format(food.discountedPrice)}  •  Stock: ${food.stock}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _ActionChip(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        onTap: onEdit,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: food.isActive
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        label: food.isActive ? 'Hide' : 'Show',
                        onTap: onToggle,
                      ),
                      const SizedBox(width: 8),
                      _ActionChip(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        onTap: onDelete,
                        isDestructive: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red[400]! : AppColors.forestGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: color.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
