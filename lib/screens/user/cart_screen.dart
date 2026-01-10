import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ncris7shop/screens/user/checkout_screen.dart';
import '../../utils/constants.dart';
import '../../utils/styles.dart';
import '../../services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  List<dynamic> _cartItems = [];
  final Set<int> _selectedItemIds = {};

  bool _isLoading = true;
  double _totalPrice = 0;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final items = await _cartService.getCart();
    if (mounted) {
      setState(() {
        _cartItems = items;
        // Xóa ID đã chọn nếu không còn trong giỏ
        _selectedItemIds.removeWhere(
          (id) => !items.any((item) => item['cart_item_id'] == id),
        );
        _calculateTotal();
        _isLoading = false;
      });
    }
  }

  void _calculateTotal() {
    double total = 0;
    for (var item in _cartItems) {
      if (_selectedItemIds.contains(item['cart_item_id'])) {
        double price = double.parse(
          (item['product']['sale_price'] ?? item['product']['price'])
              .toString(),
        );
        int qty = item['quantity'];
        total += price * qty;
      }
    }
    setState(() => _totalPrice = total);
  }

  void _toggleItem(int id) {
    setState(() {
      if (_selectedItemIds.contains(id)) {
        _selectedItemIds.remove(id);
      } else {
        _selectedItemIds.add(id);
      }
      _calculateTotal();
    });
  }

  void _toggleAll(bool? value) {
    setState(() {
      if (value == true) {
        _selectedItemIds.addAll(
          _cartItems.map((e) => e['cart_item_id'] as int),
        );
      } else {
        _selectedItemIds.clear();
      }
      _calculateTotal();
    });
  }

  bool get _isAllSelected =>
      _cartItems.isNotEmpty && _selectedItemIds.length == _cartItems.length;

  void _updateQuantity(int index, int newQty) async {
    if (newQty < 1) {
      final bool? confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Xác nhận"),
          content: const Text("Xóa sản phẩm khỏi giỏ hàng?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Hủy"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm == true) _deleteItem(index);
      return;
    }

    setState(() {
      _cartItems[index]['quantity'] = newQty;
      _calculateTotal();
    });

    await _cartService.updateQuantity(
      _cartItems[index]['cart_item_id'],
      newQty,
    );
  }

  void _deleteItem(int index) async {
    int id = _cartItems[index]['cart_item_id'];
    var deletedItem = _cartItems[index];

    setState(() {
      _cartItems.removeAt(index);
      _selectedItemIds.remove(id);
      _calculateTotal();
    });

    bool success = await _cartService.deleteItem(id);
    if (!success && mounted) {
      setState(() {
        _cartItems.insert(index, deletedItem);
        _calculateTotal();
      });
    }
  }

  void _handleCheckout() async {
    if (_selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn sản phẩm để mua!")),
      );
      return;
    }

    final selectedItems = _cartItems
        .where((item) => _selectedItemIds.contains(item['cart_item_id']))
        .toList();

    // Chuyển sang Checkout
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CheckoutScreen(items: selectedItems)),
    );

    // Khi quay lại: Reload lại giỏ
    setState(() => _isLoading = true);
    _loadCart();
    setState(() => _selectedItemIds.clear());
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text("Giỏ hàng", style: AppStyles.h2),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textTitle,
        centerTitle: true,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadCart,
              child: _cartItems.isEmpty
                  ? ListView(
                      // Dùng ListView để kéo refresh được khi rỗng
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3,
                        ),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                size: 80,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                "Giỏ hàng trống",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _cartItems.length,
                            itemBuilder: (context, index) {
                              final item = _cartItems[index];
                              final product = item['product'];
                              final variant = item['variant'];
                              double price = double.parse(
                                (product['sale_price'] ?? product['price'])
                                    .toString(),
                              );
                              int cartItemId = item['cart_item_id'];
                              bool isSelected = _selectedItemIds.contains(
                                cartItemId,
                              );

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.border),
                                ),
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      height: 30,
                                      child: Checkbox(
                                        value: isSelected,
                                        activeColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        onChanged: (val) =>
                                            _toggleItem(cartItemId),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        variant['image_url'] ??
                                            product['thumbnail_url'],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[200],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product['name'],
                                            style: AppStyles.h3,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${variant['color']} | Size ${variant['size']}",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            currencyFormat.format(price),
                                            style: AppStyles.price,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        InkWell(
                                          onTap: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text(
                                                  "Xóa sản phẩm",
                                                ),
                                                content: const Text(
                                                  "Bạn muốn xóa sản phẩm này?",
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          false,
                                                        ),
                                                    child: const Text("Hủy"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          ctx,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      "Xóa",
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true)
                                              _deleteItem(index);
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            InkWell(
                                              onTap: () => _updateQuantity(
                                                index,
                                                item['quantity'] - 1,
                                              ),
                                              child: const Icon(
                                                Icons.remove,
                                                size: 20,
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8.0,
                                                  ),
                                              child: Text(
                                                "${item['quantity']}",
                                                style: AppStyles.h3,
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () => _updateQuantity(
                                                index,
                                                item['quantity'] + 1,
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                size: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _isAllSelected,
                                      activeColor: AppColors.primary,
                                      onChanged: _toggleAll,
                                    ),
                                    const Text("Tất cả"),
                                    const Spacer(),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        const Text(
                                          "Tổng thanh toán:",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          currencyFormat.format(_totalPrice),
                                          style: AppStyles.price.copyWith(
                                            fontSize: 18,
                                            color: AppColors.primaryRed,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _handleCheckout,
                                    child: Text(
                                      "MUA HÀNG (${_selectedItemIds.length})",
                                      style: AppStyles.buttonText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }
}
