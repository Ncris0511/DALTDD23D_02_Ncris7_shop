import 'package:flutter/material.dart';
import 'package:ncris7shop/screens/auth/register_screen.dart';
import 'package:ncris7shop/screens/user/main_screen.dart';
import 'package:ncris7shop/screens/admin/admin_order_list_screen.dart'; // <--- 1. IMPORT TRANG ADMIN
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isObscure = true;

  void _handleLogin() async {
    // 1. Kiểm tra nhập liệu
    if (_emailController.text.trim().isEmpty ||
        _passController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin!"),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Gọi API Đăng nhập
    final result = await _authService.login(
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    setState(() => _isLoading = false);

    // 3. Xử lý kết quả
    if (result['success']) {
      // Lấy role từ kết quả trả về
      // (Lưu ý: Backend phải trả về 'admin' hoặc 'customer')
      String role = result['role']?.toString().toLowerCase() ?? 'customer';
      String name = result['user']?['name'] ?? 'Bạn';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Xin chào $name! (Quyền: $role)"),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );

        //PHÂN QUYỀN ĐIỀU HƯỚNG
        if (role == 'admin') {
          // NẾU LÀ ADMIN -> Vào trang Quản lý đơn hàng
          print("👉 Điều hướng: ADMIN");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminOrderListScreen(),
            ),
            (route) => false,
          );
        } else {
          // NẾU LÀ USER -> Vào trang Mua sắm
          print("👉 Điều hướng: USER");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } else {
      // Đăng nhập thất bại
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.white,
            title: Text("Lỗi đăng nhập", style: AppStyles.h2),
            content: Text(
              result['message'] ?? "Có lỗi xảy ra",
              style: AppStyles.body,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  // ... (Giữ nguyên phần UI _buildTextField và build)
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _isObscure : false,
      keyboardType: isPassword
          ? TextInputType.text
          : TextInputType.emailAddress,
      style: AppStyles.body.copyWith(color: AppColors.textTitle),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppStyles.body.copyWith(color: AppColors.textHint),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.textHint, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        prefixIcon: Icon(icon, color: AppColors.textHint),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textHint,
                ),
                onPressed: () => setState(() => _isObscure = !_isObscure),
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Image.asset(
                'assets/images/logo.png',
                width: 80,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.shopping_bag,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "ĐĂNG NHẬP",
                textAlign: TextAlign.center,
                style: AppStyles.h1,
              ),
              const SizedBox(height: 10),

              Text(
                "Chào mừng bạn quay trở lại",
                textAlign: TextAlign.center,
                style: AppStyles.body.copyWith(color: AppColors.textBody),
              ),
              const SizedBox(height: 50),

              _buildTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              _buildTextField(
                controller: _passController,
                label: "Mật khẩu",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Chưa có tài khoản?",
                      style: AppStyles.body.copyWith(
                        color: AppColors.textBody,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ForgotPasswordScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Quên mật khẩu?",
                      style: AppStyles.body.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
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
                    : Text("ĐĂNG NHẬP", style: AppStyles.buttonText),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
