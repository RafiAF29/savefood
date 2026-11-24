import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/features/order/order_service.dart';
import 'package:savefood/features/order/order_detail_screen.dart';
import 'package:savefood/shared/models/food_model.dart';
import 'package:savefood/shared/widgets/food_card.dart';
import 'package:savefood/shared/widgets/sf_button.dart';
import 'package:savefood/shared/widgets/sf_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  final FoodListingModel food;
  final int quantity;

  const CheckoutScreen({
    super.key,
    required this.food,
    required this.quantity,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  double get _subtotal => widget.food.discountedPrice * widget.quantity;
  double get _savings =>
      (widget.food.originalPrice - widget.food.discountedPrice) * widget.quantity;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    setState(() => _isLoading = true);

    try {
      final order = await _orderService.placeOrder(
        items: [
          {
            'food_listing_id': widget.food.id,
            'quantity': widget.quantity,
          }
        ],
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        // Replace checkout with order detail
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderDetailScreen(
              orderId: order.id,
              isCustomer: true,
            ),
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! 🎉'),
            backgroundColor: AppColors.forestGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final food = widget.food;
    final merchant = food.merchant;

    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pickup info banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.accentOrange.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.directions_walk,
                      color: AppColors.accentOrange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pickup Only — Collect your order at the merchant location',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.accentOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order item
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.deepGreen,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.forestGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.restaurant,
                        color: AppColors.forestGreen),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.deepGreen,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.quantity}x  ${PriceFormatter.format(food.discountedPrice)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    PriceFormatter.format(_subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.forestGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Merchant info
            if (merchant != null) ...[
              const Text(
                'Pickup Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepGreen,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.store,
                            color: AppColors.forestGreen, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          merchant.businessName ?? merchant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.deepGreen,
                          ),
                        ),
                      ],
                    ),
                    if (merchant.address != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: Colors.grey[500], size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              merchant.address!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            color: Colors.grey[500], size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Pickup before: ${food.pickupTimeLeft}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Notes
            const Text(
              'Notes (optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.deepGreen,
              ),
            ),
            const SizedBox(height: 12),
            SfTextField(
              controller: _notesController,
              hintText: 'Any special requests...',
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Price breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  _PriceRow(
                    label: 'Subtotal',
                    value: PriceFormatter.format(_subtotal),
                  ),
                  const SizedBox(height: 8),
                  _PriceRow(
                    label: 'You save',
                    value: '- ${PriceFormatter.format(_savings)}',
                    valueColor: AppColors.forestGreen,
                  ),
                  const Divider(height: 20),
                  _PriceRow(
                    label: 'Total',
                    value: PriceFormatter.format(_subtotal),
                    isBold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Place order button
            SfButton(
              text: 'Place Order',
              onPressed: _placeOrder,
              isLoading: _isLoading,
              icon: Icons.check_circle_outline,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.deepGreen : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: valueColor ?? (isBold ? AppColors.deepGreen : Colors.grey[700]),
          ),
        ),
      ],
    );
  }
}
