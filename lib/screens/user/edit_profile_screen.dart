import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _avatarController =
      TextEditingController(); // Thêm controller cho Avatar
  final _emailController = TextEditingController(); // Email (Read-only)

  final UserService _userService = UserService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user['full_name'] ?? '';
    _phoneController.text = widget.user['phone_number'] ?? '';
    _avatarController.text = widget.user['avatar_url'] ?? '';
    _emailController.text = widget.user['email'] ?? '';
  }

  void _handleUpdate() async {
    setState(() => _isLoading = true);
    // Gọi API updateProfile trong userController.js
    final success = await _userService.updateProfile({
      'full_name': _nameController.text,
      'phone_number': _phoneController.text,
      'avatar_url': _avatarController.text,
    });
    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cập nhật thành công!"),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lỗi cập nhật!"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool readOnly = false,
    IconData? icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppStyles.h3.copyWith(color: AppColors.textBody)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          readOnly: readOnly,
          style: AppStyles.body.copyWith(
            color: readOnly ? Colors.grey : AppColors.textTitle,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: readOnly ? Colors.grey[100] : Colors.white,
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.textHint)
                : null,
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
        title: Text("Chỉnh sửa hồ sơ", style: AppStyles.h2),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Ảnh đại diện (Review)
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                  image: _avatarController.text.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(_avatarController.text),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _avatarController.text.isEmpty
                    ? const Icon(
                        Icons.person,
                        size: 50,
                        color: AppColors.textHint,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 30),

            _buildTextField(
              "Email (Không thể thay đổi)",
              _emailController,
              readOnly: true,
              icon: Icons.email_outlined,
            ),
            _buildTextField(
              "Họ và tên",
              _nameController,
              icon: Icons.person_outline,
            ),
            _buildTextField(
              "Số điện thoại",
              _phoneController,
              icon: Icons.phone_outlined,
            ),
            _buildTextField(
              "Link ảnh đại diện (URL)",
              _avatarController,
              icon: Icons.link,
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("LƯU THAY ĐỔI", style: AppStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
