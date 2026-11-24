import 'package:savefood/core/network/api_client.dart';
import 'package:savefood/shared/models/order_model.dart';

class OrderService {
  final ApiClient _api = ApiClient();

  // Customer: place order
  Future<OrderModel> placeOrder({
    required List<Map<String, dynamic>> items,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'items': items,
    };
    if (notes != null && notes.isNotEmpty) {
      body['notes'] = notes;
    }

    final response = await _api.post('/customer/orders', body: body, auth: true);
    return OrderModel.fromJson(response['order']);
  }

  // Customer: list my orders
  Future<List<OrderModel>> getCustomerOrders({String? status}) async {
    var endpoint = '/customer/orders';
    if (status != null) {
      endpoint += '?status=$status';
    }

    final response = await _api.get(endpoint, auth: true);
    final List orders = response['orders'];
    return orders.map((o) => OrderModel.fromJson(o)).toList();
  }

  // Customer: order detail
  Future<OrderModel> getCustomerOrderDetail(int id) async {
    final response = await _api.get('/customer/orders/$id', auth: true);
    return OrderModel.fromJson(response['order']);
  }

  // Customer: cancel order
  Future<OrderModel> cancelOrder(int id) async {
    final response = await _api.patch('/customer/orders/$id/cancel', auth: true);
    return OrderModel.fromJson(response['order']);
  }

  // Merchant: list orders
  Future<List<OrderModel>> getMerchantOrders({String? status}) async {
    var endpoint = '/merchant/orders';
    if (status != null) {
      endpoint += '?status=$status';
    }

    final response = await _api.get(endpoint, auth: true);
    final List orders = response['orders'];
    return orders.map((o) => OrderModel.fromJson(o)).toList();
  }

  // Merchant: order detail
  Future<OrderModel> getMerchantOrderDetail(int id) async {
    final response = await _api.get('/merchant/orders/$id', auth: true);
    return OrderModel.fromJson(response['order']);
  }

  // Merchant: update order status
  Future<OrderModel> updateOrderStatus(int id, String status, {String? rejectionReason}) async {
    final body = <String, dynamic>{'status': status};
    if (rejectionReason != null) {
      body['rejection_reason'] = rejectionReason;
    }

    final response = await _api.patch('/merchant/orders/$id/status', body: body, auth: true);
    return OrderModel.fromJson(response['order']);
  }
}
