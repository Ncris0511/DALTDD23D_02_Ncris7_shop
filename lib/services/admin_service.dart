import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AdminService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 4. Lấy danh sách tất cả đơn hàng (Có lọc theo status)
  Future<List<dynamic>> getAllOrders({String? status}) async {
    final token = await _getToken();
    // Tạo query param nếu có status
    String urlStr = '${ApiConfig.baseUrl}/orders';
    if (status != null && status != 'all') {
      urlStr += '?status=$status';
    }

    try {
      final response = await http.get(
        Uri.parse(urlStr),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['orders'] ?? [];
      }
    } catch (e) {
      print("Lỗi Admin getAllOrders: $e");
    }
    return [];
  }

  // 6. Cập nhật trạng thái đơn hàng
  Future<bool> updateOrderStatus(int orderId, String newStatus) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/orders/$orderId/status');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"status": newStatus}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi Admin updateOrderStatus: $e");
      return false;
    }
  }
}
