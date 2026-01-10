import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ncris7shop/screens/user/all_reviews_screen.dart';
import 'package:ncris7shop/widgets/cart_icon_badge.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();

  Map<String, dynamic>? _product;
  List<dynamic> _reviews = [];
  List<dynamic> _relatedProducts = [];
  bool _isLoading = true;
  bool _isFavorite = false; // Trạng thái tim

  // Logic Xem thêm/Thu gọn mô tả
  bool _isDescriptionExpanded = false;

  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  List<String> _imageGallery = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
    _checkIfLiked(); // Kiểm tra xem đã tim chưa
  }

  // Hàm kiểm tra trạng thái yêu thích
  void _checkIfLiked() async {
    // Vì API getDetailProduct chưa trả về is_liked, ta lấy list wishlist về soi ID
    final wishlist = await _wishlistService.getMyWishlist();
    if (mounted) {
      // Tìm xem ID sản phẩm hiện tại có trong list không
      bool found = wishlist.any(
        (item) => item['product_id'] == widget.productId,
      );
      setState(() {
        _isFavorite = found;
      });
    }
  }

  // Hàm xử lý bấm tim
  void _toggleFavorite() async {
    // Đổi trạng thái UI ngay cho mượt
    setState(() {
      _isFavorite = !_isFavorite;
    });

    // Gọi API
    bool success = await _wishlistService.toggleWishlist(widget.productId);

    if (!success) {
      // Nếu lỗi thì quay lại trạng thái cũ
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Lỗi kết nối!")));
      }
    }
  }

  void _fetchData() async {
    final productData = await _productService.getProductDetail(
      widget.productId,
    );
    final reviewData = await _productService.getProductReviews(
      widget.productId,
    );
    final relatedData = await _productService.getRelatedProducts(
      widget.productId,
    );

    if (mounted) {
      setState(() {
        _product = productData;
        _reviews = reviewData;
        _relatedProducts = relatedData;
        _isLoading = false;

        if (_product != null) {
          _imageGallery = [];
          if (_product!['thumbnail_url'] != null) {
            _imageGallery.add(_product!['thumbnail_url']);
          }
          List<dynamic> variants = _product!['variants'] ?? [];
          for (var v in variants) {
            String? vImage = v['image_url'];
            if (vImage != null &&
                vImage.isNotEmpty &&
                !_imageGallery.contains(vImage)) {
              _imageGallery.add(vImage);
            }
          }
        }
      });
    }
  }

  void _showAddToCartModal() {
    if (_product == null) return;
    List<dynamic> variants = _product!['variants'] ?? [];
    int quantity = 1;
    Map<String, dynamic>? selectedVariant;
    if (variants.isNotEmpty) selectedVariant = variants[0];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final currencyFormat = NumberFormat.currency(
              locale: 'vi_VN',
              symbol: 'đ',
            );
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          selectedVariant?['image_url'] ??
                              _product!['thumbnail_url'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[200],
                            width: 80,
                            height: 80,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currencyFormat.format(
                                _product!['sale_price'] ?? _product!['price'],
                              ),
                              style: AppStyles.price.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Kho: ${selectedVariant?['stock_quantity'] ?? 0}",
                              style: AppStyles.body.copyWith(
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 30),
                  Text("Chọn phân loại:", style: AppStyles.h3),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: variants.map((v) {
                      bool isSelected = selectedVariant == v;
                      return ChoiceChip(
                        label: Text(
                          "${v['color']} - ${v['size']}",
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary.withOpacity(0.1),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        onSelected: (val) =>
                            setModalState(() => selectedVariant = v),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Số lượng:", style: AppStyles.h3),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () => quantity > 1
                                  ? setModalState(() => quantity--)
                                  : null,
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () => setModalState(() => quantity++),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        if (selectedVariant == null) return;
                        Navigator.pop(context);
                        bool s = await _cartService.addToCart(
                          _product!['product_id'],
                          selectedVariant!['variant_id'],
                          quantity,
                        );
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                s ? "Đã thêm vào giỏ!" : "Lỗi thêm giỏ hàng",
                              ),
                              backgroundColor: s
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          );
                      },
                      child: const Text(
                        "THÊM VÀO GIỎ",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_product == null)
      return const Scaffold(
        body: Center(child: Text("Sản phẩm không tồn tại")),
      );

    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    var price = _product!['price'];
    var salePrice = _product!['sale_price'];
    List<dynamic> variants = _product!['variants'] ?? [];

    double avgRating = 0;
    if (_reviews.isNotEmpty) {
      avgRating =
          _reviews.map((r) => r['rating']).reduce((a, b) => a + b) /
          _reviews.length;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: const CartIconWithBadge(color: Colors.black),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER ẢNH
            SizedBox(
              height: 420,
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _imageGallery.length,
                    onPageChanged: (idx) =>
                        setState(() => _currentImageIndex = idx),
                    itemBuilder: (ctx, idx) =>
                        Image.network(_imageGallery[idx], fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${_currentImageIndex + 1}/${_imageGallery.length}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 2. GIÁ & TÊN & TIM
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (salePrice != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryRed,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "SALE SỐC",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      // Nút Tim đã được gắn logic
                      GestureDetector(
                        onTap: _toggleFavorite,
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite
                              ? AppColors.primaryRed
                              : Colors.grey,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _product!['name'],
                    style: AppStyles.h2.copyWith(fontSize: 20, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currency.format(salePrice ?? price),
                        style: AppStyles.price.copyWith(fontSize: 24),
                      ),
                      if (salePrice != null) ...[
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            currency.format(price),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 3. SIZE & BIẾN THỂ
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Phân loại", style: AppStyles.h3),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _imageGallery.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        bool isSelected = _currentImageIndex == index;
                        return GestureDetector(
                          onTap: () => _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          ),
                          child: Container(
                            width: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(
                                _imageGallery[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: variants.map((v) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          "${v['color']} / Size ${v['size']}",
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 4. MÔ TẢ
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mô tả sản phẩm",
                    style: AppStyles.h3.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _product!['description'] ?? "Đang cập nhật...",
                    style: AppStyles.body.copyWith(
                      height: 1.6,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                    maxLines: _isDescriptionExpanded ? null : 4,
                    overflow: _isDescriptionExpanded
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 20,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _isDescriptionExpanded ? "Thu gọn" : "Xem thêm",
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              _isDescriptionExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 5. ĐÁNH GIÁ
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Đánh giá sản phẩm",
                        style: AppStyles.h3.copyWith(fontSize: 16),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AllReviewsScreen(
                                reviews: _reviews,
                                averageRating: avgRating,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "Xem tất cả (${_reviews.length}) >",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  _reviews.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              "Chưa có đánh giá nào",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length > 3 ? 3 : _reviews.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 30),
                          itemBuilder: (context, index) {
                            final review = _reviews[index];

                            // Lấy thông tin biến thể (nếu có) từ backend trả về
                            final variant = review['variant'];

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage: NetworkImage(
                                    review['user']['avatar_url'] ??
                                        "https://via.placeholder.com/150",
                                  ),
                                  backgroundColor: Colors.grey[200],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        review['user']['full_name'] ??
                                            "Người dùng",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),

                                      // Hàng sao
                                      Row(
                                        children: List.generate(
                                          5,
                                          (i) => Icon(
                                            Icons.star,
                                            size: 14,
                                            color: i < review['rating']
                                                ? const Color(0xFFFFC107)
                                                : Colors.grey[300],
                                          ),
                                        ),
                                      ),
                                      if (variant != null) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          "Phân loại: ${variant['color']} / ${variant['size']}",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors
                                                .grey[600], // Màu xám nhạt cho tinh tế
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 8),
                                      Text(
                                        review['comment'] ?? "",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          height: 1.4,
                                          color: Colors.black87,
                                        ),
                                      ),

                                      const SizedBox(height: 4),
                                      Text(
                                        review['created_at'] != null
                                            ? DateFormat('dd/MM/yyyy').format(
                                                DateTime.parse(
                                                  review['created_at'],
                                                ),
                                              )
                                            : "",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // 6. SẢN PHẨM TƯƠNG TỰ
            if (_relatedProducts.isNotEmpty)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "Có thể bạn cũng thích",
                        style: AppStyles.h3.copyWith(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _relatedProducts.length,
                        itemBuilder: (context, index) {
                          final p = _relatedProducts[index];
                          return Container(
                            width: 150,
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: InkWell(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ProductDetailScreen(
                                    productId: p['product_id'],
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(8),
                                      ),
                                      child: Image.network(
                                        p['thumbnail_url'],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p['name'],
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            height: 1.3,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          currency.format(
                                            p['sale_price'] ?? p['price'],
                                          ),
                                          style: AppStyles.price.copyWith(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.black87,
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _showAddToCartModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "THÊM VÀO GIỎ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
