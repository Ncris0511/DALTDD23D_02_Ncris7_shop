import 'package:flutter/material.dart';
import 'package:ncris7shop/screens/auth/register_screen.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/auth_service.dart';
import 'forgot_password_screen.dart';
// import 'register_screen.dart'; // <--- Đừng quên tạo và import trang đăng ký nhé

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
    if (_emailController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin!"),
          backgroundColor: AppColors.primaryRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.login(
      _emailController.text,
      _passController.text,
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Xin chào ${result['user']['name']}!"),
          backgroundColor: Colors.green,
        ),
      );
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomeScreen()));
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.white,
          title: Text("Lỗi đăng nhập", style: AppStyles.h2),
          content: Text(result['message'], style: AppStyles.body),
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

  // Widget TextField dùng chung
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
              Image.asset('assets/images/logo.png', width: 80),
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

              // --- HÀNG CHỨA 2 NÚT (TRÁI: ĐĂNG KÝ - PHẢI: QUÊN MK) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Đẩy 2 bên
                children: [
                  // Nút Đăng ký (Bên trái)
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
                        color: AppColors.textBody, // Màu xám cho chữ thường
                        fontWeight: FontWeight.w500,
                        fontSize: 13, // Chỉnh nhỏ chút để vừa hàng
                      ),
                    ),
                  ),

                  // Nút Quên mật khẩu (Bên phải)
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

              // --------------------------------------------------------
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
