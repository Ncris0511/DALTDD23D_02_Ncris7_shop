import 'package:flutter/material.dart';
import 'package:ncris7shop/screens/auth/login_screen.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _phoneController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // 1. Thêm biến để quản lý trạng thái Ẩn/Hiện mật khẩu
  bool _isShowPassword = false;
  bool _isShowConfirmPassword = false;

  void _handRegister() async {
    // Validate cơ bản
    if (_emailController.text.isEmpty ||
        _passController.text.isEmpty ||
        _fullNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ thông tin")),
      );
      return;
    }
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu nhập lại không khớp")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _authService.register(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passController.text,
      phone: _phoneController.text,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.green, // Dùng màu xanh lá cho thành công
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red, // Dùng màu đỏ cho lỗi
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // Thêm physics để cuộn mượt hơn
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(24, 20, 24, 20 + bottomPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 120,
              ), // Giảm size chút cho gọn
              const SizedBox(height: 20),

              Text("Tạo Tài Khoản", style: AppStyles.h1),
              const SizedBox(height: 30),

              _buildTextField(
                controller: _fullNameController,
                label: "Họ và tên",
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _emailController,
                label: "Email",
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress, // Bàn phím email
              ),
              const SizedBox(height: 16),

              // Ô Mật khẩu (Có nút mắt thần)
              _buildTextField(
                controller: _passController,
                label: "Mật khẩu",
                icon: Icons.lock_outline,
                isPassword: true,
                isShowPass: _isShowPassword,
                onTogglePass: () {
                  setState(() {
                    _isShowPassword = !_isShowPassword;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Ô Nhập lại Mật khẩu
              _buildTextField(
                controller: _confirmPassController,
                label: "Nhập lại mật khẩu",
                icon: Icons.lock_outline,
                isPassword: true,
                isShowPass: _isShowConfirmPassword,
                onTogglePass: () {
                  setState(() {
                    _isShowConfirmPassword = !_isShowConfirmPassword;
                  });
                },
              ),
              const SizedBox(height: 16),

              _buildTextField(
                controller: _phoneController,
                label: "Số điện thoại",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone, // Bàn phím số
              ),

              const SizedBox(height: 40),

              // Nút Đăng ký
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 2, // Thêm chút bóng đổ cho nút nổi lên
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // Bo góc mềm mại hơn
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Đăng Ký",
                          style: AppStyles.buttonText.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Nút Thoát
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                ),
                child: Text(
                  "Đã có tài khoản? Đăng nhập ngay",
                  style: AppStyles.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    bool isShowPass = false,
    VoidCallback? onTogglePass,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isShowPass, // Logic ẩn hiện mật khẩu
      keyboardType: keyboardType,
      style: AppStyles.h3,
      decoration: InputDecoration(
        labelText: label,
        // Label khi chưa nhập màu xám, nhập rồi thì màu xanh
        labelStyle: AppStyles.body.copyWith(color: Colors.grey.shade600),

        prefixIcon: Icon(icon, color: Colors.grey.shade500),

        // Icon mắt thần
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isShowPass ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade500,
                ),
                onPressed: onTogglePass,
              )
            : null,

        filled: true,
        fillColor: Colors.grey.shade50, // Màu nền xám cực nhạt cho hiện đại

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),

        // Viền khi bình thường
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),

        // Viền khi bấm vào
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        // Viền khi có lỗi
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
