import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class OrderService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. Lấy giỏ hàng (Để hiển thị trước khi mua)
  Future<List<dynamic>> getCart() async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.cart);
    print("👉 Đang gọi API: $url"); // <--- THÊM DÒNG NÀY
    print("👉 Token: $token");
    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['cartItem'];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> createOrder({
    required int addressId,
    required String paymentMethod,
    String? voucherCode,
    String? note,
    required List<dynamic> items, // Chỉ cần nhận danh sách món
  }) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.order);

    try {
      // 1. Chuẩn bị danh sách sản phẩm (variant_id, quantity)
      final List<Map<String, dynamic>> itemsPayload = items
          .map(
            (e) => {
              "variant_id": e['variant']['variant_id'],
              "quantity": e['quantity'],
            },
          )
          .toList();

      // 2. Tự động lấy danh sách ID giỏ hàng để xóa (Fix lỗi thiếu tham số cartItemIds)
      final List<int> cartItemIds = items
          .map((e) => e['cart_item_id'] as int)
          .toList();

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "address_id": addressId,
          "payment_method": paymentMethod,
          "voucher_code": voucherCode,
          "note": note,
          "items": itemsPayload,
          "cart_item_ids": cartItemIds, // Gửi kèm để backend xóa giỏ hàng
        }),
      );

      // Kiểm tra xem Server có trả về HTML (trang lỗi) thay vì JSON không
      if (response.headers['content-type']?.contains('text/html') == true) {
        print("Lỗi API: ${response.body}");
        return {
          'success': false,
          'message': 'Sai đường dẫn API hoặc Lỗi Server (500/404)',
        };
      }

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'order_id': data['order_id'] ?? 0};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi đặt hàng'};
      }
    } catch (e) {
      print("Lỗi createOrder: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // CHECK VOUCHER
  Future<Map<String, dynamic>> checkVoucher(
    String code,
    double totalAmount,
  ) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.voucher);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"code": code, "total_amount": totalAmount}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Mã không hợp lệ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kiểm tra voucher'};
    }
  }

  // Lấy lịch sử đơn hàng
  Future<List<dynamic>> getMyOrders() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/my-orders'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['orders'] ?? [];
      }
    } catch (e) {
      print("Lỗi getMyOrders: $e");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getOrderDetail(int orderId) async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("Lỗi getOrderDetail: $e");
    }
    return null;
  }

  Future<bool> cancelOrder(int orderId) async {
    final token = await _getToken();
    try {
      // Gọi đúng route đã định nghĩa ở Bước 1
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/cancel'),
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi cancelOrder: $e");
      return false;
    }
  }
}
