import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ProductService {
  // 1. Lấy chi tiết sản phẩm
  Future<Map<String, dynamic>?> getProductDetail(int id) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/products/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['product'];
      }
    } catch (e) {
      print("Lỗi getProductDetail: $e");
    }
    return null;
  }

  // 2. Lấy đánh giá sản phẩm (API mới sửa)
  Future<List<dynamic>> getProductReviews(int productId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/reviews/product/$productId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reviews'] ?? [];
      }
    } catch (e) {
      print("Lỗi getProductReviews: $e");
    }
    return [];
  }

  Future<List<dynamic>> getRelatedProducts(int productId) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/products/$productId/related');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      }
    } catch (e) {
      print("Lỗi getRelatedProducts: $e");
    }
    return [];
  }
}
