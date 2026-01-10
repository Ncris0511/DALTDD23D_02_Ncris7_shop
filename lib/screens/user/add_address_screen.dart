import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  // Biến này để nhận dữ liệu khi bấm nút Sửa
  final Map<String, dynamic>? existingAddress;

  const AddAddressScreen({super.key, this.existingAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _addressLineController = TextEditingController();

  bool _isDefault = false;
  bool _isLoading = false;
  final AddressService _addressService = AddressService();

  @override
  void initState() {
    super.initState();
    _initData();
  }

  //Giải phóng bộ nhớ khi thoát màn hình
  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _addressLineController.dispose();
    super.dispose();
  }

  // Hàm điền dữ liệu cũ vào form (Nếu là Sửa)
  void _initData() {
    if (widget.existingAddress != null) {
      final data = widget.existingAddress!;
      _nameController.text = data['recipient_name']?.toString() ?? '';
      _phoneController.text = data['phone_number']?.toString() ?? '';
      _cityController.text = data['city']?.toString() ?? '';
      _districtController.text = data['district']?.toString() ?? '';
      _wardController.text = data['ward']?.toString() ?? '';
      _addressLineController.text = data['address_line']?.toString() ?? '';

      // Xử lý logic true/false hoặc 1/0 cho địa chỉ mặc định (Fix lỗi SQL Server trả về 1)
      var def = data['is_default'];
      if (def == true ||
          def == 1 ||
          def.toString() == 'true' ||
          def.toString() == '1') {
        _isDefault = true;
      } else {
        _isDefault = false;
      }
    }
  }

  void _handleSave() async {
    // 1. Kiểm tra nhập liệu
    if (_nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _cityController.text.trim().isEmpty ||
        _districtController.text.trim().isEmpty ||
        _wardController.text.trim().isEmpty ||
        _addressLineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final body = {
      "recipient_name": _nameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "city": _cityController.text.trim(),
      "district": _districtController.text.trim(),
      "ward": _wardController.text.trim(),
      "address_line": _addressLineController.text.trim(),
      "is_default": _isDefault,
    };

    Map<String, dynamic> result;

    try {
      // 2. Kiểm tra chế độ Thêm hay Sửa
      if (widget.existingAddress != null) {
        // CHẾ ĐỘ SỬA
        // Lấy ID (Ưu tiên lấy 'address_id', nếu không có thì thử lấy 'id')
        int id =
            widget.existingAddress!['address_id'] ??
            widget.existingAddress!['id'];
        result = await _addressService.updateAddress(id, body);
      } else {
        // CHẾ ĐỘ THÊM MỚI
        result = await _addressService.addAddress(body);
      }

      setState(() => _isLoading = false);

      // 3. Xử lý kết quả
      if (result['success'] == true) {
        if (mounted) {
          Navigator.pop(
            context,
            true,
          ); // Trả về true để màn hình danh sách load lại
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? "Có lỗi xảy ra"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi ứng dụng: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Widget ô nhập liệu chuẩn Style
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        style: AppStyles.body.copyWith(color: AppColors.textTitle),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppStyles.body.copyWith(color: AppColors.textHint),
          filled: true,
          fillColor: AppColors.white,
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
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.existingAddress != null;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isEditing ? "Cập nhật địa chỉ" : "Thêm địa chỉ mới",
          style: AppStyles.h2,
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thông tin liên hệ", style: AppStyles.h3),
                  const SizedBox(height: 16),
                  _buildTextField("Họ và tên", _nameController),
                  _buildTextField(
                    "Số điện thoại",
                    _phoneController,
                    type: TextInputType.phone,
                  ),

                  const Divider(height: 30, color: AppColors.border),

                  Text("Địa chỉ nhận hàng", style: AppStyles.h3),
                  const SizedBox(height: 16),
                  _buildTextField("Tỉnh / Thành phố", _cityController),
                  _buildTextField("Quận / Huyện", _districtController),
                  _buildTextField("Phường / Xã", _wardController),
                  _buildTextField("Tên đường, Số nhà", _addressLineController),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Nút gạt Mặc định
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SwitchListTile(
                title: Text("Đặt làm địa chỉ mặc định", style: AppStyles.body),
                value: _isDefault,
                activeColor: AppColors.primary,
                onChanged: (bool value) {
                  setState(() => _isDefault = value);
                },
              ),
            ),
            const SizedBox(height: 30),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing ? "LƯU THAY ĐỔI" : "HOÀN THÀNH",
                        style: AppStyles.buttonText,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
