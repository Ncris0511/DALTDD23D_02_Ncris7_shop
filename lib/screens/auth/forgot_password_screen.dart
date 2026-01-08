import 'package:flutter/material.dart';
// Bỏ import http và dart:convert vì đã chuyển sang service
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

  // Khởi tạo AuthService
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isObscure = true;

  void _handleResetPassword() async {
    // 1. Kiểm tra đầu vào
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

    // 2. Gọi Service thay vì gọi trực tiếp http
    final result = await _authService.resetPassword(
      _emailController.text,
      _newPassController.text,
    );

    setState(() => _isLoading = false);

    // 3. Xử lý kết quả trả về từ Service
    if (result['success']) {
      // Thành công -> Hiện Dialog
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.white,
          title: Text(
            "Thành công",
            style: AppStyles.h2.copyWith(color: Colors.green),
          ),
          content: Text(result['message'], style: AppStyles.body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng dialog
                Navigator.pop(context); // Quay về màn hình login
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
      // Thất bại -> Hiện SnackBar lỗi
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
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
        backgroundColor: AppColors.backgroundLight,
        foregroundColor: AppColors.textTitle,
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
                  backgroundColor: AppColors.primary,
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
