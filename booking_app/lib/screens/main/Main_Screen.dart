import 'package:booking_app/screens/history/BookingHistory_Screen.dart';
import 'package:booking_app/screens/home/Home_Screen.dart';
import 'package:booking_app/screens/search/Search_Screen.dart';
import 'package:booking_app/screens/user/User_Screen.dart';
import 'package:flutter/material.dart';


class MainScreen extends StatefulWidget {
  int currentIndex;
  MainScreen({super.key, required this.currentIndex});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  @override
  void initState() {
    _currentIndex = widget.currentIndex;
    super.initState();
  }
  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    BookingHistoryScreen(),
    UserScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Đặt phòng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
