import 'package:flutter/material.dart';
import 'package:ncris7shop/screens/user/cart_screen.dart';
import 'package:ncris7shop/screens/user/home_screen.dart';
import 'package:ncris7shop/screens/user/profile_screen.dart';
import '../../utils/constants.dart';
import '../../services/cart_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  int _cartCount = 0;
  final CartService _cartService = CartService();

  // Danh sách màn hình
  final List<Widget> _screens = [
    const HomeScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _fetchCartCount();
  }

  void _fetchCartCount() async {
    final items = await _cartService.getCart();
    if (mounted) {
      setState(() {
        _cartCount = items.length;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Cập nhật số lượng mỗi khi chuyển tab
    _fetchCartCount();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          height: 70,
          elevation: 0,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.1),
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Trang chủ',
            ),
            NavigationDestination(
              icon: Badge(
                label: _cartCount > 0 ? Text('$_cartCount') : null,
                isLabelVisible: _cartCount > 0,
                backgroundColor: AppColors.primaryRed,
                child: const Icon(Icons.shopping_cart_outlined),
              ),
              selectedIcon: Badge(
                label: _cartCount > 0 ? Text('$_cartCount') : null,
                isLabelVisible: _cartCount > 0,
                backgroundColor: AppColors.primaryRed,
                child: const Icon(
                  Icons.shopping_cart,
                  color: AppColors.primary,
                ),
              ),
              label: 'Giỏ hàng',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Tài khoản',
            ),
          ],
        ),
      ),
    );
  }
}
