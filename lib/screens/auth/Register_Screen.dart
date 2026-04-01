import 'dart:async';

import 'package:application_book/data/core/UnitofWork.dart';
import 'package:application_book/data/di/locator.dart';
import 'package:application_book/screens/auth/Login_Screen.dart';
import 'package:application_book/widgets/customPopup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Đăng ký"),
          backgroundColor: Colors.blue,
          centerTitle: true),
      backgroundColor: Colors.white,
      body: SafeArea(child: _RegisterBody()),
    );
  }
}

class _RegisterBody extends StatefulWidget {
  @override
  State<_RegisterBody> createState() => _RegisterBodyState();
}

class _RegisterBodyState extends State<_RegisterBody> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cfpasswordController = TextEditingController();
  final TextEditingController _otp = TextEditingController();
  bool _otpVerified = false;
  bool _sendOtp = false;
  Duration duration = Duration(minutes: 5);
  Timer? timer;
  final _service = getIt<UnitOfWork>();

  @override
  void dispose() {
    // TODO: implement dispose
    _emailController.dispose();
    _otp.dispose();
    timer?.cancel();
    super.dispose();
  }

  void startCountdown() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (duration.inSeconds <= 0) {
        timer.cancel();
        setState(() {
          _sendOtp = false;
        });
      } else {
        setState(() {
          duration = duration - Duration(seconds: 1);
          debugPrint("${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          _buildTextField(_emailController, 'Email'),
          const SizedBox(height: 15),
          if (_otpVerified == false) ...[
            if (_sendOtp == false) ...[
              const SizedBox(height: 15),
              CustomButton(
                text: 'Gửi OTP',
                onPressed: () => btnSendOTP(context),
              ),
            ] else ...[
              Text(
                  "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}"),
            ],
            const SizedBox(height: 15),
            _buildTextField(_otp, "OTP", isPhone: true),
            const SizedBox(height: 15),
            CustomButton(
              text: 'Xác nhận OTP',
              onPressed: () => btnVerifyOTP(context),
              backgroundColor: Colors.red,
            )
          ],
          if (_otpVerified) ...[
            _buildTextField(_passwordController, "Mật khẩu", isPassword: true),
            const SizedBox(height: 15),
            _buildTextField(_cfpasswordController, "Nhập lại mật khẩu",
                isPassword: true),
            const SizedBox(height: 15),
            CustomButton(
              text: "Đăng ký",
              onPressed: () => btnResgister(context),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> btnSendOTP(BuildContext context) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng không để trống email')),
      );
      return;
    }

    try {
      final checkEmail = await _service.authService.checkEmail(email);
      if (checkEmail) {
        final result = await _service.authService.sendOTP(email);
        if (result) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('OTP đã được gửi')),
          );
          setState(() {
            startCountdown();
            _sendOtp = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gửi OTP thất bại')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email đã tồn tại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> btnVerifyOTP(BuildContext context) async {
    final email = _emailController.text.trim();
    final otp = _otp.text.trim();
    if (email.isEmpty || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng không để trống email hoặc OTP')),
      );
      return;
    }
    final result = await _service.authService.verifyOTP(email, otp);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực OTP thành công')),
      );
      setState(() {
        _otpVerified = true;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xác thực OTP thất bại')),
      );
    }
  }

  Future<void> btnResgister(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final cfPassword = _cfpasswordController.text.trim();
    if (email.isEmpty || password.isEmpty || cfPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng không để trống thông tin')),
      );
      return;
    }
    if(password.length <=8){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yêu cầu mật khẩu phải dài hơn 8 ký tự')),
      );
      return;
    }
    if (password != cfPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp')),
      );
      return;
    }
    try {
      final result = await _service.authService.register(email, password);
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Widget _buildTextField(
      TextEditingController controller,
      String hintText, {
        bool isPassword = false,
        bool isPhone = false, // 👈 Thêm tùy chọn này
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.number : TextInputType.text,
        // 👈 kiểu bàn phím
        inputFormatters: isPhone
            ? [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(10)
        ] // 👈 Chỉ cho nhập số
            : null,
        decoration: InputDecoration(
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
}
