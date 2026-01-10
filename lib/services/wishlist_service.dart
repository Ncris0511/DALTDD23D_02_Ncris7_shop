import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class WishlistService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Trong wishlist_service.dart
  Future<List<dynamic>> getMyWishlist() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/wishlist'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['wishlist'] ?? [];
      } else {
        // In lỗi ra console để debug
        print("Lỗi Server trả về: ${response.body}");
      }
    } catch (e) {
      print("Lỗi kết nối App: $e");
    }
    return [];
  }

  // 2. Thêm / Bỏ tim (Toggle)
  Future<bool> toggleWishlist(int productId) async {
    final token = await _getToken();
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/wishlist/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId}),
      );
      // Backend trả về 200 (Bỏ tim) hoặc 201 (Thêm tim) đều coi là thành công
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Lỗi toggleWishlist: $e");
      return false;
    }
  }
}
