import 'package:application_book/data/di/locator.dart';
import 'package:application_book/screens/auth/Login_Screen.dart';
import 'package:flutter/material.dart';

void main() {
  setupLocator(); // Thiết lập GetIt để quản lý dependency injection
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginScreen(), // Màn hình khởi động là LoginScreen
    );
  }
}