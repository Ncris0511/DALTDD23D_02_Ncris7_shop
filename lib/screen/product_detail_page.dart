import 'package:flutter/material.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black), onPressed: () {}),
        ],
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm chính
            Container(
              height: 300,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Image.network(
                'https://product.hstatic.net/200000414327/product/akka_speed_ii_xanhbien__1__b66e0f3e4d464ac1ab24bfa77a2e6b8a_small.jpg', // Link ảnh mẫu
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 100),
              ),
            ),
            const Divider(thickness: 1, height: 1),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text("1,550,000₫", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blue)),
                      SizedBox(width: 10),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                      Icon(Icons.star, color: Colors.amber, size: 18),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Giày đá bóng AKKA Speed II TF - Xanh Biển",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 16),
                  const Text("Hình ảnh", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSmallPreview('https://product.hstatic.net/200000414327/product/akka_speed_ii_xanhbien__8__9079fbecd1e24e0596c48f5bb64dfaf3_small.jpg'),
                      _buildSmallPreview('https://product.hstatic.net/200000414327/product/akka_speed_ii_xanhbien__5__f0beb968a96149c0a55d7d2096fa5615_small.jpg'),
                      _buildSmallPreview('https://product.hstatic.net/200000414327/product/akka_speed_ii_xanhbien__7__57b215885f53456f9a279b58a7170d63_small.jpg'),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Size", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [39, 40, 41, 42, 43, 44].map((size) {
                      bool isSelected = size == 40;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue.withOpacity(0.2) : Colors.grey[100],
                          border: Border.all(color: isSelected ? Colors.blue : Colors.transparent),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(size.toString(), style: TextStyle(color: isSelected ? Colors.blue : Colors.black54)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 25),
                  const Text("Mô tả", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  const SizedBox(height: 10),
                  _buildDetailItem("Thương hiệu: Giày đá bóng nam AKKA"),
                  _buildDetailItem("Sở hữu thương hiệu: CTCP Thế Giới Bóng Đá"),
                  _buildDetailItem("Giày đá bóng nam với da Microfiber cao cấp"),
                  const Text("GIÀY ĐÁ BÓNG NAM AKKA SPEED TF", style: TextStyle(fontWeight: FontWeight.bold)),
                  _buildDetailItem("AKKA SPEED Phù hợp với các cầu thủ có lối chơi tốc độ."),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
              child: IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text("Thêm vào giỏ hàng", style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/cart'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text("Mua Ngay", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallPreview(String url) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
      child: Image.network(url, width: 45, height: 45),
    );
  }

  Widget _buildDetailItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("✓ ", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}