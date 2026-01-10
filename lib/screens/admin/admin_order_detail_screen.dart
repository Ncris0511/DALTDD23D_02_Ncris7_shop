import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/order_service.dart';
import '../../services/admin_service.dart';

class AdminOrderDetailScreen extends StatefulWidget {
  final int orderId;
  const AdminOrderDetailScreen({super.key, required this.orderId});

  @override
  State<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends State<AdminOrderDetailScreen> {
  final OrderService _orderService = OrderService(); // Để lấy chi tiết
  final AdminService _adminService = AdminService(); // Để update status
  Map<String, dynamic>? _order;
  bool _isLoading = true;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    // Tận dụng hàm getOrderDetail cũ vì cấu trúc dữ liệu giống nhau
    final data = await _orderService.getOrderDetail(widget.orderId);
    if (mounted) {
      setState(() {
        _order = data;
        _isLoading = false;
      });
    }
  }

  // --- 6. CẬP NHẬT TRẠNG THÁI ---
  void _updateStatus(String newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận"),
        content: Text(
          "Bạn muốn đổi trạng thái đơn hàng thành: ${_getStatusText(newStatus)}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Hủy"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Đồng ý",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUpdating = true);
    final success = await _adminService.updateOrderStatus(
      widget.orderId,
      newStatus,
    );
    setState(() => _isUpdating = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật thành công!"),
            backgroundColor: AppColors.success,
          ),
        );
        _fetchDetail(); // Load lại để thấy thay đổi
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi cập nhật!"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Helper UI
  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_order == null)
      return const Scaffold(body: Center(child: Text("Lỗi tải đơn hàng")));

    String currentStatus = _order!['status'];
    List<dynamic> items = _order!['items'] ?? [];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text("Chi tiết đơn hàng"),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Panel điều khiển trạng thái
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Cập nhật trạng thái", style: AppStyles.h3),
                  const SizedBox(height: 12),
                  // Logic hiển thị nút bấm dựa trên trạng thái hiện tại
                  if (currentStatus == 'pending') ...[
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            onPressed: _isUpdating
                                ? null
                                : () => _updateStatus('shipping'),
                            child: const Text(
                              "Xác nhận giao",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                            onPressed: _isUpdating
                                ? null
                                : () => _updateStatus('cancelled'),
                            child: const Text(
                              "Hủy đơn",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else if (currentStatus == 'shipping') ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                        ),
                        onPressed: _isUpdating
                            ? null
                            : () => _updateStatus('delivered'),
                        child: const Text(
                          "Hoàn thành đơn hàng",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ] else ...[
                    Text(
                      "Đơn hàng đã ${_getStatusText(currentStatus)}",
                      style: AppStyles.body.copyWith(
                        color: currentStatus == 'cancelled'
                            ? AppColors.error
                            : AppColors.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Thông tin người nhận
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Thông tin giao hàng", style: AppStyles.h3),
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.person,
                    "Người nhận",
                    _order!['shipping_address'].split(',')[0],
                  ), // Hack nhẹ để lấy tên nếu string gộp
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.location_on,
                    "Địa chỉ",
                    _order!['shipping_address'],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.payment,
                    "Thanh toán",
                    _order!['payment_method'],
                  ),
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.info_outline,
                    "Trạng thái thanh toán",
                    _order!['payment_status'] == 'paid'
                        ? "Đã thanh toán"
                        : "Chưa thanh toán",
                    color: _order!['payment_status'] == 'paid'
                        ? AppColors.success
                        : Colors.orange,
                  ),
                  if (_order!['note'] != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.note, "Ghi chú", _order!['note']),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Danh sách sản phẩm
            Text("Sản phẩm (${items.length})", style: AppStyles.h3),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                final variant = item['variant'];
                final product = variant['product'];

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product['thumbnail_url'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            width: 60,
                            height: 60,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['product_name'],
                              style: AppStyles.body.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${variant['color']} | Size ${variant['size']}",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currency.format(item['price_at_purchase']),
                                  style: AppStyles.body,
                                ),
                                Text(
                                  "x${item['quantity']}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // 4. Tổng kết tiền
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildPriceRow(
                    "Tổng tiền hàng",
                    currency.format(_order!['total_amount']),
                  ),
                  _buildPriceRow(
                    "Phí vận chuyển",
                    currency.format(_order!['shipping_fee']),
                  ),
                  if ((_order!['discount_amount'] ?? 0) > 0)
                    _buildPriceRow(
                      "Giảm giá",
                      "-${currency.format(_order!['discount_amount'])}",
                      color: Colors.green,
                    ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Thành tiền", style: AppStyles.h2),
                      Text(
                        currency.format(_order!['final_amount']),
                        style: AppStyles.price.copyWith(fontSize: 20),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    Color color = Colors.black87,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: AppStyles.body.copyWith(color: Colors.black87),
              children: [
                TextSpan(
                  text: "$label: ",
                  style: const TextStyle(color: Colors.grey),
                ),
                TextSpan(
                  text: value,
                  style: TextStyle(fontWeight: FontWeight.w500, color: color),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color color = Colors.black87,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.body),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
