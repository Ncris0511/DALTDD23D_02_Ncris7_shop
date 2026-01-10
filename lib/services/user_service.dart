import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class UserService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // 1. Lấy thông tin cá nhân
  Future<Map<String, dynamic>?> getMyProfile() async {
    final token = await _getToken();
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body)['user'];
      }
    } catch (e) {
      print("Lỗi getMyProfile: $e");
    }
    return null;
  }

  // 2. Cập nhật thông tin
  Future<bool> updateProfile(Map<String, dynamic> body) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 3. Đổi mật khẩu
  Future<Map<String, dynamic>> changePassword(
    String oldPass,
    String newPass,
  ) async {
    final token = await _getToken();
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/users/change-password'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'old_password': oldPass, 'new_password': newPass}),
      );
      final data = jsonDecode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return {'success': false, 'message': "Lỗi kết nối: $e"};
    }
  }
}
