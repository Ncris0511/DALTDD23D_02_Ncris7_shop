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
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 2. Xóa địa chỉ
  Future<bool> deleteAddress(int addressId) async {
    final token = await _getToken();
    final url = Uri.parse(
      '${ApiConfig.address}/$addressId',
    ); // Giả sử API xóa là DELETE /addresses/:id

    try {
      final response = await http.delete(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.statusCode == 200;
    } catch (e) {
      print("Lỗi xóa địa chỉ: $e");
      return false;
    }
  }

  // 3. Cập nhật địa chỉ
  Future<Map<String, dynamic>> updateAddress(
    int addressId,
    Map<String, dynamic> body,
  ) async {
    final token = await _getToken();
    final url = Uri.parse('${ApiConfig.address}/$addressId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'message': 'Cập nhật thành công!'};
      } else {
        return {'success': false, 'message': data['message'] ?? 'Lỗi cập nhật'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: $e'};
    }
  }
}
