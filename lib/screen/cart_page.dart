import 'package:flutter/material.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  final List<Map<String, dynamic>> items = const [
    {"name": "Giày đá bóng AKKA Speed II TF - Xanh Biển", "price": "1,550,000₫", "size": "43", "color": Colors.blue},
    {"name": "Giày Nike Air Zoom Mercurial Superfly 9", "price": "1,990,000₫", "size": "43", "color": Colors.pink},
    {"name": "Giày đá bóng Wika Flash - Xanh chuối", "price": "550,000₫", "size": "43", "color": Colors.greenAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: const Text("Giỏ hàng", style: TextStyle(color: Colors.black, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.blue), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(onPressed: () {}, child: const Text("Sửa", style: TextStyle(color: Colors.black))),
          IconButton(icon: const Icon(Icons.chat_bubble_outline, color: Colors.blue), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                Checkbox(value: true, activeColor: Colors.blue, onChanged: (v) {}),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['name'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.blue), maxLines: 2),
                      const SizedBox(height: 4),
                      Text("Size: ${item['size']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item['price'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                          _buildQtySelector(),
                        ],
                      )
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22), onPressed: () {}),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.confirmation_num_outlined, color: Colors.blue),
                const SizedBox(width: 8),
                const Expanded(child: Text("Tất cả voucher")),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(value: false, onChanged: (v) {}),
                const Text("Tất cả"),
                const Spacer(),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text("Thanh toán", style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQtySelector() {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(4)),
      child: const Row(
        children: [
          Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text("-")),
          VerticalDivider(width: 1),
          Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("1")),
          VerticalDivider(width: 1),
          Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Text("+", style: TextStyle(color: Colors.blue))),
        ],
      ),
    );
  }
}