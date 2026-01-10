import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ncris7shop/screens/user/category_products_screen.dart';
import 'package:ncris7shop/screens/user/product_detail_screen.dart';
import 'dart:async';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/home_service.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();

  // Dữ liệu
  List<dynamic> _banners = [];
  List<dynamic> _categories = [];
  List<dynamic> _featuredProducts = [];
  List<dynamic> _newProducts = [];

  bool _isLoading = true;
  int _currentBannerIndex = 0;
  final PageController _bannerController = PageController();

  @override
  void initState() {
    super.initState();
    _fetchHomeData();

    // Auto slide banner
    Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_banners.isNotEmpty && mounted) {
        int nextPage = _currentBannerIndex + 1;
        if (nextPage >= _banners.length) nextPage = 0;
        _bannerController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void _fetchHomeData() async {
    final banners = await _homeService.getBanners();
    final categories = await _homeService.getCategories();
    final allProducts = await _homeService.getProducts();

    List<dynamic> featured = [];
    List<dynamic> newP = [];

    for (var p in allProducts) {
      bool isFeatured = p['is_featured'] == 1 || p['is_featured'] == true;
      bool isNew = p['is_new'] == 1 || p['is_new'] == true;

      if (isFeatured) featured.add(p);
      if (isNew) newP.add(p);
    }

    if (mounted) {
      setState(() {
        _banners = banners;
        _categories = categories;
        _featuredProducts = featured;
        _newProducts = newP;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,

        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Image.asset('assets/images/logo.png', width: 28),
              const SizedBox(width: 8),
              Text(
                "NCRIS7",
                style: AppStyles.h2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 22,
                ),
              ),
              const SizedBox(width: 16),

              //THANH TÌM KIẾM DỄ NHÌN HƠN
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  child: Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors
                          .grey[100], // Nền xám nhẹ (tương phản với trắng)
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.search,
                          color: AppColors.textHint,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Bạn tìm gì...",
                          style: AppStyles.body.copyWith(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _fetchHomeData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner
                    if (_banners.isNotEmpty) ...[
                      SizedBox(
                        height: 160,
                        child: PageView.builder(
                          controller: _bannerController,
                          itemCount: _banners.length,
                          onPageChanged: (index) =>
                              setState(() => _currentBannerIndex = index),
                          itemBuilder: (context, index) {
                            return Image.network(
                              _banners[index]['image_url'],
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  Container(color: Colors.grey[300]),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _banners.map((url) {
                          int index = _banners.indexOf(url);
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentBannerIndex == index
                                  ? AppColors.primary
                                  : Colors.grey[300],
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Danh mục
                    _buildSectionTitle("Danh mục"),
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          return InkWell(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryProductsScreen(
                                  categoryId: cat['category_id'],
                                  categoryName: cat['name'],
                                ),
                              ),
                            ),
                            child: Container(
                              width: 70,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  Container(
                                    width: 55,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      image: cat['image_url'] != null
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                cat['image_url'],
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                      border: Border.all(
                                        color: AppColors.border,
                                      ),
                                    ),
                                    child: cat['image_url'] == null
                                        ? const Icon(
                                            Icons.category,
                                            color: AppColors.primary,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    cat['name'],
                                    style: const TextStyle(fontSize: 11),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Sản phẩm nổi bật
                    if (_featuredProducts.isNotEmpty) ...[
                      _buildSectionTitle("Sản phẩm Nổi bật 🔥"),
                      SizedBox(
                        height: 250,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: _featuredProducts.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 160,
                              margin: const EdgeInsets.only(right: 12),
                              child: _buildProductCard(
                                _featuredProducts[index],
                              ),
                            );
                          },
                        ),
                      ),
                    ],

                    // Sản phẩm mới
                    _buildSectionTitle("Sản phẩm Mới về 🆕"),
                    GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: _newProducts.length,
                      itemBuilder: (context, index) =>
                          _buildProductCard(_newProducts[index]),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Text(title, style: AppStyles.h2),
    );
  }

  Widget _buildProductCard(dynamic product) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    double price = double.parse(
      (product['sale_price'] ?? product['price']).toString(),
    );

    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ProductDetailScreen(productId: product['product_id']),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        product['thumbnail_url'] ?? "",
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[200]),
                      ),
                    ),
                    if (product['sale_price'] != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "SALE",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
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
                    style: AppStyles.body.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(price),
                    style: AppStyles.price.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
