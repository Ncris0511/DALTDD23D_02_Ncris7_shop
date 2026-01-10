import 'package:flutter/material.dart';
import 'package:ncris7shop/screens/user/cart_screen.dart';
import '../services/cart_service.dart';
import '../utils/constants.dart';

class CartIconWithBadge extends StatefulWidget {
  final Color color;
  const CartIconWithBadge({super.key, this.color = Colors.white});

  @override
  State<CartIconWithBadge> createState() => _CartIconWithBadgeState();
}

class _CartIconWithBadgeState extends State<CartIconWithBadge> {
  int _itemCount = 0;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _fetchCount();
  }

  // Hàm lấy số lượng item trong giỏ
  void _fetchCount() async {
    final items = await _cartService.getCart();
    if (mounted) {
      setState(() {
        _itemCount = items.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.shopping_cart_outlined, color: widget.color),
          onPressed: () {
            // Khi bấm vào giỏ hàng -> Chuyển trang -> Khi quay lại thì reload số lượng
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ).then((_) => _fetchCount());
          },
        ),
        if (_itemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: AppColors.primaryRed,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                '$_itemCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
