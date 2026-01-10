import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class CartService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. Lấy giỏ hàng (Đã nâng cấp để sửa lỗi không hiện sản phẩm)
  Future<List<dynamic>> getCart() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/cart');

    try {
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Debug: In ra để xem Server trả về cái gì
        print("📦 Data Giỏ hàng: $data");

        // Kiểm tra kỹ các trường hợp tên biến backend có thể trả về
        if (data['cartItem'] != null) return data['cartItem'];
        if (data['cartItems'] != null) return data['cartItems'];
        if (data['items'] != null) return data['items'];

        return [];
      } else {
        print("❌ Lỗi API Giỏ hàng: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi getCart: $e");
    }
    return [];
  }

  // 2. Thêm vào giỏ
  Future<bool> addToCart(int productId, int variantId, int quantity) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/cart/add');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "product_id": productId,
          "variant_id": variantId,
          "quantity": quantity,
        }),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  // 3. Cập nhật số lượng
  Future<bool> updateQuantity(int cartItemId, int newQuantity) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/cart/$cartItemId');
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"quantity": newQuantity}),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Xóa sản phẩm
  Future<bool> deleteItem(int cartItemId) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/cart/$cartItemId');
    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
