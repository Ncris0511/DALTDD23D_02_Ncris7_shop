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

  // 2. Kiểm tra Voucher
  Future<Map<String, dynamic>> checkVoucher(String code, double total) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.voucher);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'code': code, 'order_total': total}),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // 3. Tạo đơn hàng (Đặt hàng)
  Future<Map<String, dynamic>> createOrder({
    required int addressId,
    required String paymentMethod,
    String? note,
    String? voucherCode,
  }) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.order);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'address_id': addressId,
          'payment_method': paymentMethod,
          'note': note ?? "",
          'voucher_code': voucherCode,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'order_id': data['order_id']};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
