import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/data/models/user.dart';
import 'package:booking_app/screens/Auth/Login_Screen.dart';
import 'package:booking_app/screens/detail/UserDetail_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// User Screen
class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  User? currentUser;
  final _service = getIt<UnitOfWork>();
  bool isLoading = true;

  @override
  void initState() {
    loadUser();
    super.initState();
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final iduser = prefs.getString("iduser");
    try {
      final u = await _service.authService.getUserbyId(iduser!);
      if (u == null) {
        debugPrint("Loi khi lay user ");
      }
      setState(() {
        currentUser = u;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Loi khi lay user $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    AvatarSection(
                      name: currentUser?.fullName ?? '',
                      email: currentUser!.email,
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                        text: "Chỉnh sửa hồ sơ",
                        onPressed: () {
                          btnToEdit(currentUser!);
                        }),
                    const SizedBox(height: 20),
                    CustomButton(
                        text: "Thay đổi mật khẩu",
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => PasswordScreen(user: currentUser!,)));
                        }),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: "Đăng xuất",
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        // Điều hướng về trang đăng nhập:
                        Navigator.of(context).pushReplacement(MaterialPageRoute(
                            builder: (context) => LoginScreen()));
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Future<void> btnToEdit(User user) async {
    final updatedUser = await Navigator.push<User>(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(user: user),
      ),
    );
    // Khi quay lại, nếu có dữ liệu mới, cập nhật UI
    if (updatedUser != null) {
      setState(() {
        debugPrint(
            "${updatedUser.address}-${updatedUser.fullName}-${updatedUser.phoneNumber}");
        currentUser = updatedUser; // hoặc cập nhật vào controller/state khác
      });
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(
        'Trang cá nhân',
      ),
      backgroundColor: Colors.blue,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// Avatar Section
class AvatarSection extends StatelessWidget {
  String name;
  String email;

  AvatarSection({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(
            Icons.account_circle,
            size: 100, // Gấp đôi radius
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        Text(
          name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }
}
