import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ReviewService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Gửi đánh giá lên Server
  Future<Map<String, dynamic>> addReview({
    required int orderId,
    required int productId,
    required int? variantId,
    required int rating,
    required String comment,
  }) async {
    final token = await _getToken();
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/reviews/add');

      // Debug: In ra console để kiểm tra
      print(
        "👉 GỬI REVIEW: Order=$orderId, Product=$productId, Variant=$variantId",
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'order_id': orderId,
          'product_id': productId,
          'variant_id': variantId,
          'rating': rating,
          'comment': comment,
        }),
      );

      print("👉 Server Response: ${response.body}");

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': data['message']};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi đánh giá'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
