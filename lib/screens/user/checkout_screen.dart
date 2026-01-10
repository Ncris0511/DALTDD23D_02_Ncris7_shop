import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ncris7shop/screens/user/main_screen.dart'; // <--- Import MainScreen để về trang chủ có Menu
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/order_service.dart';
import '../../services/address_service.dart';
import 'address_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<dynamic> items;
  const CheckoutScreen({super.key, required this.items});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();
  final _voucherController = TextEditingController();

  Map<String, dynamic>? _selectedAddress;
  bool _isLoading = false;
  String _paymentMethod = "COD";
  double _totalPrice = 0;
  double _shippingFee = 30000;
  double _discountAmount = 0;
  String? _appliedVoucherCode;

  @override
  void initState() {
    super.initState();
    _initData();
    _calculateTotal();
  }

  void _initData() async {
    final addresses = await _addressService.getMyAddresses();
    if (mounted && addresses.isNotEmpty) {
      setState(() {
        _selectedAddress = addresses.firstWhere(
          (element) => element['is_default'] == true,
          orElse: () => addresses.first,
        );
      });
    }
  }

  void _calculateTotal() {
    double temp = 0;
    try {
      for (var item in widget.items) {
        var salePrice = item['product']['sale_price'];
        var regularPrice = item['product']['price'];
        double price =
            double.tryParse((salePrice ?? regularPrice ?? "0").toString()) ?? 0;
        int quantity = int.tryParse((item['quantity'] ?? "1").toString()) ?? 1;
        temp += price * quantity;
      }
    } catch (e) {
      print("⚠️ Lỗi tính tiền: $e");
    }
    if (mounted) setState(() => _totalPrice = temp);
  }

  void _applyVoucher() async {
    if (_voucherController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập mã Voucher!")),
      );
      return;
    }
    setState(() {
      _discountAmount = 0;
      _appliedVoucherCode = null;
    });

    final result = await _orderService.checkVoucher(
      _voucherController.text.trim(),
      _totalPrice,
    );

    if (mounted) {
      if (result['success']) {
        final data = result['data'];
        setState(() {
          _discountAmount = (data['discount_amount'] as num).toDouble();
          _appliedVoucherCode = data['code'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message']),
            backgroundColor: AppColors.success,
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

  void _placeOrder() async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn địa chỉ giao hàng!")),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _orderService.createOrder(
      addressId: _selectedAddress!['address_id'],
      paymentMethod: _paymentMethod,
      voucherCode: _appliedVoucherCode,
      note: "Giao giờ hành chính",
      items: widget.items,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success']) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Text("Đặt hàng thành công!"),
            content: Text("Mã đơn hàng: ${result['order_id']}"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const MainScreen()),
                    (route) => false,
                  );
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

  // --- WIDGETS GIAO DIỆN CŨ ĐẸP ---

  Widget _buildSection({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildProductItem(dynamic item) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    var salePrice = item['product']['sale_price'];
    var regularPrice = item['product']['price'];
    double price =
        double.tryParse((salePrice ?? regularPrice ?? "0").toString()) ?? 0;

    String thumbUrl = item['product']['thumbnail_url']?.toString() ?? "";
    String variantUrl = item['variant']['image_url']?.toString() ?? "";
    String finalImageUrl = (variantUrl.contains("http"))
        ? variantUrl
        : thumbUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: finalImageUrl.contains("http")
                ? Image.network(
                    finalImageUrl,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                    ),
                  )
                : Container(width: 70, height: 70, color: Colors.grey[200]),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product']['name'] ?? "",
                  style: AppStyles.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "Phân loại: ${item['variant']['color']} - Size ${item['variant']['size']}",
                  style: AppStyles.body.copyWith(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      currencyFormat.format(price),
                      style: AppStyles.price.copyWith(fontSize: 15),
                    ),
                    Text("x${item['quantity']}", style: AppStyles.body),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    double finalTotal = (_totalPrice + _shippingFee) - _discountAmount;
    if (finalTotal < 0) finalTotal = 0;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Thanh toán"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSection(
                    child: InkWell(
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddressListScreen(),
                          ),
                        );
                        if (result != null)
                          setState(() => _selectedAddress = result);
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: AppColors.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _selectedAddress == null
                                ? Text(
                                    "Vui lòng chọn địa chỉ nhận hàng",
                                    style: AppStyles.h3.copyWith(
                                      color: AppColors.primaryRed,
                                    ),
                                  )
                                : Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${_selectedAddress!['recipient_name']} | ${_selectedAddress!['phone_number']}",
                                        style: AppStyles.h3,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${_selectedAddress!['address_line']}, ${_selectedAddress!['city']}",
                                        style: AppStyles.body,
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                  _buildSection(
                    child: Column(
                      children: widget.items
                          .map((item) => _buildProductItem(item))
                          .toList(),
                    ),
                  ),
                  _buildSection(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.discount_outlined,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _voucherController,
                            decoration: const InputDecoration(
                              hintText: "Nhập Voucher",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _applyVoucher,
                          child: const Text(
                            "ÁP DỤNG",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Thanh toán khi nhận hàng (COD)"),
                          leading: const Icon(Icons.money, color: Colors.blue),
                          trailing: Radio(
                            value: "COD",
                            groupValue: _paymentMethod,
                            onChanged: (v) =>
                                setState(() => _paymentMethod = v!),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Ví MoMo"),
                          leading: const Icon(Icons.wallet, color: Colors.pink),
                          trailing: Radio(
                            value: "MOMO",
                            groupValue: _paymentMethod,
                            onChanged: (v) =>
                                setState(() => _paymentMethod = v!),
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildSection(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Tổng tiền hàng"),
                            Text(currencyFormat.format(_totalPrice)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Phí ship"),
                            Text(currencyFormat.format(_shippingFee)),
                          ],
                        ),
                        if (_discountAmount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Voucher",
                                style: TextStyle(color: Colors.green),
                              ),
                              Text(
                                "-${currencyFormat.format(_discountAmount)}",
                                style: const TextStyle(color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Thành tiền",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              currencyFormat.format(finalTotal),
                              style: const TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Text("ĐẶT HÀNG", style: AppStyles.buttonText),
          ),
        ),
      ),
    );
  }
}
