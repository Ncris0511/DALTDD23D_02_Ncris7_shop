import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ncris7shop/screens/user/product_detail_screen.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/home_service.dart';
import '../../widgets/cart_icon_badge.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final HomeService _homeService = HomeService();

  List<dynamic> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  void _doSearch() async {
    String keyword = _searchController.text.trim();
    if (keyword.isEmpty) return;

    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final data = await _homeService.getProducts(keyword: keyword);

    if (mounted) {
      setState(() {
        _results = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: const BackButton(color: AppColors.textTitle),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            style: AppStyles.body.copyWith(color: AppColors.textTitle),
            onSubmitted: (_) => _doSearch(),
            decoration: const InputDecoration(
              hintText: "Bạn tìm gì hôm nay?",
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: AppColors.textHint),
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        actions: const [
          CartIconWithBadge(color: AppColors.textTitle), // Dùng widget mới
          SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : (_results.isEmpty && _hasSearched)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Không tìm thấy sản phẩm nào", style: AppStyles.h3),
                  const SizedBox(height: 8),
                  Text(
                    "Thử tìm với từ khóa khác xem sao!",
                    style: AppStyles.body,
                  ),
                ],
              ),
            )
          : !_hasSearched
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 80, color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  Text("Nhập từ khóa để tìm kiếm", style: AppStyles.body),
                ],
              ),
            )
          : ListView.builder(
              // Hiển thị dạng List cho dễ nhìn chi tiết
              padding: const EdgeInsets.all(16),
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final product = _results[index];
                double price = double.parse(
                  (product['sale_price'] ?? product['price']).toString(),
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductDetailScreen(
                          productId: product['product_id'],
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                          child: Image.network(
                            product['thumbnail_url'] ?? "",
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 100,
                              height: 100,
                              color: Colors.grey[200],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: AppStyles.h3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                currencyFormat.format(price),
                                style: AppStyles.price,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
