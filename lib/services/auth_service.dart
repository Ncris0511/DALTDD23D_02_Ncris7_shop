import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  // ĐĂNG KÝ
  Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": fullName,
          "email": email,
          "password": password,
          "phone_number": phone,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'message': 'Đăng ký thành công!'};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng ký thất bại',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối Server: $e'};
    }
  }

  // ĐĂNG NHẬP
  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse(ApiConfig.login);
    print("👉 Đang gọi Login API: $url");

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      print("👉 Server phản hồi code: ${response.statusCode}");
      print("👉 Server body: ${response.body}"); // Debug xem server trả về gì

      // Kiểm tra lỗi HTML
      if (response.headers['content-type']?.contains('text/html') == true) {
        return {
          'success': false,
          'message': 'Lỗi Server (HTML response). Kiểm tra lại IP/URL.',
        };
      }

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // XỬ LÝ DỮ LIỆU AN TOÀN (Tránh lỗi Null) ---
        // 1. Token
        String token = data['accessToken'] ?? '';

        // 2. Role (Xóa khoảng trắng và đưa về chữ thường để so sánh chuẩn)
        String role = (data['role'] ?? 'customer')
            .toString()
            .trim()
            .toLowerCase();

        // 3. Tên người dùng
        String fullName = data['full_name'] ?? 'Người dùng';

        // Lưu vào máy
        await prefs.setString('token', token);
        await prefs.setString('role', role);

        return {
          'success': true,
          'data': data,
          'role': role, // Trả role về cho LoginScreen dùng
          'user': {'name': fullName},
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (e) {
      print("❌ Lỗi Exception: $e");
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  // QUÊN MẬT KHẨU
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String newPassword,
  ) async {
    final url = Uri.parse(ApiConfig.resetPassword);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'new_password': newPassword}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': data['message']};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Lỗi không xác định',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
