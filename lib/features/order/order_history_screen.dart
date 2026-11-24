import 'package:flutter/material.dart';
import 'package:savefood/core/constants/app_colors.dart';
import 'package:savefood/features/order/order_service.dart';
import 'package:savefood/features/order/order_detail_screen.dart';
import 'package:savefood/shared/models/order_model.dart';
import 'package:savefood/shared/widgets/food_card.dart';

class OrderHistoryScreen extends StatefulWidget {
  final bool isCustomer;

  const OrderHistoryScreen({super.key, required this.isCustomer});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderService _service = OrderService();
  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _error;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = widget.isCustomer
          ? await _service.getCustomerOrders(status: _statusFilter)
          : await _service.getMerchantOrders(status: _statusFilter);
      setState(() => _orders = orders);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.softCream,
      appBar: AppBar(
        title: Text(widget.isCustomer ? 'My Orders' : 'Orders'),
        backgroundColor: AppColors.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.forestGreen))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _loadOrders,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _orders.isEmpty
                        ? _buildEmpty()
                        : RefreshIndicator(
                            onRefresh: _loadOrders,
                            color: AppColors.forestGreen,
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: _orders.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _OrderTile(
                                  order: _orders[index],
                                  isCustomer: widget.isCustomer,
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => OrderDetailScreen(
                                          orderId: _orders[index].id,
                                          isCustomer: widget.isCustomer,
                                        ),
                                      ),
                                    );
                                    _loadOrders();
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [null, 'pending', 'accepted', 'ready', 'picked_up'];
    final labels = ['All', 'Pending', 'Accepted', 'Ready', 'Completed'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
      child: SizedBox(
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
                  _loadOrders();
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
                color:
                    isSelected ? AppColors.forestGreen : Colors.grey[300]!,
              ),
              showCheckmark: false,
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No orders yet',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderModel order;
  final bool isCustomer;
  final VoidCallback onTap;

  const _OrderTile({
    required this.order,
    required this.isCustomer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColors = {
      'pending': Colors.orange,
      'accepted': Colors.blue,
      'ready': AppColors.forestGreen,
      'picked_up': Colors.teal,
      'rejected': Colors.red,
      'cancelled': Colors.grey,
    };
    final statusColor = statusColors[order.status] ?? Colors.grey;

    final contactName = isCustomer
        ? (order.merchant?.businessName ?? order.merchant?.name ?? 'Merchant')
        : (order.customer?.name ?? 'Customer');

    final itemsSummary = order.items.map((i) => '${i.quantity}x ${i.foodName}').join(', ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${order.orderNumber}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppColors.deepGreen,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isCustomer ? Icons.store : Icons.person_outline,
                  size: 16,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  contactName,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              itemsSummary,
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(order.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
                Text(
                  PriceFormatter.format(order.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.forestGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
