import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/order_service.dart';
import 'add_review_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final OrderService _orderService = OrderService();
  Map<String, dynamic>? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  void _fetchDetail() async {
    final data = await _orderService.getOrderDetail(widget.orderId);
    if (mounted) {
      setState(() {
        _order = data;
        _isLoading = false;
      });
    }
  }

  void _handleCancelOrder() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          "Xác nhận hủy",
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text("Bạn có chắc chắn muốn hủy đơn hàng này không?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Không"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              "Hủy đơn",
              style: TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final success = await _orderService.cancelOrder(widget.orderId);

    if (success) {
      await Future.delayed(const Duration(milliseconds: 500));
      _fetchDetail();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Đã hủy đơn hàng thành công!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Lỗi hủy đơn! Có thể đơn đã được giao."),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'shipping':
        return Colors.blue;
      case 'delivered':
        return AppColors.success;
      case 'completed':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'shipping':
        return 'Đang giao';
      case 'delivered':
        return 'Giao thành công';
      case 'completed':
        return 'Đã hoàn thành';
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

    List<dynamic> items = _order!['items'] ?? [];
    bool canReview =
        _order!['status'] == 'delivered' || _order!['status'] == 'completed';
    bool canCancel = _order!['status'] == 'pending';

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Chi tiết đơn #${widget.orderId}", style: AppStyles.h2),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Trạng thái đơn hàng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping_outlined,
                    color: _getStatusColor(_order!['status']),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Trạng thái đơn hàng", style: AppStyles.body),
                      Text(
                        _getStatusText(_order!['status']),
                        style: AppStyles.h3.copyWith(
                          color: _getStatusColor(_order!['status']),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 2. Địa chỉ
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
                  Text("Địa chỉ nhận hàng", style: AppStyles.h3),
                  const Divider(height: 20),
                  Text(
                    _order!['shipping_address'] ?? "Không có địa chỉ",
                    style: AppStyles.body,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Ghi chú: ${_order!['note'] ?? 'Không có'}",
                    style: AppStyles.body.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // 3. Danh sách sản phẩm
            Text("Sản phẩm đã mua", style: AppStyles.h3),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final variant = item['variant'] ?? {}; // Tránh lỗi null
                final product = variant['product'] ?? {};

                // Lấy thông tin an toàn
                String imageUrl = product['thumbnail_url'] ?? '';
                String productName = product['name'] ?? 'Sản phẩm';
                String variantInfo =
                    "${variant['color'] ?? ''} - Size ${variant['size'] ?? ''}";
                int variantId =
                    item['variant_id'] ?? 0; // Lấy trực tiếp từ item
                int productId = product['product_id'] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageUrl,
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
                                  productName,
                                  style: AppStyles.body.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  "Phân loại: $variantInfo",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      currency.format(
                                        item['price_at_purchase'],
                                      ),
                                      style: AppStyles.body,
                                    ),
                                    Text(
                                      "x${item['quantity']}",
                                      style: AppStyles.body,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // NÚT ĐÁNH GIÁ (QUAN TRỌNG)
                      if (canReview) ...[
                        const Divider(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AddReviewScreen(
                                    orderId: widget.orderId,
                                    productId: productId,

                                    variantId: variantId,

                                    productName: productName,
                                    productImage: imageUrl,
                                  ),
                                ),
                              );
                              if (result == true) {
                                // Reload
                              }
                            },
                            icon: const Icon(
                              Icons.star_rate_rounded,
                              size: 18,
                              color: Colors.amber,
                            ),
                            label: const Text(
                              "Đánh giá",
                              style: TextStyle(color: Colors.black87),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.amber),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
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
                    "+${currency.format(_order!['shipping_fee'])}",
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
            const SizedBox(height: 20),
            if (canCancel)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _handleCancelOrder,
                  icon: const Icon(
                    Icons.cancel_outlined,
                    color: AppColors.error,
                  ),
                  label: const Text(
                    "HỦY ĐƠN HÀNG",
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    String value, {
    Color color = Colors.black,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.body),
          Text(
            value,
            style: AppStyles.body.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
