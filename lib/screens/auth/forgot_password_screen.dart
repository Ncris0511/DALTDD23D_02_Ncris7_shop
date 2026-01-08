import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/api_config.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPassController = TextEditingController();
  bool _isLoading = false;
  bool _isObscure = true;

  void _handleResetPassword() async {
    if (_emailController.text.isEmpty || _newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đủ thông tin!"),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/auth/reset-password-email');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailController.text,
          'new_password': _newPassController.text,
        }),
      );

      final data = jsonDecode(response.body);

      setState(() => _isLoading = false);

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.white,
            title: Text(
              "Thành công",
              style: AppStyles.h2.copyWith(color: Colors.green),
            ),
            content: Text(data['message'], style: AppStyles.body),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Đăng nhập ngay",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: AppColors.primaryRed,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi kết nối: $e"),
          backgroundColor: AppColors.primaryRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Đặt lại mật khẩu", style: AppStyles.h2),
        backgroundColor: AppColors.backgroundLight, // Hòa vào nền
        foregroundColor: AppColors.textTitle, // Màu nút back
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              "Nhập Email đã đăng ký và Mật khẩu mới để đặt lại ngay lập tức.",
              textAlign: TextAlign.center,
              style: AppStyles.body,
            ),
            const SizedBox(height: 30),

            // Ô Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              style: AppStyles.body.copyWith(color: AppColors.textTitle),
              decoration: InputDecoration(
                labelText: "Email đã đăng ký",
                labelStyle: AppStyles.body.copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.textHint,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: AppColors.textHint,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Ô Mật khẩu mới
            TextField(
              controller: _newPassController,
              obscureText: _isObscure,
              style: AppStyles.body.copyWith(color: AppColors.textTitle),
              decoration: InputDecoration(
                labelText: "Mật khẩu mới",
                labelStyle: AppStyles.body.copyWith(color: AppColors.textHint),
                filled: true,
                fillColor: AppColors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.textHint,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(
                  Icons.lock_reset,
                  color: AppColors.textHint,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textHint,
                  ),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Nút Xác nhận
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, // Màu xanh chủ đạo
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text("XÁC NHẬN ĐỔI MK", style: AppStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
