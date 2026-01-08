import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AddressService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. Lấy danh sách địa chỉ
  Future<List<dynamic>> getMyAddresses() async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.address);

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['addresses'] ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // 2. THÊM ĐỊA CHỈ MỚI (Hàm mới)
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> body) async {
    final token = await _getToken();
    final url = Uri.parse(ApiConfig.address);

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Thêm địa chỉ thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Lỗi thêm địa chỉ',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
