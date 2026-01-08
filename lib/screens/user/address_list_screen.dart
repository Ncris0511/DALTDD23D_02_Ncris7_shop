import 'package:flutter/material.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/address_service.dart';
import 'add_address_screen.dart'; // <--- Import màn hình thêm mới

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

  // Hàm load lại danh sách
  void _fetchAddresses() async {
    setState(() => _isLoading = true); // Hiện loading khi refresh
    final data = await _addressService.getMyAddresses();
    if (mounted) {
      setState(() {
        _addresses = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Chọn địa chỉ", style: AppStyles.h2),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _addresses.isEmpty
          ? Center(child: Text("Chưa có địa chỉ nào", style: AppStyles.body))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final addr = _addresses[index];
                return Card(
                  color: AppColors.white,
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  child: ListTile(
                    title: Text(
                      "${addr['recipient_name']} | ${addr['phone_number']}",
                      style: AppStyles.h3,
                    ),
                    subtitle: Text(
                      "${addr['address_line']}, ${addr['ward']}, ${addr['district']}, ${addr['city']}",
                      style: AppStyles.body,
                    ),
                    trailing: addr['is_default'] == true
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context, addr);
                    },
                  ),
                );
              },
            ),
      // Nút thêm địa chỉ
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Chuyển sang trang thêm địa chỉ và chờ kết quả trả về
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddAddressScreen()),
          );

          // Nếu thêm thành công (result == true) thì load lại danh sách
          if (result == true) {
            _fetchAddresses();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
