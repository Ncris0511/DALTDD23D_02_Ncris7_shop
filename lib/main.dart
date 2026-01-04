import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/intro/intro_screen.dart';
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
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: const IntroScreen(),
    );
  }
}