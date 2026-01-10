import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/home_service.dart';
import 'product_detail_screen.dart';
import '../../widgets/cart_icon_badge.dart'; // Import widget giỏ hàng

class CategoryProductsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final HomeService _homeService = HomeService();

  List<dynamic> _allProducts = []; // List gốc
  List<dynamic> _displayProducts = []; // List đang hiển thị

  bool _isLoading = true;
  String _sortType = "default";

  // Biến lọc giá: Mặc định từ 0 đến 10 triệu
  RangeValues _currentRangeValues = const RangeValues(0, 10000000);
  final double _maxPriceLimit = 20000000; // Max thanh trượt là 20tr

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() async {
    setState(() => _isLoading = true);
    final data = await _homeService.getProducts(categoryId: widget.categoryId);

    if (mounted) {
      setState(() {
        _allProducts = data;
        _displayProducts = data;
        _isLoading = false;
        // Reset bộ lọc mỗi khi vào danh mục mới nếu cần
        // _currentRangeValues = const RangeValues(0, 10000000);
      });
    }
  }

  // --- LOGIC LỌC & SẮP XẾP ĐÃ SỬA ---
  void _applyFilterAndSort() {
    List<dynamic> temp = List.from(_allProducts);

    // 1. Lọc theo giá
    // Lỗi thường gặp: Dữ liệu null hoặc parse string bị lỗi. Dùng tryParse an toàn hơn.
    temp = temp.where((p) {
      var rawPrice = p['sale_price'] ?? p['price'];
      double price = double.tryParse(rawPrice.toString()) ?? 0;

      // Logic: Giá sản phẩm phải nằm trong khoảng user chọn
      return price >= _currentRangeValues.start &&
          price <= _currentRangeValues.end;
    }).toList();

    // 2. Sắp xếp
    if (_sortType == 'price_asc') {
      temp.sort((a, b) {
        double p1 =
            double.tryParse((a['sale_price'] ?? a['price']).toString()) ?? 0;
        double p2 =
            double.tryParse((b['sale_price'] ?? b['price']).toString()) ?? 0;
        return p1.compareTo(p2);
      });
    } else if (_sortType == 'price_desc') {
      temp.sort((a, b) {
        double p1 =
            double.tryParse((a['sale_price'] ?? a['price']).toString()) ?? 0;
        double p2 =
            double.tryParse((b['sale_price'] ?? b['price']).toString()) ?? 0;
        return p2.compareTo(p1);
      });
    }

    setState(() {
      _displayProducts = temp;
    });
  }

  // BottomSheet Bộ lọc nâng cao
  void _showFilterSheet() {
    // Tạo biến tạm để lưu giá trị khi user đang kéo (chưa bấm áp dụng)
    RangeValues tempRangeValues = _currentRangeValues;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final currency = NumberFormat.currency(
          locale: 'vi_VN',
          symbol: 'đ',
          decimalDigits: 0,
        );

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Lọc theo giá", style: AppStyles.h2),
                  const SizedBox(height: 20),

                  // Hiển thị số tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currency.format(tempRangeValues.start),
                        style: AppStyles.h3,
                      ),
                      Text(
                        currency.format(tempRangeValues.end),
                        style: AppStyles.h3,
                      ),
                    ],
                  ),

                  // Thanh trượt
                  RangeSlider(
                    values: tempRangeValues,
                    min: 0,
                    max: _maxPriceLimit,
                    divisions: 20, // Chia làm 20 nấc (mỗi nấc 1tr)
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey[200],
                    onChanged: (RangeValues values) {
                      setModalState(() => tempRangeValues = values);
                    },
                  ),
                  const SizedBox(height: 30),

                  // Nút bấm
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // Reset về mặc định
                            setModalState(
                              () => tempRangeValues = const RangeValues(
                                0,
                                20000000,
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Đặt lại"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Lưu giá trị vào biến chính và lọc
                            setState(
                              () => _currentRangeValues = tempRangeValues,
                            );
                            _applyFilterAndSort();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "ÁP DỤNG",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(widget.categoryName, style: AppStyles.h2),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textTitle,
        elevation: 0,
        centerTitle: true,
        actions: const [
          CartIconWithBadge(color: AppColors.textTitle),
          SizedBox(width: 12),
        ],
      ),
      body: Column(
        children: [
          // Toolbar Lọc & Sắp xếp
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // Logic hiển thị sort options (giữ nguyên hoặc tự thêm)
                      showModalBottomSheet(
                        context: context,
                        builder: (ctx) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text("Mới nhất"),
                              onTap: () {
                                setState(() => _sortType = 'default');
                                _applyFilterAndSort();
                                Navigator.pop(ctx);
                              },
                            ),
                            ListTile(
                              title: const Text("Giá tăng dần"),
                              onTap: () {
                                setState(() => _sortType = 'price_asc');
                                _applyFilterAndSort();
                                Navigator.pop(ctx);
                              },
                            ),
                            ListTile(
                              title: const Text("Giá giảm dần"),
                              onTap: () {
                                setState(() => _sortType = 'price_desc');
                                _applyFilterAndSort();
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.sort, size: 18),
                        SizedBox(width: 6),
                        Text("Sắp xếp"),
                      ],
                    ),
                  ),
                ),
                Container(width: 1, height: 24, color: Colors.grey[300]),
                Expanded(
                  child: InkWell(
                    onTap: _showFilterSheet,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.filter_alt_outlined,
                          size: 18,
                          color: _currentRangeValues.end < _maxPriceLimit
                              ? AppColors.primary
                              : Colors.black,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Lọc giá",
                          style: TextStyle(
                            color: _currentRangeValues.end < _maxPriceLimit
                                ? AppColors.primary
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Danh sách sản phẩm
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _displayProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        Text("Không có sản phẩm nào", style: AppStyles.body),
                        if (_currentRangeValues.end < _maxPriceLimit)
                          TextButton(
                            onPressed: () {
                              setState(
                                () => _currentRangeValues = const RangeValues(
                                  0,
                                  20000000,
                                ),
                              );
                              _applyFilterAndSort();
                            },
                            child: const Text("Xóa bộ lọc giá"),
                          ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _displayProducts.length,
                    itemBuilder: (context, index) {
                      final product = _displayProducts[index];
                      double price =
                          double.tryParse(
                            (product['sale_price'] ?? product['price'])
                                .toString(),
                          ) ??
                          0;

                      return InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                              productId: product['product_id'],
                            ),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    product['thumbnail_url'] ?? "",
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product['name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppStyles.body.copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      currencyFormat.format(price),
                                      style: AppStyles.price,
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
    );
  }
}
