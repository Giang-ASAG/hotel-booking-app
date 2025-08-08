import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/screens/Auth/Register_Screen.dart';
import 'package:booking_app/screens/auth/Forget_Screen.dart';
import 'package:booking_app/screens/main/Main_Screen.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Đăng nhập"),
          backgroundColor: Colors.blue,
          centerTitle: true),
      backgroundColor: Colors.white,
      body: SafeArea(child: _LoginBody()),
    );
  }
}

class _LoginBody extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _service = getIt<UnitOfWork>();

  _LoginBody();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.08),
          const Text(
            "ODOLO",
            style: TextStyle(color: Colors.blue, fontSize: 16),
          ),
          const SizedBox(height: 30),
          _buildTextField(_emailController, 'Email', 'Nhập email'),
          const SizedBox(height: 15),
          _buildTextField(_passwordController, 'Mật khẩu', 'Nhập mật khẩu',
              isPassword: true),
          const SizedBox(height: 25),
          CustomButton(text: 'Đăng nhập', onPressed: () => btnLogin(context)),
          // _buildLoginButton(context),
          const SizedBox(height: 10),
          _buildRegisterText(context),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Future<void> btnLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đầy đủ thông tin")),
      );
      return;
    }
    try {
      final result = await _service.authService.login(email, password);
      if (result) {
        if (!context.mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
              builder: (_) => MainScreen(
                    currentIndex: 0,
                  )),
        );
        // Sau khi đăng nhập thành công, chuyển hướng đến HomeScreen
        debugPrint("Sau khi push HomeScreen");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đăng nhập thành công")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sai email hoặc mật khẩu")),
        );
      }
    } catch (e) {
      debugPrint("Dang nhap loi");
      showPopup(
          context: context,
          title: "Lỗi",
          type: AlertType.error,
          content: "Vui lòng kiểm tra kết nối mạng",
          onOkPressed: () {});
    }
  }

  // Suggested code may be subject to a license. Learn more: ~LicenseLog:3030660662.
  Widget _buildTextField(
    TextEditingController controller,
    String lableText,
    String hintText, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          labelText: lableText,
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 14,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildRegisterText(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // Căn giữa hàng
      children: [
        Expanded( // Dùng Expanded để chia đều không gian
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              );
            },
            child: const Text('Đăng ký', style: TextStyle(color: Colors.blue)),
          ),
        ),
        Expanded( // Dùng Expanded để chia đều không gian
          child: TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ForgetScreen()),
              );
            },
            child: const Text('Quên mật khẩu', style: TextStyle(color: Colors.indigo)),
          ),
        ),
      ],
    );
  }
}
