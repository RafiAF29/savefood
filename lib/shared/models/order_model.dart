class OrderModel {
  final int id;
  final String orderNumber;
  final int customerId;
  final int merchantId;
  final String status;
  final double totalAmount;
  final String? notes;
  final String? rejectionReason;
  final DateTime? pickupTime;
  final DateTime createdAt;
  final List<OrderItemModel> items;
  final OrderUserInfo? merchant;
  final OrderUserInfo? customer;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.merchantId,
    required this.status,
    required this.totalAmount,
    this.notes,
    this.rejectionReason,
    this.pickupTime,
    required this.createdAt,
    required this.items,
    this.merchant,
    this.customer,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? [];
    return OrderModel(
      id: json['id'],
      orderNumber: json['order_number'],
      customerId: json['customer_id'],
      merchantId: json['merchant_id'],
      status: json['status'],
      totalAmount: double.parse(json['total_amount'].toString()),
      notes: json['notes'],
      rejectionReason: json['rejection_reason'],
      pickupTime: json['pickup_time'] != null
          ? DateTime.parse(json['pickup_time'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      items: itemsList.map((i) => OrderItemModel.fromJson(i)).toList(),
      merchant: json['merchant'] != null
          ? OrderUserInfo.fromJson(json['merchant'])
          : null,
      customer: json['customer'] != null
          ? OrderUserInfo.fromJson(json['customer'])
          : null,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'ready':
        return 'Ready for Pickup';
      case 'picked_up':
        return 'Picked Up';
      case 'rejected':
        return 'Rejected';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get canCancel => status == 'pending';
  bool get isActive => ['pending', 'accepted', 'ready'].contains(status);
}

class OrderItemModel {
  final int id;
  final int foodListingId;
  final String foodName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  OrderItemModel({
    required this.id,
    required this.foodListingId,
    required this.foodName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      foodListingId: json['food_listing_id'],
      foodName: json['food_name'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
    );
  }
}

class OrderUserInfo {
  final int id;
  final String name;
  final String? phone;
  final String? businessName;
  final String? address;

  OrderUserInfo({
    required this.id,
    required this.name,
    this.phone,
    this.businessName,
    this.address,
  });

  factory OrderUserInfo.fromJson(Map<String, dynamic> json) {
    final profile = json['merchant_profile'];
    return OrderUserInfo(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      businessName: profile?['business_name'],
      address: profile?['address'],
    );
  }
}
