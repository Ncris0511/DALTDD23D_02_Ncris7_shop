import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/order_service.dart';
import '../../services/address_service.dart';
import 'address_list_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final OrderService _orderService = OrderService();
  final AddressService _addressService = AddressService();
  final _voucherController = TextEditingController();

  List<dynamic> _cartItems = [];
  Map<String, dynamic>? _selectedAddress;

  bool _isLoading = true;
  String _paymentMethod = "COD"; // Mặc định là COD
  double _totalPrice = 0;
  double _shippingFee = 30000; // Phí ship mặc định từ backend
  double _discountAmount = 0;
  String? _appliedVoucherCode;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() async {
    setState(() => _isLoading = true);

    // 1. Lấy địa chỉ
    final addresses = await _addressService.getMyAddresses();
    if (addresses.isNotEmpty) {
      _selectedAddress = addresses.firstWhere(
        (element) => element['is_default'] == true,
        orElse: () => addresses.first,
      );
    }

    // 2. GỌI API GIỎ HÀNG THẬT (Bỏ đoạn Mock data đi)
    _cartItems = await _orderService.getCart();

    // Nếu giỏ hàng rỗng thì hiện thông báo hoặc xử lý tùy ý
    if (_cartItems.isEmpty) {
      // Có thể print ra để debug xem có lấy được không
      print("Giỏ hàng đang trống");
    }

    _calculateTotal();
    setState(() => _isLoading = false);
  }

  void _calculateTotal() {
    double temp = 0;
    try {
      for (var item in _cartItems) {
        // --- SỬA LỖI TẠI ĐÂY ---
        // 1. Lấy giá trị ra (Backend có thể trả về số hoặc chữ)
        var salePrice = item['product']['sale_price'];
        var regularPrice = item['product']['price'];

        // 2. Ép kiểu về String (.toString()) TRƯỚC khi Parse
        // Dù là số hay chữ thì .toString() đều xử lý được hết
        String priceString = (salePrice ?? regularPrice ?? "0").toString();
        double price = double.tryParse(priceString) ?? 0;

        // 3. Làm tương tự với số lượng
        String qtyString = (item['quantity'] ?? "1").toString();
        int quantity = int.tryParse(qtyString) ?? 1;

        temp += price * quantity;
      }
    } catch (e) {
      print("⚠️ Lỗi tính tiền: $e");
    }

    // Cập nhật UI (Tắt xoay)
    if (mounted) {
      setState(() {
        _totalPrice = temp;
      });
    }
  }

  // Hàm xử lý áp mã Voucher
  void _applyVoucher() async {
    if (_voucherController.text.isEmpty) return;

    // Reset discount trước khi check
    setState(() {
      _discountAmount = 0;
      _appliedVoucherCode = null;
    });

    final result = await _orderService.checkVoucher(
      _voucherController.text,
      _totalPrice,
    );

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

  // Hàm đặt hàng
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
      note: "Giao giờ hành chính", // Có thể thêm ô nhập Note nếu cần
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      // Thành công -> Hiện thông báo và về trang chủ
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Đặt hàng thành công!"),
          content: Text("Mã đơn hàng: ${result['order_id']}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Đóng Dialog
                Navigator.of(
                  context,
                ).popUntil((route) => route.isFirst); // Về trang chủ
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

  // --- WIDGETS CON ---

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildAddressSection() {
    return _buildSectionContainer(
      child: InkWell(
        onTap: () async {
          // Mở màn hình chọn địa chỉ
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddressListScreen()),
          );
          if (result != null) {
            setState(() => _selectedAddress = result);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: _selectedAddress == null
                  ? Text(
                      "Vui lòng thêm địa chỉ nhận hàng",
                      style: AppStyles.h3.copyWith(color: AppColors.primaryRed),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_selectedAddress!['recipient_name']} | ${_selectedAddress!['phone_number']}",
                          style: AppStyles.h3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${_selectedAddress!['address_line']}, ${_selectedAddress!['ward']}, ${_selectedAddress!['district']}, ${_selectedAddress!['city']}",
                          style: AppStyles.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(dynamic item) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    // 1. Xử lý giá tiền
    var salePrice = item['product']['sale_price'];
    var regularPrice = item['product']['price'];
    String priceString = (salePrice ?? regularPrice ?? "0").toString();
    double price = double.tryParse(priceString) ?? 0;

    // 2. XỬ LÝ ẢNH (Logic mới)
    String thumbUrl = item['product']['thumbnail_url']?.toString() ?? "";
    String variantUrl = item['variant']['image_url']?.toString() ?? "";

    // Chỉ lấy ảnh biến thể nếu nó hợp lệ (Có chữ http)
    // Nếu ảnh biến thể lỗi -> Tự động quay về lấy ảnh sản phẩm gốc
    String finalImageUrl = (variantUrl.contains("http"))
        ? variantUrl
        : thumbUrl;

    // Nếu cả 2 đều lỗi -> Dùng ảnh giữ chỗ
    if (!finalImageUrl.contains("http")) {
      finalImageUrl = "https://via.placeholder.com/150"; // Ảnh mặc định online
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              finalImageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 80,
                  height: 80,
                  color: Colors.grey[300],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, color: Colors.grey),
                      Text("Lỗi ảnh", style: TextStyle(fontSize: 10)),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // ... (Phần hiển thị tên và giá giữ nguyên như cũ)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['product']['name']?.toString() ?? "Sản phẩm",
                  style: AppStyles.h3,
                  maxLines: 2,
                ),
                Text(
                  "Phân loại: ${item['variant']['color']} - ${item['variant']['size']}",
                  style: AppStyles.body,
                ),
                // ...
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

  Widget _buildVoucherSection() {
    return _buildSectionContainer(
      child: Row(
        children: [
          const Icon(Icons.discount_outlined, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _voucherController,
              decoration: InputDecoration(
                hintText: "Nhập mã Voucher",
                hintStyle: AppStyles.body.copyWith(color: AppColors.textHint),
                border: InputBorder.none,
                isDense: true,
              ),
              style: AppStyles.body,
            ),
          ),
          TextButton(
            onPressed: _applyVoucher,
            child: Text(
              "ÁP DỤNG",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Phương thức thanh toán", style: AppStyles.h3),
          const SizedBox(height: 12),

          // COD
          InkWell(
            onTap: () => setState(() => _paymentMethod = "COD"),
            child: Row(
              children: [
                Icon(Icons.money, color: Colors.blue),
                const SizedBox(width: 12),
                const Expanded(child: Text("Thanh toán khi nhận hàng (COD)")),
                Radio<String>(
                  value: "COD",
                  groupValue: _paymentMethod,
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // MOMO
          InkWell(
            onTap: () => setState(() => _paymentMethod = "MOMO"),
            child: Row(
              children: [
                const Icon(Icons.wallet, color: Colors.pink),
                const SizedBox(width: 12),
                const Expanded(child: Text("Ví điện tử MoMo")),
                Radio<String>(
                  value: "MOMO",
                  groupValue: _paymentMethod,
                  onChanged: (val) => setState(() => _paymentMethod = val!),
                  activeColor: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    double finalTotal = (_totalPrice + _shippingFee) - _discountAmount;
    if (finalTotal < 0) finalTotal = 0;

    return _buildSectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Chi tiết thanh toán", style: AppStyles.h3),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tổng tiền hàng", style: AppStyles.body),
              Text(currencyFormat.format(_totalPrice), style: AppStyles.h3),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Phí vận chuyển", style: AppStyles.body),
              Text(currencyFormat.format(_shippingFee), style: AppStyles.h3),
            ],
          ),
          const SizedBox(height: 8),
          if (_discountAmount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Voucher giảm giá", style: AppStyles.body),
                Text(
                  "-${currencyFormat.format(_discountAmount)}",
                  style: AppStyles.price,
                ),
              ],
            ),
          const Divider(height: 24, color: AppColors.border),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tổng thanh toán", style: AppStyles.h2),
              Text(
                currencyFormat.format(finalTotal),
                style: AppStyles.price.copyWith(fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Thanh toán", style: AppStyles.h2),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAddressSection(),

                  // Danh sách sản phẩm
                  _buildSectionContainer(
                    child: Column(
                      children: _cartItems
                          .map((item) => _buildProductItem(item))
                          .toList(),
                    ),
                  ),

                  _buildVoucherSection(),
                  _buildPaymentMethodSection(),
                  _buildSummarySection(),

                  // Khoảng trống để nút đặt hàng không che nội dung
                  const SizedBox(height: 80),
                ],
              ),
            ),

      // Nút Đặt hàng dưới cùng
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
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
