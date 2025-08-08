import 'package:booking_app/data/core/UnitOfWork.dart';
import 'package:booking_app/data/di/locator.dart';
import 'package:booking_app/data/models/user.dart';
import 'package:booking_app/widgets/customButton.dart';
import 'package:booking_app/widgets/custom_popup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class UserDetailScreen extends StatefulWidget {
  final User user;

  const UserDetailScreen({super.key, required this.user});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  TextEditingController fullname = TextEditingController();
  TextEditingController sdt = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController adress = TextEditingController();
  final _service = getIt<UnitOfWork>();

  @override
  void initState() {
    super.initState();
    fullname.text = widget.user.fullName ?? '';
    sdt.text = widget.user.phoneNumber ?? '';
    email.text = widget.user.email;
    adress.text = widget.user.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField("Email", email, readonly: true, "Email"),
            const SizedBox(height: 20),
            _buildTextField(
                "Họ và tên", fullname, readonly: false, "Họ và tên"),
            const SizedBox(height: 20),
            _buildTextField(
                "Số điện thoại",
                sdt,
                readonly: false,
                "Số điện thoại",
                isPhone: true),
            const SizedBox(height: 20),
            _buildTextField(
                "Địa chỉ", adress, readonly: false, "Địa chỉ", maxLine: 4),
            const SizedBox(height: 30),
            CustomButton(
                text: "Lưu",
                onPressed: () {
                  btnSave(context);
                })
          ],
        ),
      ),
    );
  }

  Future<void> btnSave(BuildContext context) async {
    if (fullname.text.isEmpty || adress.text.isEmpty || sdt.text.isEmpty) {
      showPopup(
          context: context,
          onOkPressed: () {},
          title: "Thông báo",
          content: "Không được để trống",
          type: AlertType.info);
    } else {
      try {
        final u = User(
            userId: widget.user.userId,
            fullName: fullname.text,
            email: email.text,
            address: adress.text,
            phoneNumber: sdt.text);
        final result = await _service.authService.updateUser(u);
        if (result == null) {
          debugPrint("Loi khi cap nhat thong tin");
        } else {
          debugPrint("cap nhat thong tin thanh cong");
          setState(() {
            fullname.text = result.fullName ?? '';
            sdt.text = result.phoneNumber ?? '';
            adress.text = result.address ?? '';
          });
          showPopup(
              context: context,
              title: "Thông báo",
              content: "Cập nhật thành công",
              type: AlertType.success,
              onOkPressed: () {
                Navigator.pop(context, u);
              });
        }
      } catch (e) {
        debugPrint("Loi save $e");
      }
    }
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hintText,
      {bool readonly = false,
      bool isPassword = false,
      bool isPhone = false,
      int maxLine = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        maxLines: maxLine,
        readOnly: readonly,
        obscureText: isPassword,
        keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
        inputFormatters: isPhone
            ? [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ]
            : null,
        decoration: InputDecoration(
          labelText: label,
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

//Man hinh thay doi pass word
class PasswordScreen extends StatefulWidget {
  User user;

  PasswordScreen({super.key, required this.user});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  TextEditingController password = TextEditingController();
  TextEditingController afterpassword = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();
  final _service = getIt<UnitOfWork>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chỉnh sửa hồ sơ"),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildTextField("Mật khẩu hiện tại", password, ""),
            const SizedBox(height: 20),
            _buildTextField("Mật khẩu mới", afterpassword, ""),
            const SizedBox(height: 20),
            _buildTextField("Nhập lại mật khẩu mới", confirmpassword, ""),
            const SizedBox(height: 30),
            CustomButton(
                text: "Lưu",
                onPressed: () async {
                  if (afterpassword.text != confirmpassword.text) {
                    showPopup(
                        context: context,
                        onOkPressed: () {},
                        title: "Thông báo",
                        content:
                            "Mật khẩu mới và nhập lại mật khẩu không trùng",
                        type: AlertType.error);
                  }
                  final result = await _service.authService.changePassword(
                      widget.user.userId, password.text, afterpassword.text);
                  if (result) {
                    showPopup(
                        context: context,
                        onOkPressed: () {
                          Navigator.pop(context);
                        },
                        title: "Thông báo",
                        content: "Thay đổi mật khẩu thành công",
                        type: AlertType.success);
                  } else {
                    debugPrint("Doi pass that bai");
                  }
                })
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hintText,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
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
