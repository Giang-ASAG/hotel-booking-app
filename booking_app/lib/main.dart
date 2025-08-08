import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/screens/Auth/Login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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
