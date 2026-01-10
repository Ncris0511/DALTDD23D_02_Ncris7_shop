import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/wishlist_service.dart';
import 'product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  final WishlistService _wishlistService = WishlistService();
  List<dynamic> _wishlistItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  void _fetchWishlist() async {
    final data = await _wishlistService.getMyWishlist();
    if (mounted) {
      setState(() {
        _wishlistItems = data;
        _isLoading = false;
      });
    }
  }

  void _removeFromWishlist(int productId) async {
    // Xóa tạm trên giao diện cho mượt (Optimistic UI)
    final index = _wishlistItems.indexWhere(
      (item) => item['product_id'] == productId,
    );
    final deletedItem = index != -1 ? _wishlistItems[index] : null;

    setState(() {
      _wishlistItems.removeWhere((item) => item['product_id'] == productId);
    });

    // Gọi API xóa thật
    bool success = await _wishlistService.toggleWishlist(productId);

    if (!success && deletedItem != null && mounted) {
      // Nếu lỗi thì hoàn tác
      setState(() {
        _wishlistItems.insert(index, deletedItem);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Lỗi kết nối!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Sản phẩm yêu thích", style: AppStyles.h2),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _wishlistItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text("Danh sách yêu thích trống", style: AppStyles.body),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7, // Tỷ lệ khung hình card
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _wishlistItems.length,
              itemBuilder: (context, index) {
                final item = _wishlistItems[index];
                final product = item['product']; // Lấy thông tin sp từ include

                // Phòng trường hợp sản phẩm bị xóa bên admin
                if (product == null) return const SizedBox.shrink();

                return GestureDetector(
                  onTap: () async {
                    // Chuyển sang chi tiết
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: product['product_id'],
                        ),
                      ),
                    );
                    // Khi quay lại thì reload để cập nhật nếu user bỏ tim bên trang chi tiết
                    _fetchWishlist();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  product['thumbnail_url'] ?? "",
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      Container(color: Colors.grey[200]),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'],
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppStyles.h3.copyWith(fontSize: 13),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    currency.format(
                                      product['sale_price'] ?? product['price'],
                                    ),
                                    style: AppStyles.price,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Nút Xóa (Thùng rác)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: () =>
                                _removeFromWishlist(product['product_id']),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.primaryRed,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
