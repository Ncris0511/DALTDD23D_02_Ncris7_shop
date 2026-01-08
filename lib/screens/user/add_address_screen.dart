import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

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

  void _handleSave() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _cityController.text.isEmpty ||
        _districtController.text.isEmpty ||
        _wardController.text.isEmpty ||
        _addressLineController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng điền đầy đủ thông tin!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final body = {
      "recipient_name": _nameController.text,
      "phone_number": _phoneController.text,
      "city": _cityController.text,
      "district": _districtController.text,
      "ward": _wardController.text,
      "address_line": _addressLineController.text,
      "is_default": _isDefault,
    };

    final result = await _addressService.addAddress(body);

    setState(() => _isLoading = false);

    if (result['success']) {
      // Trả về true để màn hình trước biết là cần load lại danh sách
      if (mounted) Navigator.pop(context, true);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

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
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Thêm địa chỉ mới", style: AppStyles.h2),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
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

                  const Divider(height: 30),
                  Text("Địa chỉ", style: AppStyles.h3),
                  const SizedBox(height: 16),
                  _buildTextField("Tỉnh / Thành phố", _cityController),
                  _buildTextField("Quận / Huyện", _districtController),
                  _buildTextField("Phường / Xã", _wardController),
                  _buildTextField(
                    "Tên đường, Tòa nhà, Số nhà",
                    _addressLineController,
                  ),
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
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text("HOÀN THÀNH", style: AppStyles.buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
