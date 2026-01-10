import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/user_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _confirmPassController =
      TextEditingController(); // Thêm ô xác nhận lại cho chắc chắn

  final UserService _userService = UserService();
  bool _isLoading = false;

  // Trạng thái ẩn/hiện mật khẩu cho từng ô
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  void _handleChange() async {
    // 1. Validate cơ bản
    if (_oldPassController.text.isEmpty ||
        _newPassController.text.isEmpty ||
        _confirmPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng nhập đầy đủ thông tin!"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 2. Kiểm tra mật khẩu mới có trùng khớp không
    if (_newPassController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu xác nhận không khớp!"),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // 3. Kiểm tra độ dài (Tùy chọn)
    if (_newPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu mới phải có ít nhất 6 ký tự"),
          backgroundColor: AppColors.primaryYellow,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 4. Gọi API
    final result = await _userService.changePassword(
      _oldPassController.text,
      _newPassController.text,
    );

    setState(() => _isLoading = false);

    // 5. Xử lý kết quả
    if (mounted) {
      if (result['success']) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Thành công",
              style: TextStyle(color: AppColors.success),
            ),
            content: const Text("Đổi mật khẩu thành công!"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Đóng Dialog
                  Navigator.pop(context); // Quay về trang Profile
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Widget ô nhập mật khẩu dùng chung để code gọn hơn
  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.h3.copyWith(color: AppColors.textBody)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isObscure,
          style: AppStyles.body.copyWith(color: AppColors.textTitle),
          decoration: InputDecoration(
            hintText: "••••••••",
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 18,
              letterSpacing: 2,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: AppColors.textHint,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isObscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textHint,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Đổi mật khẩu", style: AppStyles.h2),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Container chứa form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildPasswordField(
                    label: "Mật khẩu hiện tại",
                    controller: _oldPassController,
                    isObscure: _obscureOld,
                    onToggle: () => setState(() => _obscureOld = !_obscureOld),
                  ),

                  _buildPasswordField(
                    label: "Mật khẩu mới",
                    controller: _newPassController,
                    isObscure: _obscureNew,
                    onToggle: () => setState(() => _obscureNew = !_obscureNew),
                  ),

                  _buildPasswordField(
                    label: "Nhập lại mật khẩu mới",
                    controller: _confirmPassController,
                    isObscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Nút Lưu thay đổi
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChange,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
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
                    : Text("LƯU THAY ĐỔI", style: AppStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
