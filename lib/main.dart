import 'package:flutter/material.dart';
import 'package:ncris7shop/screens/user/checkout_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Giày Ncris7',
      debugShowCheckedModeBanner: false, // Tắt chữ Debug góc phải
      theme: ThemeData(useMaterial3: true),
      home: const CheckoutScreen(),
    );
  }
}
