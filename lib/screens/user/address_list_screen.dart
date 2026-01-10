import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/address_service.dart';
import 'add_address_screen.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  final AddressService _addressService = AddressService();
  List<dynamic> _addresses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  // Hàm tải danh sách từ API
  void _fetchAddresses() async {
    setState(() => _isLoading = true);
    final data = await _addressService.getMyAddresses();
    if (mounted) {
      setState(() {
        _addresses = data;
        _isLoading = false;
      });
    }
  }

  // Hàm xử lý xóa địa chỉ
  void _deleteAddress(int id) async {
    // 1. Hiện popup xác nhận
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Xác nhận", style: AppStyles.h2),
        content: Text(
          "Bạn có chắc muốn xóa địa chỉ này không?",
          style: AppStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("Hủy", style: AppStyles.body),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              "Xóa",
              style: AppStyles.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );

    // 2. Nếu chọn OK -> Gọi API xóa
    if (confirm == true) {
      setState(() => _isLoading = true);
      // Gọi hàm delete bên service
      final success = await _addressService.deleteAddress(id);

      if (success) {
        _fetchAddresses(); // Load lại danh sách sau khi xóa xong
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Đã xóa địa chỉ thành công!"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Lỗi khi xóa địa chỉ!"),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Địa chỉ của tôi", style: AppStyles.h2),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_off, size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  Text("Chưa có địa chỉ nào", style: AppStyles.body),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final addr = _addresses[index];

                //  LOGIC QUAN TRỌNG: XỬ LÝ HIỂN THỊ MẶC ĐỊNH
                // Chấp nhận cả true, 1 (số), "true", "1" (chuỗi)
                var rawDef = addr['is_default'];
                bool isDefault =
                    rawDef == true ||
                    rawDef == 1 ||
                    rawDef.toString() == 'true' ||
                    rawDef.toString() == '1';

                return Card(
                  color: AppColors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      // Nếu là mặc định thì viền xanh, còn lại viền xám
                      color: isDefault ? AppColors.primary : AppColors.border,
                      width: isDefault ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      // Bấm vào card -> Chọn địa chỉ để đặt hàng
                      Navigator.pop(context, addr);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon thay đổi: Check xanh (Mặc định) hoặc Định vị (Thường)
                          Icon(
                            isDefault
                                ? Icons.check_circle
                                : Icons.location_on_outlined,
                            color: isDefault
                                ? AppColors.primary
                                : AppColors.textHint,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${addr['recipient_name']} | ${addr['phone_number']}",
                                        style: AppStyles.h3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    //HIỂN THỊ NHÃN MẶC ĐỊNH
                                    if (isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(
                                            0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: AppColors.primary,
                                          ),
                                        ),
                                        child: const Text(
                                          "Mặc định",
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${addr['address_line']}, ${addr['ward']}, ${addr['district']}, ${addr['city']}",
                                  style: AppStyles.body.copyWith(
                                    color: AppColors.textBody,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const Divider(
                                  height: 20,
                                  color: AppColors.border,
                                ),

                                //Hàng nút thao tác (Sửa / Xóa)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    // Nút Sửa
                                    InkWell(
                                      onTap: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddAddressScreen(
                                              existingAddress: addr,
                                            ),
                                          ),
                                        );
                                        // Sửa xong thì load lại để cập nhật trạng thái
                                        if (result == true) _fetchAddresses();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.edit,
                                              size: 16,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Sửa",
                                              style: AppStyles.body.copyWith(
                                                color: Colors.blue,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Nút Xóa
                                    InkWell(
                                      onTap: () {
                                        // Kiểm tra ID (nếu backend trả về 'address_id' hoặc 'id')
                                        int idToDelete =
                                            addr['address_id'] ?? addr['id'];
                                        _deleteAddress(idToDelete);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.delete_outline,
                                              size: 16,
                                              color: AppColors.error,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "Xóa",
                                              style: AppStyles.body.copyWith(
                                                color: AppColors.error,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

      // Nút thêm mới
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          );

          if (result == true) {
            _fetchAddresses();
          }
        },
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}
