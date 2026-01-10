import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class HomeService {
  // 1. Lấy danh sách Banner
  Future<List<dynamic>> getBanners() async {
    try {
      final url = Uri.parse(
        '${ApiConfig.baseUrl}/marketing/banners',
      ); // Đảm bảo URL đúng với backend
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['banners'] ?? [];
      }
    } catch (e) {
      print("Lỗi getBanners: $e");
    }
    return [];
  }

  // 2. Lấy danh mục sản phẩm
  Future<List<dynamic>> getCategories() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/categories');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['categories'] ?? [];
      }
    } catch (e) {
      print("Lỗi getCategories: $e");
    }
    return [];
  }

  // 3. Lấy sản phẩm (Hỗ trợ lọc theo category, keyword)
  Future<List<dynamic>> getProducts({int? categoryId, String? keyword}) async {
    try {
      // Xây dựng URL query string
      String query = "";
      if (categoryId != null) query += "category_id=$categoryId&";
      if (keyword != null) query += "keyword=$keyword&";

      final url = Uri.parse('${ApiConfig.baseUrl}/products?$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['products'] ?? [];
      }
    } catch (e) {
      print("Lỗi getProducts: $e");
    }
    return [];
  }
}
