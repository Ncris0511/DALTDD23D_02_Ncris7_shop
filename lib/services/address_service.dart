import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AddressService {
  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Lấy key 'token' mà bên login đã lưu
    return prefs.getString('token');
  }

  // Khi gọi API thêm địa chỉ, nó tự động lấy token gắn vào header
  Future<Map<String, dynamic>> addAddress(Map<String, dynamic> body) async {
    final token = await _getToken(); // <--- Lấy token ở đây

    // Nếu chưa đăng nhập (không có token) thì báo lỗi luôn
    if (token == null) {
      return {'success': false, 'message': 'Bạn chưa đăng nhập!'};
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/addresses');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // <--- Gửi token đi ở đây
        },
        body: jsonEncode(body),
      );
      // ... (Phần xử lý response giữ nguyên như cũ)
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Thêm địa chỉ thành công!'};
      } else {
        return {'success': false, 'message': data['message']};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }

  Future<List<dynamic>> getMyAddresses() async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.baseUrl}/addresses');

    print("👉 Đang gọi: $url"); // In URL
    print("👉 Token: $token"); // In Token

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
        "👉 Server phản hồi (${response.statusCode}): ${response.body}",
      ); // <--- QUAN TRỌNG

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['addresses'] ?? [];
      } else {
        // In lỗi ra để biết đường sửa
        print("❌ Lỗi Server: ${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      print("❌ Lỗi kết nối: $e");
      return [];
    }
  }
}
