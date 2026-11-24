import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/features/order/order_service.dart';
import 'package:savefood/shared/models/order_model.dart';
import 'package:savefood/shared/widgets/food_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  final bool isCustomer;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
    required this.isCustomer,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _service = OrderService();
  OrderModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final order = widget.isCustomer
          ? await _service.getCustomerOrderDetail(widget.orderId)
          : await _service.getMerchantOrderDetail(widget.orderId);
      setState(() => _order = order);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes, Cancel',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _service.cancelOrder(widget.orderId);
        _loadOrder();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled')),
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

  Future<void> _updateStatus(String newStatus) async {
    String? rejectionReason;

    if (newStatus == 'rejected') {
      rejectionReason = await showDialog<String>(
        context: context,
        builder: (ctx) {
          final controller = TextEditingController();
          return AlertDialog(
            title: const Text('Reject Order'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Reason for rejection...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, controller.text),
                child: const Text('Reject',
                    style: TextStyle(color: Colors.red)),
              ),
            ],
          );
        },
      );

      if (rejectionReason == null) return;
    }

    try {
      await _service.updateOrderStatus(
        widget.orderId,
        newStatus,
        rejectionReason: rejectionReason,
      );
      _loadOrder();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order $newStatus')),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        title: Text(_order != null ? '#${_order!.orderNumber}' : 'Order Detail'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.forestGreen))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrder,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadOrder,
                  color: AppColors.forestGreen,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatusBadge(),
                        const SizedBox(height: 20),
                        _buildItems(),
                        const SizedBox(height: 20),
                        _buildContactInfo(),
                        const SizedBox(height: 20),
                        _buildPriceSummary(),
                        if (_order!.notes != null &&
                            _order!.notes!.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          _buildNotes(),
                        ],
                        if (_order!.rejectionReason != null) ...[
                          const SizedBox(height: 20),
                          _buildRejectionReason(),
                        ],
                        const SizedBox(height: 24),
                        _buildActions(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatusBadge() {
    final order = _order!;
    final statusColors = {
      'pending': Colors.orange,
      'accepted': Colors.blue,
      'ready': AppColors.forestGreen,
      'picked_up': Colors.teal,
      'rejected': Colors.red,
      'cancelled': Colors.grey,
    };
    final color = statusColors[order.status] ?? Colors.grey;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(_getStatusIcon(order.status), color: color, size: 40),
          const SizedBox(height: 8),
          Text(
            order.statusLabel,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getStatusDescription(order.status),
            style: TextStyle(fontSize: 12, color: color.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_top;
      case 'accepted':
        return Icons.thumb_up_outlined;
      case 'ready':
        return Icons.check_circle_outline;
      case 'picked_up':
        return Icons.shopping_bag_outlined;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.info_outline;
    }
  }

  String _getStatusDescription(String status) {
    if (widget.isCustomer) {
      switch (status) {
        case 'pending':
          return 'Waiting for merchant to accept your order';
        case 'accepted':
          return 'Merchant is preparing your order';
        case 'ready':
          return 'Your order is ready! Go pick it up';
        case 'picked_up':
          return 'Order completed. Thank you!';
        case 'rejected':
          return 'Merchant rejected your order';
        case 'cancelled':
          return 'You cancelled this order';
        default:
          return '';
      }
    } else {
      switch (status) {
        case 'pending':
          return 'New order — accept or reject';
        case 'accepted':
          return 'Prepare the order for pickup';
        case 'ready':
          return 'Waiting for customer to pick up';
        case 'picked_up':
          return 'Order completed';
        case 'rejected':
          return 'You rejected this order';
        case 'cancelled':
          return 'Customer cancelled this order';
        default:
          return '';
      }
    }
  }

  Widget _buildItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.deepGreen,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: _order!.items.map((item) {
              return Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.forestGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          '${item.quantity}x',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: AppColors.forestGreen,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.foodName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.deepGreen,
                        ),
                      ),
                    ),
                    Text(
                      PriceFormatter.format(item.subtotal),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.deepGreen,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo() {
    final info = widget.isCustomer ? _order!.merchant : _order!.customer;
    if (info == null) return const SizedBox.shrink();

    final title = widget.isCustomer ? 'Pickup Location' : 'Customer';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.deepGreen,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
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
                  Icon(
                    widget.isCustomer ? Icons.store : Icons.person_outline,
                    color: AppColors.forestGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    info.businessName ?? info.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.deepGreen,
                    ),
                  ),
                ],
              ),
              if (info.address != null) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.location_on_outlined,
                        color: Colors.grey[500], size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        info.address!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ],
              if (info.phone != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone_outlined,
                        color: Colors.grey[500], size: 18),
                    const SizedBox(width: 8),
                    Text(
                      info.phone!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.deepGreen,
            ),
          ),
          Text(
            PriceFormatter.format(_order!.totalAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.forestGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.deepGreen,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            _order!.notes!,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectionReason() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.red[700], size: 18),
              const SizedBox(width: 8),
              Text(
                'Rejection Reason',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _order!.rejectionReason!,
            style: TextStyle(fontSize: 13, color: Colors.red[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    final order = _order!;

    if (widget.isCustomer) {
      if (order.canCancel) {
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _cancelOrder,
            icon: const Icon(Icons.cancel_outlined, color: Colors.red),
            label: const Text('Cancel Order',
                style: TextStyle(color: Colors.red)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      }
      return const SizedBox.shrink();
    }

    // Merchant actions
    final actions = <Widget>[];

    if (order.status == 'pending') {
      actions.addAll([
        Expanded(
          child: OutlinedButton(
            onPressed: () => _updateStatus('rejected'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child:
                const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => _updateStatus('accepted'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Accept'),
          ),
        ),
      ]);
    } else if (order.status == 'accepted') {
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus('ready'),
            icon: const Icon(Icons.check),
            label: const Text('Mark as Ready'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    } else if (order.status == 'ready') {
      actions.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _updateStatus('picked_up'),
            icon: const Icon(Icons.shopping_bag_outlined),
            label: const Text('Confirm Pickup'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Row(children: actions);
  }
}
